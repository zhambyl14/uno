import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/ui_feedback.dart';
import '../../domain/mission.dart';
import '../missions_controller.dart';

class MissionsCard extends ConsumerWidget {
  const MissionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionsControllerProvider);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Insets.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 20)),
                const SizedBox(width: Insets.s),
                Text(S.missionsTitle, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: Insets.s),
            for (var i = 0; i < Missions.daily.length; i++)
              _MissionRow(
                def: Missions.daily[i],
                progress: state.entries[i],
                complete: state.isComplete(i),
                onClaim: () async {
                  await ref.read(missionsControllerProvider.notifier).claim(i);
                  if (context.mounted) {
                    context.showSnack(
                      S.missionReward(Missions.daily[i].reward),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.def,
    required this.progress,
    required this.complete,
    required this.onClaim,
  });
  final MissionDef def;
  final MissionProgress progress;
  final bool complete;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (progress.progress / def.target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.s),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(def.title, overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      '${progress.progress}/${def.target}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: Insets.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Corners.s),
                  child: LinearProgressIndicator(value: ratio, minHeight: 6),
                ),
              ],
            ),
          ),
          const SizedBox(width: Insets.m),
          _ClaimButton(
            reward: def.reward,
            claimed: progress.claimed,
            enabled: complete && !progress.claimed,
            onClaim: onClaim,
          ),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.reward,
    required this.claimed,
    required this.enabled,
    required this.onClaim,
  });
  final int reward;
  final bool claimed;
  final bool enabled;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    if (claimed) {
      return const Icon(Icons.check_circle_rounded, color: Colors.green);
    }
    return FilledButton.tonal(
      onPressed: enabled ? onClaim : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: Insets.m),
        minimumSize: const Size(0, 40),
      ),
      child: Text('🪙 $reward'),
    );
  }
}
