// SPDX-License-Identifier: AGPL-3.0-only
//
// A site account, held on the phone.
//
// One account, both places: somebody who signs up here is signed in on
// shrutivtuber.com and the other way round. The website keeps its session in an
// httpOnly cookie; a phone cannot use that, so the app asks for the same signed
// session as a bearer token and sends it itself.
//
// ⚠ **Nothing else in this app needs an account.** Every instrument computes on
// the device. Signing in adds her side of things — saved charts, practice
// readings — and a reader who never signs in loses nothing they had. So every
// call here fails soft into a message, never into a broken screen.
//
// ⚠ **The consent wording is FETCHED, never written here.** What a person reads
// must be what gets filed, and the site already keeps that in one place with a
// test holding its copies together. A fourth copy in Dart would be a fourth
// thing to drift.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'site.dart' show siteOrigin;

const _timeout = Duration(seconds: 12);
const _tokenKey = 'account.token';

/// One of the three decisions, exactly as the site words it.
class Consent {
  const Consent({
    required this.kind,
    required this.label,
    required this.wording,
    required this.basis,
    required this.required,
    required this.explanation,
  });

  factory Consent.fromJson(Map<String, dynamic> j) => Consent(
    kind: j['kind'] as String,
    label: j['label'] as String? ?? '',
    wording: j['wording'] as String? ?? '',
    basis: j['basis'] as String? ?? '',
    required: j['required'] as bool? ?? false,
    explanation: j['explanation'] as String? ?? '',
  );

  final String kind;
  final String label;
  final String wording;
  final String basis;

  /// Only the contract consent may be this. The site refuses to make a
  /// special-category consent required, and so does the screen.
  final bool required;
  final String explanation;
}

/// Who is signed in, if anybody.
class Reader {
  const Reader({required this.id, required this.email, required this.name});

  factory Reader.fromJson(Map<String, dynamic> j) => Reader(
    id: j['id'] as int? ?? 0,
    email: j['email'] as String? ?? '',
    name: (j['displayName'] ?? j['display_name'] ?? '') as String,
  );

  final int id;
  final String email;
  final String name;

  String get shownName => name.trim().isEmpty ? email : name.trim();
}

/// What went wrong, in words worth showing somebody.
class AccountTrouble implements Exception {
  const AccountTrouble(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The signed-in reader, and the token that proves it.
///
/// A ChangeNotifier so the shell can show who is signed in without every
/// screen fetching it again.
class Account extends ChangeNotifier {
  Account._(this._prefs, this._token);

  final SharedPreferences _prefs;
  String? _token;
  Reader? _reader;

  static Future<Account> load() async {
    final prefs = await SharedPreferences.getInstance();
    final account = Account._(prefs, prefs.getString(_tokenKey));
    // Don't block startup on the network: the token is enough to show a
    // signed-in shell, and who it belongs to arrives when it arrives.
    unawaited(account.refresh());
    return account;
  }

  bool get signedIn => _token != null;
  Reader? get reader => _reader;
  String? get token => _token;

  /// The header to send with anything that needs an account.
  Map<String, String> get headers =>
      _token == null ? const {} : {'Authorization': 'Bearer $_token'};

  Uri _at(String path) => Uri.parse('$siteOrigin$path');

  /// The three decisions, worded by the site.
  Future<List<Consent>> consents() async {
    final r = await http.get(_at('/api/account/consents')).timeout(_timeout);
    if (r.statusCode != 200) {
      throw const AccountTrouble('Could not reach shrutivtuber.com.');
    }
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return [
      for (final c in (body['consents'] as List))
        Consent.fromJson(c as Map<String, dynamic>),
    ];
  }

  /// Make an account. [granted] maps a consent kind to the answer given.
  ///
  /// ⚠ Returns [SignUpOutcome.checkEmail] when the site declines to say whether
  /// the address already has an account — that is deliberate over there and
  /// must not be turned into "that email is taken" here. Whether an address has
  /// an account is not something a stranger gets to learn from a form.
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
    required String name,
    required Map<String, bool> granted,
  }) async {
    final r = await _post('/api/account/signup', {
      'email': email.trim(),
      'password': password,
      'display_name': name.trim(),
      'bearer': true,
      'consents': [
        for (final entry in granted.entries)
          {'kind': entry.key, 'granted': entry.value},
      ],
    });
    if (r['token'] is String) {
      await _keep(r['token'] as String);
      await refresh();
      return SignUpOutcome.signedIn;
    }
    return SignUpOutcome.checkEmail;
  }

