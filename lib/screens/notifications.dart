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
import '../widgets/parts.dart';
import '../widgets/forms.dart';
import '../widgets/eyebrow.dart';
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
      appBar: const Bar(title: 'Notifications', hour: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Gap.gutter,
            Gap.gutter,
            Gap.gutter,
            Gap.huge,
          ),
          children: [
            const Eyebrow('Tell me about'),
            const SizedBox(height: Gap.sm),
            Pressable(
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              child: Column(
                children: [
                  Switcher(
                    label: 'Send notifications to this phone',
                    description: wanted.on
                        ? 'This phone is on the list.'
                        : 'Off. Nothing is sent and no token is held.',
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
                  ),
                  for (final n in notices) ...[
                    const Divider(height: 1),
                    Switcher(
                      label: n.label,
                      // ⚠ Dimmed rather than hidden. Seeing that replies exist
                      // is the reason somebody would make an account for them;
                      // a control that vanishes teaches nobody anything.
                      description: n.needsAccount && !signedIn
                          ? '${n.about} Needs an account.'
                          : n.about,
                      value: wanted.wants(n.key),
                      enabled: !(n.needsAccount && !signedIn),
                      onChanged: (v) => wanted.setWants(n.key, v),
                    ),
                  ],
                ],
              ),
            ),

            if (_trouble != null) ...[
              const SizedBox(height: Gap.md),
              NoticeBar(tone: BannerTone.warning, text: _trouble!),
            ],

            const SizedBox(height: Gap.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Gap.xs),
              child: Text(
                'Nothing here is needed to use the app — every instrument '
                'computes on this phone, signed out and offline. The sky '
                'notifications are worked out here too, so they still arrive '
                'with no network. Turning this off takes the phone off the '
                'list at her end as well, not just here.',
                style: TextStyle(
                  fontFamily: Face.body,
                  fontSize: Type.caption,
                  height: 1.6,
                  color: Tone.faint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
