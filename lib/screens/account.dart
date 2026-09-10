// SPDX-License-Identifier: AGPL-3.0-only
//
// Signing up and signing in, on the phone.
//
// She asked that somebody be able to make a site account here rather than being
// sent to the website — "so we can make it easier" — and that the account then
// work in both places. It does: the same signed session, held as a token here
// and as a cookie there.
//
// ⚠ **The three consents are three decisions.** They are fetched from the site
// so the words shown are the words filed, and only the contract one may be
// required — a special-category consent that blocked the button would not be
// freely given, and consent that is not freely given is not consent. The screen
// takes that from the server's `required` flag rather than deciding for itself.
import 'package:flutter/material.dart';

import '../services/account.dart';
import '../theme/glyph.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/site.dart';
import '../theme/tokens.dart';
import '../widgets/parts.dart';
import '../widgets/forms.dart';
import '../widgets/brand.dart';
import '../widgets/eyebrow.dart';

/// The account, offered down the tree the way settings are.
class AccountScope extends InheritedNotifier<Account> {
  const AccountScope({
    super.key,
    required Account super.notifier,
    required super.child,
  });

  static Account of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AccountScope>()!.notifier!;
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  bool _makingOne = false;
  bool _busy = false;
  String? _trouble;
  String? _said;

  List<Consent>? _consents;
  final Map<String, bool> _granted = {};

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _loadConsents(Account account) async {
    if (_consents != null) return;
    try {
      final got = await account.consents();
      if (!mounted) return;
      setState(() {
        _consents = got;
        for (final c in got) {
          // Required ones start ticked because they are the thing being asked
          // for; the optional ones start UNTICKED. A pre-ticked box is not a
          // decision somebody made.
          _granted[c.kind] = c.required;
        }
      });
    } on AccountTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    }
  }

  /// For somebody who forgot their password — or never had one, because the
  /// website lets an account be made with a magic link and nothing else. That
  /// person could otherwise never sign in HERE, since a phone has nowhere for
  /// a magic link to land.
  Future<void> _emailAPassword(Account account) async {
    if (_email.text.trim().isEmpty) {
      setState(() => _trouble = 'Put your email address in first.');
      return;
    }
    setState(() {
      _busy = true;
      _trouble = null;
      _said = null;
    });
    try {
      await account.requestPassword(_email.text);
      if (mounted) {
        setState(
          () => _said =
              'Check your email. If that address has an account, a link to set a '
              'password is on its way. It works once and lasts twenty minutes.',
        );
      }
    } on AccountTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _go(Account account) async {
    setState(() {
      _busy = true;
      _trouble = null;
      _said = null;
    });
    try {
      if (_makingOne) {
        final how = await account.signUp(
          email: _email.text,
          password: _password.text,
          name: _name.text,
          granted: _granted,
        );
        if (how == SignUpOutcome.checkEmail && mounted) {
          setState(
            () => _said =
                'Check your email. If that address can have an account, one is '
                'waiting there.',
          );
        }
      } else {
        await account.signIn(email: _email.text, password: _password.text);
      }
      if (mounted) _password.clear();
    } on AccountTrouble catch (e) {
      if (mounted) setState(() => _trouble = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = AccountScope.of(context);
    if (account.signedIn) return _SignedIn(account: account);
    if (_makingOne) _loadConsents(account);

    return Scaffold(
      appBar: Bar(
        title: 'Account',
        hour: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.gutter,
          Gap.gutter,
          Gap.gutter,
          Gap.huge,
        ),
        children: [
          const SizedBox(height: Gap.sm),
          Text(
            'An account is only for the practice room',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: Gap.sm),
          const Text(
            'Everything else — the sky, the hours, the chart, the letters — '
            'works without one, offline, and always will. It is the same '
            'account as shrutivtuber.com.',
            style: TextStyle(
              fontFamily: Face.body,
              fontFamilyFallback: [Face.glyph],
              fontSize: Type.body,
              height: 1.5,
              color: Tone.soft,
            ),
          ),
          const SizedBox(height: Gap.xl),

          if (_makingOne) ...[
            Field(
              label: 'Name',
              controller: _name,
              helper: 'What she calls you. Anything you like.',
            ),
            const SizedBox(height: 14),
          ],
          Field(label: 'Email', controller: _email, hint: 'you@example.com'),
          const SizedBox(height: 14),
          Field(
            label: 'Password',
            controller: _password,
            helper: _makingOne ? 'Ten characters or more.' : null,
          ),

          if (_makingOne) ...[
            const SizedBox(height: Gap.xl),
            const Eyebrow('Three decisions'),
            const SizedBox(height: Gap.sm),
            const Text(
              // ⚠ Separate rows, never one bundled tick. A consent that comes
              // packaged with two others is not a consent anybody gave.
              'These are separate on purpose. You can say yes to one and no to '
              'another, and change any of them later.',
              style: TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1.5,
                color: Tone.faint,
              ),
            ),
            const SizedBox(height: Gap.sm),
            if (_consents == null)
              const Skeleton(height: 150)
            else
              for (final c in _consents!)
                ChoiceRow(
                  radio: false,
                  label: c.label,
                  rule: c.wording.isEmpty ? c.explanation : c.wording,
                  checked: _granted[c.kind] ?? false,
                  onChanged: (v) => setState(() => _granted[c.kind] = v),
                ),
          ],

          if (_trouble != null) ...[
            const SizedBox(height: Gap.lg),
            NoticeBar(tone: BannerTone.warning, text: _trouble!),
          ],
          if (_said != null) ...[
            const SizedBox(height: Gap.lg),
            NoticeBar(tone: BannerTone.note, text: _said!),
          ],

          const SizedBox(height: Gap.xl),
          Push(
            label: _busy
                ? 'One moment…'
                : _makingOne
                ? 'Make the account'
                : 'Sign in',
            size: Bulk.lg,
            full: true,
            loading: _busy,
            onTap: _busy ? null : () => _go(account),
          ),
          if (!_makingOne) ...[
            const SizedBox(height: Gap.sm),
            Push(
              label: 'Email me a link to set a password',
              weight: Weight.text,
              full: true,
              onTap: _busy ? null : () => _emailAPassword(account),
            ),
          ],
          const SizedBox(height: Gap.xs),
          Push(
            label: _makingOne
                ? 'I already have an account'
                : 'I need an account',
            weight: Weight.text,
            full: true,
            onTap: _busy
                ? null
                : () => setState(() {
                    _makingOne = !_makingOne;
                    _trouble = null;
                    _said = null;
                  }),
          ),
        ],
      ),
    );
  }
}