  Future<void> signIn({required String email, required String password}) async {
    final r = await _post('/api/account/signin', {
      'email': email.trim(),
      'password': password,
      'bearer': true,
    });
    final token = r['token'];
    if (token is! String) {
      throw const AccountTrouble('That email and password do not match.');
    }
    await _keep(token);
    await refresh();
  }

  /// Ask the site to email a link for setting a password.
  ///
  /// Covers two people with one button. Somebody who forgot theirs, and
  /// somebody who never had one — the website lets an account be made with a
  /// magic link and no password at all, and that person could otherwise never
  /// sign in HERE, because a phone has nowhere for a magic link to land.
  ///
  /// ⚠ The answer is the same whether or not the address has an account. That
  /// is deliberate over there and must stay deliberate here: whether somebody
  /// has an account is not a thing a form gets to tell a stranger.
  Future<void> requestPassword(String email) async {
    await _post('/api/account/reset/request', {'email': email.trim()});
  }

  Future<void> signOut() async {
    _token = null;
    _reader = null;
    await _prefs.remove(_tokenKey);
    notifyListeners();
  }

  /// Delete the account, from inside the app.
  ///
  /// ⚠ **Required by Apple, and it was missing.** Guideline 5.1.1(v): an app
  /// that lets somebody create an account must let them delete it there too —
  /// not on a website, not by emailing anybody. Version 1.0.0 was rejected on
  /// 12 September 2026 partly for this, and the reviewer asked to be shown the
  /// flow on video.
  ///
  /// ⚠ It is also the right thing on its own terms. An account you can make in
  /// the app and can only unmake in a browser is a door that opens one way.
  ///
  /// Immediate and irreversible on the server: the account, the address, the
  /// preferences, the nativity and the newsletter subscription all go. What
  /// survives is an anonymised record that consent was given and withdrawn,
  /// which is the evidence the law asks for and carries no birth data.
  ///
  /// Signs out locally whatever the server said, because an account that is
  /// gone must not leave a phone claiming to be signed in to it.
  Future<void> deleteAccount() async {
    final http.Response r;
    try {
      r = await http
          .delete(_at('/api/account/'), headers: headers)
          .timeout(_timeout);
    } catch (_) {
      throw const AccountTrouble(
        'Could not reach shrutivtuber.com. Nothing has been deleted.',
      );
    }
    // ⚠ 401 means the token is already dead — the account is gone, or the
    // session expired. Either way there is nothing left to delete and the
    // honest local answer is the same as success.
    if (r.statusCode != 200 && r.statusCode != 401) {
      throw const AccountTrouble(
        'The site refused. Nothing has been deleted — try again in a moment.',
      );
    }
    await signOut();
  }

  /// Ask the site who this token belongs to.
  ///
  /// A token the site no longer accepts signs the reader out here rather than
  /// leaving a shell that says "signed in" over calls that all fail.
  Future<void> refresh() async {
    if (_token == null) return;
    try {
      final r = await http
          .get(_at('/api/account/me'), headers: headers)
          .timeout(_timeout);
      if (r.statusCode == 401) {
        await signOut();
        return;
      }
      if (r.statusCode != 200) return; // a bad day for the site, not for us
      _reader = Reader.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      // Offline. The token is still good; who it belongs to can wait.
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final http.Response r;
    try {
      r = await http
          .post(
            _at(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } catch (_) {
      throw const AccountTrouble(
        'Could not reach shrutivtuber.com. Check your connection.',
      );
    }
    final decoded = r.body.isEmpty ? {} : jsonDecode(r.body);
    final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    if (r.statusCode >= 400) {
      // The site's own words where it gives them — it says the useful thing,
      // like which consent is missing.
      throw AccountTrouble(
        _detail(map) ?? 'That did not work (${r.statusCode}).',
      );
    }
    return map;
  }

  static String? _detail(Map<String, dynamic> body) {
    final d = body['detail'];
    if (d is String && d.trim().isNotEmpty) return d;
    // FastAPI's validation errors arrive as a list of objects.
    if (d is List && d.isNotEmpty) {
      final first = d.first;
      if (first is Map && first['msg'] is String) return first['msg'] as String;
    }
    return null;
  }

  Future<void> _keep(String token) async {
    _token = token;
    await _prefs.setString(_tokenKey, token);
    notifyListeners();
  }
}

enum SignUpOutcome {
  /// Account made, and this device is signed in.
  signedIn,

  /// The site would not say — either the address already has an account or it
  /// is turned away. It sends an email; we say so and nothing more.
  checkEmail,
}
