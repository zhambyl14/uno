import 'dart:async';

import 'package:flutter/material.dart';

/// Countdown ring for the active turn. Disposes its ticker cleanly.
class TurnTimer extends StatefulWidget {
  const TurnTimer({
    super.key,
    required this.endsAt,
    required this.totalSeconds,
    this.size = 40,
  });

  final DateTime endsAt;
  final int totalSeconds;
  final double size;

  @override
  State<TurnTimer> createState() => _TurnTimerState();
}

class _TurnTimerState extends State<TurnTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.endsAt.difference(DateTime.now()).inMilliseconds;
    final secondsLeft = (remaining / 1000).ceil().clamp(0, widget.totalSeconds);
    final fraction = (remaining / (widget.totalSeconds * 1000)).clamp(0.0, 1.0);
    final scheme = Theme.of(context).colorScheme;
    final danger = secondsLeft <= 5;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: fraction,
            strokeWidth: 4,
            color: danger ? scheme.error : scheme.primary,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
          Text(
            '$secondsLeft',
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: danger ? scheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