/// The account, once there is one.
///
/// ⚠ Sign out and delete are the same shape of row and they are NOT the same
/// decision, so delete wears the danger colour and goes behind a dialog that
/// says what it takes with it. Nothing irreversible gets a filled button.
class _SignedIn extends StatelessWidget {
  const _SignedIn({required this.account});
  final Account account;

  @override
  Widget build(BuildContext context) {
    final reader = account.reader;
    return Scaffold(
      appBar: Bar(
        title: 'Account',
        hour: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Gap.gutter,
          Gap.gutter,
          Gap.gutter,
          Gap.huge,
        ),
        children: [
          Pressable(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Tone.veil,
                    shape: BoxShape.circle,
                    border: Border.all(color: Tone.line),
                  ),
                  child: const Glyph('☾', size: 22, color: Gilt.gilt),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reader?.shownName ?? 'Signed in',
                        style: const TextStyle(
                          fontFamily: Face.display,
                          fontFamilyFallback: [Face.glyph],
                          fontSize: 18,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: Tone.ink,
                        ),
                      ),
                      if (reader != null && reader.email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          reader.email,
                          style: const TextStyle(
                            fontFamily: Face.body,
                            fontFamilyFallback: [Face.glyph],
                            fontSize: Type.caption,
                            color: Tone.faint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.md),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Gap.xs),
            child: Text(
              'The same account works on shrutivtuber.com — signed in there '
              'too, with nothing more to do.',
              style: TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1.5,
                color: Tone.faint,
              ),
            ),
          ),

          const SizedBox(height: Gap.xl),
          const Eyebrow('Consents'),
          const SizedBox(height: Gap.sm),
          ListGroup(
            children: [
              ListRow(
                label: 'What you agreed to',
                description: 'Change any of them, at any time',
                onTap: () => launchUrl(
                  Uri.parse('$siteOrigin/account'),
                  mode: LaunchMode.externalApplication,
                ),
                external: true,
              ),
            ],
          ),

          const SizedBox(height: Gap.xl),
          ListGroup(
            children: [
              ListRow(
                label: 'Sign out of this device',
                onTap: account.signOut,
                trailing: const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: Gap.sm),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Gap.xs),
            child: Text(
              'Signing out here does not sign you out on the website, and '
              'nothing you have saved is deleted.',
              style: TextStyle(
                fontFamily: Face.body,
                fontFamilyFallback: [Face.glyph],
                fontSize: Type.caption,
                height: 1.5,
                color: Tone.faint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
