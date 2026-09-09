// SPDX-License-Identifier: AGPL-3.0-only
//
// What this phone wants to be told, and telling the site so.
//
// ⚠ **The registration token is not here yet.** Getting one needs
// `firebase_messaging` and a `google-services.json` from a Firebase project,
// and only she can create that project. Everything else — the switches, where
// they are kept, sending them to the site, taking the phone off the list — is
// built and works, so plugging Firebase in is one dependency, one config file,
// and filling in `_registrationToken` below.
//
// It is written this way round on purpose. The alternative was to add the
// plugin now against a project that does not exist, which does not compile, and
// leave the app un-buildable until she has time to do the Firebase setup.
//
// ⚠ **No account is required.** Somebody who installed this to know when a
// stream starts should be told whether or not they ever sign up. Only
// `wantsReplies` needs one, because it is about their own writing, and the
// screen says so rather than showing a switch that quietly does nothing.
import 'dart:convert';

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

  static Future<Notifications> load(Account account) async =>
      Notifications._(await SharedPreferences.getInstance(), account);

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

  /// ⚠ **The Firebase seam.** Returns null until this is filled in.
  ///
  /// To finish it:
  ///   1. Make a Firebase project and add an Android app with this
  ///      application id (com.shrutivtuber.shruti_tools).
  ///   2. Put `google-services.json` in `android/app/`.
  ///   3. Add `firebase_core` and `firebase_messaging` to pubspec.yaml.
  ///   4. Replace the body here with:
  ///        await Firebase.initializeApp();
  ///        final settings = await FirebaseMessaging.instance.requestPermission();
  ///        if (settings.authorizationStatus != AuthorizationStatus.authorized) {
  ///          return null;
  ///        }
  ///        return FirebaseMessaging.instance.getToken();
  ///   5. On the SITE, set SHRUTI_FCM_SERVICE_ACCOUNT to the service account
  ///      JSON from the same project.
  Future<String?> _registrationToken() async => null;
}
