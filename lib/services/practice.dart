// SPDX-License-Identifier: AGPL-3.0-only
//
// Horoscope practice: what people write, and what others make of it.
//
// Somewhere to put a reading in front of other people and be told what they
// think. Her purpose: so people can "get feedback on their interpretations,
// learn and grow as horoscope writers", and so she can pick the highest-voted
// ones to read on stream.
//
// ⚠ **A WORK is the unit, not a reading.** Twelve signs for a week is ONE piece
// of work — her words, "submitted, read and voted on as one" — and a single
// reading is a work that happens to hold one. Nothing here treats them as two
// different kinds of thing.
//
// ⚠ **Reading needs no account. Posting does.** Her decision, taken for
// identity, banning and traceability. The feed loads for anybody; every screen
// that writes checks first and says so rather than failing at the server.
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'account.dart';
import 'site.dart' show siteOrigin;

const _timeout = Duration(seconds: 15);

/// One piece of work in the feed.
class Work {
  const Work({
    required this.id,
    required this.author,
    required this.period,
    required this.covers,
    required this.title,
    required this.series,
    required this.signs,
    required this.votes,
    required this.voted,
    required this.mine,
    required this.opening,
    required this.submittedAt,
    this.readings = const [],
    this.comments = const [],
  });

  factory Work.fromJson(Map<String, dynamic> j) => Work(
    id: j['id'] as int,
    author: j['author'] as String? ?? 'somebody',
    period: j['period'] as String? ?? 'weekly',
    covers: j['covers'] as String? ?? '',
    title: j['title'] as String? ?? '',
    series: j['series'] as bool? ?? false,
    signs: [for (final s in (j['signs'] as List? ?? [])) s as String],
    votes: j['votes'] as int? ?? 0,
    voted: j['voted'] as bool? ?? false,
    mine: j['mine'] as bool? ?? false,
    opening: j['opening'] as String? ?? '',
    submittedAt: j['submittedAt'] as String?,
    readings: [
      for (final r in (j['readings'] as List? ?? []))
        Reading.fromJson(r as Map<String, dynamic>),
    ],
    comments: [
      for (final c in (j['comments'] as List? ?? []))
        Remark.fromJson(c as Map<String, dynamic>),
    ],
  );

  final int id;
  final String author;
  final String period;
  final String covers;
  final String title;

  /// More than one sign. A fact about the work, not a separate kind.
  final bool series;
  final List<String> signs;
  final int votes;
  final bool voted;
  final bool mine;
  final String opening;
  final String? submittedAt;
  final List<Reading> readings;
  final List<Remark> comments;

  bool get isDraft => submittedAt == null;

  /// What to call it when the writer named nothing.
  String get shownTitle {
    if (title.trim().isNotEmpty) return title.trim();
    if (signs.length == 1) return '${_Titled(signs.first).name}, $covers';
    return '${signs.length} signs, $covers';
  }
}

class Reading {
  const Reading({required this.sign, required this.bodyMd});

  factory Reading.fromJson(Map<String, dynamic> j) => Reading(
    sign: j['sign'] as String? ?? '',
    bodyMd: j['bodyMd'] as String? ?? '',
  );

  final String sign;
  final String bodyMd;

  String get signName => _Titled(sign).name;
}

class Remark {
  const Remark({
    required this.id,
    required this.author,
    required this.bodyMd,
    required this.at,
    required this.mine,
  });

  factory Remark.fromJson(Map<String, dynamic> j) => Remark(
    id: j['id'] as int,
    author: j['author'] as String? ?? 'somebody',
    bodyMd: j['bodyMd'] as String? ?? '',
    at: j['at'] as String?,
    mine: j['mine'] as bool? ?? false,
  );

  final int id;
  final String author;
  final String bodyMd;
  final String? at;
  final bool mine;
}

extension _Titled on String {
  String get name => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}

