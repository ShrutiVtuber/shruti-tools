// SPDX-License-Identifier: AGPL-3.0-only
//
// What this phone wants to be told, and telling the site so.
//
// ⚠ **`android/app/google-services.json` is required to BUILD this.** It is
// gitignored — it identifies her Firebase project — so a fresh checkout fails
// in Gradle with a message about the Google Services plugin rather than
// anything mentioning notifications. Download it from the Firebase console for
// the Android app `com.shrutivtuber.astrolabe` and drop it there.
//
// The seam below degrades to null rather than throwing, so an app built
// without it still runs; the notification switch simply says it is not set up.
//
// ⚠ **No account is required.** Somebody who installed this to know when a
// stream starts should be told whether or not they ever sign up. Only
// `wantsReplies` needs one, because it is about their own writing, and the
// screen says so rather than showing a switch that quietly does nothing.
import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'account.dart';
import 'site.dart' show siteOrigin;

const _timeout = Duration(seconds: 12);

/// One switch, and what it is for.
class Notice {
  const Notice(this.key, this.label, this.about, {this.needsAccount = false});

  final String key;
  final String label;
  final String about;
  final bool needsAccount;
}

/// ⚠ The keys must match the site's `WHO` map in `core/notify.py`. A key that
/// does not match is a switch that reaches nothing, silently.
const notices = [
  Notice(
    'live',
    'She goes live',
    'The one most people install this for. Worthless five minutes late.',
  ),
  Notice(
    'video',
    'A new video',
    'When something is posted, not when it is scheduled.',
  ),
  Notice(
    'horoscope',
    'The readings are up',
    'When a period is published, all twelve signs at once.',
  ),
  Notice('writing', 'A new article', 'When she posts to the journal.'),
  Notice(
    'replies',
    'Somebody read your practice reading',
    'Only about your own writing.',
    needsAccount: true,
  ),
];

class Notifications extends ChangeNotifier {
  Notifications._(this._prefs, this._account);

  final SharedPreferences _prefs;
  final Account _account;

  static Future<Notifications> load(Account account) async {
    final it = Notifications._(await SharedPreferences.getInstance(), account);
    // ⚠ **At every start, not only when the switch is turned on.** The
    // foreground listener lives in memory and dies with the process, so a
    // phone that registered last week has a perfectly good token, receives
    // every message, and draws none of them until the app is next backgrounded
    // — which looks exactly like notifications being broken and is the same
    // silent failure the listener was written to fix, one restart later.
    if (it.on) unawaited(it._watchWhileOpen());
    return it;
  }

  bool wants(String key) => _prefs.getBool('notify.$key') ?? _byDefault(key);

  /// What somebody installing this app plainly came for.
  static bool _byDefault(String key) =>
      key == 'live' || key == 'video' || key == 'replies';

  /// Whether the phone has ever been registered.
  bool get on => _prefs.getBool('notify.on') ?? false;

  String? get _token => _prefs.getString('notify.token');

  Future<void> setWants(String key, bool value) async {
    await _prefs.setBool('notify.$key', value);
    notifyListeners();
    if (on) await _sendPreferences();
  }

  /// Ask for permission, get a token, and tell the site.
  ///
  /// ⚠ Returns a reason rather than throwing, and the screen shows it. The
  /// commonest outcome by far is "permission refused", which is somebody's
  /// choice and not an error.
  Future<String?> turnOn() async {
    final token = await _registrationToken();
    if (token == null) {
      return 'Notifications are not set up in this build yet.';
    }
    await _prefs.setString('notify.token', token);
    await _prefs.setBool('notify.on', true);
    notifyListeners();
    final trouble = await _sendPreferences();
    if (trouble != null) {
      await _prefs.setBool('notify.on', false);
      notifyListeners();
    }
    return trouble;
  }

  /// Take this phone off the list entirely.
  Future<void> turnOff() async {
    final token = _token;
    await _prefs.setBool('notify.on', false);
    notifyListeners();
    if (token == null) return;
    try {
      await http
          .delete(Uri.parse('$siteOrigin/api/devices/$token'))
          .timeout(_timeout);
    } catch (_) {
      // ⚠ The switch is already off locally. Somebody turning notifications
      // off on a train must not have them come back because the site was
      // unreachable at that moment; the token stops being refreshed and the
      // site prunes it when sending fails.
    }
  }

