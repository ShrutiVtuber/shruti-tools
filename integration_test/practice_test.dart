// SPDX-License-Identifier: AGPL-3.0-only
//
// The practice room, end to end.
//
// The claims worth testing are the ones that would look fine while being wrong:
// that a week's twelve signs stay ONE piece of work, that a draft written here
// is the same draft the website's desk holds, and that a vote is one vote
// however many times somebody taps it.
//
// ⚠ Local stack only. `adb reverse tcp:8200 tcp:8200` and
// --dart-define=SHRUTI_SITE=http://127.0.0.1:8200. Against the real site this
// would post junk into her practice room.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shruti_tools/services/account.dart';
import 'package:shruti_tools/services/practice.dart';
import 'package:shruti_tools/services/site.dart' show siteOrigin;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    expect(
      siteOrigin.contains('127.0.0.1') || siteOrigin.contains('localhost'),
      isTrue,
      reason: 'refusing to post practice readings to $siteOrigin',
    );
  });

  String freshEmail() =>
      'practice-${DateTime.now().microsecondsSinceEpoch}@example.com';

  /// A signed-in account, and the room seen through it.
  Future<(Account, Practice)> somebody(String name) async {
    SharedPreferences.setMockInitialValues({});
    final account = await Account.load();
    await account.signUp(
      email: freshEmail(),
      password: 'a-long-enough-password',
      name: name,
      granted: const {'account': true},
    );
    expect(account.signedIn, isTrue, reason: 'could not make $name an account');
    return (account, Practice(account));
  }

  testWidgets('a week of signs is one piece of work', (tester) async {
    final (_, room) = await somebody('Writes A Week');
    final covers = 'test-${DateTime.now().microsecondsSinceEpoch}';

    for (final sign in ['aries', 'taurus', 'gemini']) {
      await room.keep(
        period: 'weekly',
        covers: covers,
        sign: sign,
        bodyMd: 'A reading for $sign.',
        title: 'A test week',
      );
    }
    final mine = await room.mine();
    expect(
      mine,
      hasLength(1),
      reason:
          'three signs became ${mine.length} works — a week is one piece '
          'of work, not one per sign',
    );
    expect(mine.first.series, isTrue);
    expect(mine.first.signs, ['aries', 'taurus', 'gemini']);
    expect(mine.first.isDraft, isTrue);
  });

  testWidgets('a blank sign is not submitted', (tester) async {
    // Somebody who opened all twelve and wrote two is submitting two. Shipping
    // ten blanks would waste every reader's time.
    final (_, room) = await somebody('Leaves Blanks');
    final covers = 'test-${DateTime.now().microsecondsSinceEpoch}';
    await room.keep(
      period: 'weekly',
      covers: covers,
      sign: 'leo',
      bodyMd: 'Leo has something to say.',
    );
    await room.keep(
      period: 'weekly',
      covers: covers,
      sign: 'virgo',
      bodyMd: '   ',
    );

    final id = (await room.mine()).first.id;
    await room.submit(id);

    final work = await room.read(id);
    expect(work.signs, ['leo']);
    expect(work.readings, hasLength(1));
  });

  testWidgets('a draft here is the draft the website holds', (tester) async {
    // Her whole point about one reading in three places. The app and the desk
    // write to the same work, so a reading started on a train can be finished
    // at a desk.
    final (_, room) = await somebody('Two Places');
    final covers = 'test-${DateTime.now().microsecondsSinceEpoch}';
    await room.keep(
      period: 'weekly',
      covers: covers,
      sign: 'libra',
      bodyMd: 'Started on the phone.',
    );
    expect(
      await room.draft(period: 'weekly', covers: covers, sign: 'libra'),
      'Started on the phone.',
    );

    await room.keep(
      period: 'weekly',
      covers: covers,
      sign: 'libra',
      bodyMd: 'Started on the phone. Finished at a desk.',
    );
    expect(
      await room.draft(period: 'weekly', covers: covers, sign: 'libra'),
      'Started on the phone. Finished at a desk.',
    );
    expect(await room.mine(), hasLength(1), reason: 'a second draft appeared');
  });

  testWidgets('a vote is one vote, and can be taken back', (tester) async {
    final (_, writer) = await somebody('Wrote It');
    final covers = 'test-${DateTime.now().microsecondsSinceEpoch}';
    await writer.keep(
      period: 'weekly',
      covers: covers,
      sign: 'scorpio',
      bodyMd: 'Something to vote on.',
    );
    final id = (await writer.mine()).first.id;
    await writer.submit(id);

    final (_, reader) = await somebody('Read It');
    expect((await reader.vote(id)).votes, 1);
    // Twice is not two votes; it is taking it back.
    expect((await reader.vote(id)).votes, 0);
    expect((await reader.vote(id)).votes, 1);

    // And the author cannot vote for their own.
    await expectLater(writer.vote(id), throwsA(isA<PracticeTrouble>()));
    expect((await reader.read(id)).votes, 1);
  });

  testWidgets('somebody says what they think, and it is there', (tester) async {
    final (_, writer) = await somebody('Wrote Again');
    final covers = 'test-${DateTime.now().microsecondsSinceEpoch}';
    await writer.keep(
      period: 'weekly',
      covers: covers,
      sign: 'pisces',
      bodyMd: 'Pisces: the tide is not the sea.',
    );
    final id = (await writer.mine()).first.id;
    await writer.submit(id);

    final (_, reader) = await somebody('Had Thoughts');
    await reader.say(id, 'The image lands. The second half explains it away.');

    final work = await reader.read(id);
    expect(work.comments, hasLength(1));
    expect(work.comments.first.author, 'Had Thoughts');
    expect(work.comments.first.mine, isTrue);
  });

  testWidgets('reading needs no account; posting says so', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final nobody = Practice(await Account.load());
    // The feed loads for anybody — that is the point of a practice room.
    await nobody.feed();
    await expectLater(nobody.mine(), throwsA(isA<PracticeTrouble>()));
    await expectLater(
      nobody.keep(period: 'weekly', covers: 'x', sign: 'aries', bodyMd: 'hi'),
      throwsA(isA<PracticeTrouble>()),
    );
  });

  testWidgets('the top of the feed is what she reads from', (tester) async {
    final (_, a) = await somebody('Quiet One');
    final (_, b) = await somebody('Popular One');
    final covers = 'test-${DateTime.now().microsecondsSinceEpoch}';

    await a.keep(
      period: 'weekly',
      covers: covers,
      sign: 'aries',
      bodyMd: 'Few will vote for this.',
    );
    final quiet = (await a.mine()).first.id;
    await a.submit(quiet);

    await b.keep(
      period: 'weekly',
      covers: covers,
      sign: 'aries',
      bodyMd: 'This one gets the votes.',
    );
    final popular = (await b.mine()).first.id;
    await b.submit(popular);

    await a.vote(popular);

    final top = await a.feed(sort: 'top');
    expect(
      top.first.id,
      popular,
      reason:
          'the most-voted work is not at the top of sort=top, which is '
          'the list she picks readings from',
    );
  });
}
