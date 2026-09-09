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
import '../theme/tokens.dart';
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
      children: [
        Text(
          _makingOne ? 'Make an account' : 'Sign in',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: Gap.xs),
        const Text(
          'One account for the app and for shrutivtuber.com. Nothing else here '
          'needs one — every instrument works signed out.',
          style: TextStyle(color: Tone.soft, height: 1.45),
        ),
        const SizedBox(height: Gap.xl),

        if (_makingOne) ...[
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              helperText: 'What she calls you. Anything you like.',
            ),
          ),
          const SizedBox(height: Gap.lg),
        ],
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: Gap.lg),
        TextField(
          controller: _password,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            helperText: _makingOne ? 'Ten characters or more.' : null,
          ),
        ),

        if (_makingOne) ...[
          const SizedBox(height: Gap.xl),
          const Eyebrow('Three decisions'),
          const SizedBox(height: Gap.sm),
          const Text(
            'These are separate on purpose. You can say yes to one and no to '
            'another, and change any of them later.',
            style: TextStyle(color: Tone.faint, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: Gap.sm),
          if (_consents == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Gap.lg),
              child: Text(
                'Fetching what you are agreeing to…',
                style: TextStyle(color: Tone.faint),
              ),
            )
          else
            for (final c in _consents!)
              _ConsentTile(
                consent: c,
                granted: _granted[c.kind] ?? false,
                onChanged: (v) => setState(() => _granted[c.kind] = v),
              ),
        ],

        if (_trouble != null) ...[
          const SizedBox(height: Gap.lg),
          Text(
            _trouble!,
            style: const TextStyle(color: Tone.live, height: 1.45),
          ),
        ],
        if (_said != null) ...[
          const SizedBox(height: Gap.lg),
          Text(
            _said!,
            style: const TextStyle(color: Tone.accent, height: 1.45),
          ),
        ],

        const SizedBox(height: Gap.xl),
        FilledButton(
          onPressed: _busy ? null : () => _go(account),
          child: Text(
            _busy
                ? 'One moment…'
                : _makingOne
                ? 'Make the account'
                : 'Sign in',
          ),
        ),
        if (!_makingOne) ...[
          const SizedBox(height: Gap.sm),
          TextButton(
            onPressed: _busy ? null : () => _emailAPassword(account),
            child: const Text('Email me a link to set a password'),
          ),
        ],
        const SizedBox(height: Gap.md),
        TextButton(
          onPressed: _busy
              ? null
              : () => setState(() {
                  _makingOne = !_makingOne;
                  _trouble = null;
                  _said = null;
                }),
          child: Text(
            _makingOne ? 'I already have an account' : 'I need an account',
          ),
        ),
      ],
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.consent,
    required this.granted,
    required this.onChanged,
  });

  final Consent consent;
  final bool granted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: Gap.sm),
    padding: const EdgeInsets.all(Gap.md),
    decoration: BoxDecoration(
      color: Tone.inset,
      borderRadius: BorderRadius.circular(Corner.md),
      border: Border.all(color: Tone.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: granted,
              // A required consent is the thing being asked for; it cannot
              // be turned off and still make an account. The others are
              // free, which is what makes them consent.
              onChanged: consent.required ? null : (v) => onChanged(v ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: Gap.md),
                child: Text(
                  consent.label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            if (consent.required)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Text(
                  'needed',
                  style: TextStyle(color: Tone.faint, fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: Gap.xs),
        // The filed words, verbatim. This is the record.
        Text(
          consent.wording,
          style: const TextStyle(color: Tone.soft, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: Gap.xs),
        Text(
          consent.explanation,
          style: const TextStyle(color: Tone.faint, fontSize: 12, height: 1.5),
        ),
      ],
    ),
  );
}

class _SignedIn extends StatelessWidget {
  const _SignedIn({required this.account});
  final Account account;

  @override
  Widget build(BuildContext context) {
    final reader = account.reader;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.xl, Gap.lg, Gap.huge),
      children: [
        Text('Your account', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: Gap.xl),
        Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            color: Tone.card,
            borderRadius: BorderRadius.circular(Corner.md),
            border: Border.all(color: Tone.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reader?.shownName ?? 'Signed in',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (reader != null && reader.name.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  reader.email,
                  style: const TextStyle(color: Tone.faint, fontSize: 13),
                ),
              ],
              const SizedBox(height: Gap.sm),
              const Text(
                'The same account works on shrutivtuber.com — signed in there '
                'too, with nothing more to do.',
                style: TextStyle(color: Tone.soft, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.xl),
        OutlinedButton(
          onPressed: account.signOut,
          child: const Text('Sign out of this device'),
        ),
        const SizedBox(height: Gap.sm),
        const Text(
          'Signing out here does not sign you out on the website, and nothing '
          'you have saved is deleted.',
          style: TextStyle(color: Tone.faint, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}