/// What went wrong, in words worth showing somebody.
class PracticeTrouble implements Exception {
  const PracticeTrouble(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The practice room.
///
/// Takes the [Account] rather than a token, so a screen never has to remember
/// to attach one and signing out takes effect everywhere at once.
class Practice {
  const Practice(this.account);
  final Account account;

  Uri _at(String path) => Uri.parse('$siteOrigin$path');

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final http.Response r;
    try {
      final request = http.Request(method, _at(path))
        ..headers.addAll({
          ...account.headers,
          if (body != null) 'Content-Type': 'application/json',
        });
      if (body != null) request.body = jsonEncode(body);
      r = await http.Response.fromStream(
        await request.send(),
      ).timeout(_timeout);
    } catch (_) {
      throw const PracticeTrouble(
        'Could not reach shrutivtuber.com. Check your connection.',
      );
    }
    final decoded = r.body.isEmpty ? null : jsonDecode(r.body);
    if (r.statusCode == 401) {
      throw const PracticeTrouble('Sign in first — reading needs no account.');
    }
    if (r.statusCode == 404 && !path.contains('/practice/')) {
      // ⚠ The whole room is missing, not one work. The app updates through an
      // APK and the site through a deploy, so this phone can be NEWER than
      // shrutivtuber.com — worth saying plainly rather than showing somebody
      // FastAPI's word for it.
      throw const PracticeTrouble(
        'The practice room is not on shrutivtuber.com yet. This app is ahead of '
        'the site; it will appear on its own.',
      );
    }
    if (r.statusCode >= 400) {
      final detail = decoded is Map ? decoded['detail'] : null;
      throw PracticeTrouble(
        detail is String ? detail : 'That did not work (${r.statusCode}).',
      );
    }
    return decoded;
  }

  /// What has been submitted. `top` is what she reads from.
  Future<List<Work>> feed({String sort = 'recent', String period = ''}) async {
    final query = [
      'sort=$sort',
      if (period.isNotEmpty) 'period=$period',
    ].join('&');
    final body = await _send('GET', '/api/practice?$query');
    return [
      for (final w in (body as List? ?? []))
        Work.fromJson(w as Map<String, dynamic>),
    ];
  }

  /// One work, with its readings and everything said about it.
  Future<Work> read(int id) async => Work.fromJson(
    await _send('GET', '/api/practice/$id') as Map<String, dynamic>,
  );

  /// Everything this account has written, drafts first.
  Future<List<Work>> mine() async {
    final body = await _send('GET', '/api/practice/mine');
    return [
      for (final w in (body as List? ?? []))
        Work.fromJson(w as Map<String, dynamic>),
    ];
  }

  /// What the account holds for one sign of one period.
  Future<String> draft({
    required String period,
    required String covers,
    required String sign,
  }) async {
    final body = await _send(
      'GET',
      '/api/practice/draft?period=$period&covers=$covers&sign=$sign',
    );
    return (body as Map<String, dynamic>)['bodyMd'] as String? ?? '';
  }

  /// Keep what is being written. Same draft as the website's desk.
  Future<int> keep({
    required String period,
    required String covers,
    required String sign,
    required String bodyMd,
    String title = '',
  }) async {
    final body = await _send('PUT', '/api/practice/draft', {
      'period': period,
      'covers': covers,
      'sign': sign,
      'body_md': bodyMd,
      'title': title,
    });
    return (body as Map<String, dynamic>)['workId'] as int;
  }

  /// Put it in front of other people.
  Future<void> submit(int workId) async =>
      _send('POST', '/api/practice/$workId/submit');

  /// Vote, or take the vote back. Returns the new count and whether it is mine.
  Future<({int votes, bool voted})> vote(int workId) async {
    final body =
        await _send('POST', '/api/practice/$workId/vote')
            as Map<String, dynamic>;
    return (votes: body['votes'] as int, voted: body['voted'] as bool);
  }

  Future<void> say(int workId, String what) async =>
      _send('POST', '/api/practice/$workId/comments', {'body_md': what});

  Future<void> unsay(int commentId) async =>
      _send('DELETE', '/api/practice/comments/$commentId');
}
