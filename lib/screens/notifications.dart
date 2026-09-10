// SPDX-License-Identifier: AGPL-3.0-only
//
// Choosing what to be told.
//
// ⚠ Every kind is its own switch. "Tell me when a stream starts" and "tell me
// when somebody replied to my reading" are different appetites, and one switch
// for both is how somebody turns all of it off.
import 'package:flutter/material.dart';

import '../services/notifications.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import 'account.dart';

/// The notification preferences, offered down the tree.
class NoticeScope extends InheritedNotifier<Notifications> {
  const NoticeScope({
    super.key,
    required Notifications super.notifier,
    required super.child,
  });

  static Notifications of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NoticeScope>()!.notifier!;
}

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  bool _busy = false;
  String? _trouble;

  @override
  Widget build(BuildContext context) {
    final wanted = NoticeScope.of(context);
    final signedIn = AccountScope.of(context).signedIn;

    return Scaffold(
      appBar: const Bar(title: 'Notifications'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.huge),
          children: [
            const Text(
              'Nothing here is needed to use the app. Every instrument computes '
              'on this phone, signed out and offline.',
              style: TextStyle(color: Tone.soft, height: 1.45),
            ),
            const SizedBox(height: Gap.lg),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: wanted.on,
              onChanged: _busy
                  ? null
                  : (want) async {
                      setState(() {
                        _busy = true;
                        _trouble = null;
                      });
                      String? trouble;
                      if (want) {
                        trouble = await wanted.turnOn();
                      } else {
                        await wanted.turnOff();
                      }
                      if (mounted) {
                        setState(() {
                          _trouble = trouble;
                          _busy = false;
                        });
                      }
                    },
              title: const Text('Send notifications to this phone'),
              subtitle: Text(
                wanted.on
                    ? 'This phone is on the list.'
                    : 'Off. Nothing is sent and no token is held.',
                style: const TextStyle(color: Tone.faint, fontSize: 12),
              ),
            ),

            if (_trouble != null) ...[
              const SizedBox(height: Gap.sm),
              Text(
                _trouble!,
                style: const TextStyle(color: Tone.live, height: 1.45),
              ),
            ],

            const SizedBox(height: Gap.lg),
            for (final n in notices)
              Opacity(
                // Dimmed rather than hidden: seeing that replies exist is why
                // somebody would make an account for them.
                opacity: (n.needsAccount && !signedIn) ? 0.55 : 1,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: wanted.wants(n.key),
                  onChanged: (n.needsAccount && !signedIn)
                      ? null
                      : (v) => wanted.setWants(n.key, v),
                  title: Text(n.label),
                  subtitle: Text(
                    n.needsAccount && !signedIn
                        ? '${n.about} Needs an account.'
                        : n.about,
                    style: const TextStyle(color: Tone.faint, fontSize: 12),
                  ),
                ),
              ),

            const SizedBox(height: Gap.lg),
            const Text(
              'Turning this off takes the phone off the list at her end too, '
              'not just here.',
              style: TextStyle(color: Tone.faint, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