  Future<String?> _sendPreferences() async {
    final token = _token;
    if (token == null) return 'This phone has no notification token.';
    try {
      final r = await http
          .put(
            Uri.parse('$siteOrigin/api/devices'),
            headers: {
              'Content-Type': 'application/json',
              // Attaches the device to the account when there is one, so
              // "somebody replied to your reading" has somewhere to go.
              ..._account.headers,
            },
            body: jsonEncode({
              'token': token,
              'platform': defaultTargetPlatform == TargetPlatform.iOS
                  ? 'ios'
                  : 'android',
              for (final n in notices) 'wants_${n.key}': wants(n.key),
            }),
          )
          .timeout(_timeout);
      if (r.statusCode >= 400) {
        return 'The site would not take that (${r.statusCode}).';
      }
      return null;
    } catch (_) {
      return 'Could not reach shrutivtuber.com.';
    }
  }

  /// ⚠ **The channel, declared by US and not by FCM.**
  ///
  /// Left to itself, Firebase invents `fcm_fallback_notification_channel`,
  /// which has no sound and no vibration. The notification then arrives
  /// perfectly correctly and completely silently, which to the person holding
  /// the phone is indistinguishable from it never arriving. The id here
  /// matches the one named in AndroidManifest.xml.
  static const _channel = AndroidNotificationChannel(
    'live',
    'When Shruti goes live',
    description: 'A stream starting, and answers to your practice writing.',
    importance: Importance.high,
  );

  final _local = FlutterLocalNotificationsPlugin();
  bool _listening = false;

  /// Draw the ones that arrive while the app is OPEN.
  ///
  /// ⚠ **This is the whole of the bug it was written for.** Android draws an
  /// FCM notification by itself only when the app is in the background. In the
  /// foreground it hands the message to the app and draws nothing, on the
  /// reasonable theory that an app on screen can say so better than a banner.
  /// An app that does not handle this shows NOTHING — and the first three test
  /// notifications vanished exactly that way, with a 200 from Firebase and a
  /// delivery logged on the phone, which is the most misleading shape a
  /// failure can have.
  Future<void> _watchWhileOpen() async {
    if (_listening) return;
    _listening = true;
    try {
      await _startWatching();
    } catch (error) {
      // ⚠ Said out loud. This runs from `unawaited` at startup, where a thrown
      // error goes nowhere at all — and its only symptom would be
      // notifications that arrive while the app is open and are never drawn,
      // which is precisely the bug this method exists to fix.
      _listening = false;
      debugPrint('notifications: cannot watch while open ($error)');
    }
  }

  Future<void> _startWatching() async {

    // ⚠ **initialize() FIRST, then the channel.** The other way round,
    // `resolvePlatformSpecificImplementation` has no platform to resolve and
    // returns null — so the `?.` swallows the call, no channel is created, and
    // Android quietly falls back to FCM's silent one. Nothing throws and
    // nothing is logged; the only symptom is a notification with no sound,
    // which reads as a phone setting rather than a bug.
    await _local.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
    ));

    final android = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) {
      debugPrint('notifications: no Android plugin to make a channel with');
      return;
    }
    await android.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen((message) {
      final note = message.notification;
      if (note == null) return;
      _local.show(
        note.hashCode,
        note.title,
        note.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id, _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
        ),
        payload: message.data['url'] as String?,
      );
    });
  }

  /// This device's address at Firebase, or null if we may not have one.
  ///
  /// Null is a normal answer, not a failure: somebody who declines the
  /// permission prompt gets null, and so does a device with no Play Services
  /// at all. Both are told "not set up in this build yet" rather than shown an
  /// error, because neither is anything they did wrong.
  ///
  /// ⚠ Every call is wrapped. `Firebase.initializeApp()` throws if
  /// `google-services.json` was missing at BUILD time — the file is gitignored,
  /// so a clean checkout produces an app that compiles and then throws here,
  /// on a screen the user opened deliberately. A throw would take the settings
  /// screen down with it; null just leaves the switch off.
  Future<String?> _registrationToken() async {
    try {
      /// Safe to call more than once — it returns the existing app.
      await Firebase.initializeApp();
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return null;
      }
      await _watchWhileOpen();
      return await FirebaseMessaging.instance.getToken();
    } catch (error) {
      debugPrint('notifications: no Firebase token ($error)');
      return null;
    }
  }
}
