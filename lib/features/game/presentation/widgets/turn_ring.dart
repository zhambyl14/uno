import 'dart:async';

import 'package:flutter/material.dart';

/// A ring that highlights whose turn it is around their avatar: a live
/// countdown arc when the mode has a turn timer, or a solid glow ring when
/// it doesn't (Family mode has no timer). Mirrors the redesign mockup's
/// glowing turn ring around the active seat.
class TurnRing extends StatefulWidget {
  const TurnRing({
    super.key,
    required this.child,
    required this.active,
    this.endsAt,
    this.totalSeconds,
    this.color = const Color(0xFFFFB020),
    this.size = 52,
  });

  final Widget child;
  final bool active;
  final DateTime? endsAt;
  final int? totalSeconds;
  final Color color;
  final double size;

  @override
  State<TurnRing> createState() => _TurnRingState();
}

class _TurnRingState extends State<TurnRing> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TurnRing old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    _timer?.cancel();
    if (widget.active && widget.endsAt != null) {
      _timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    var fraction = 1.0;
    final endsAt = widget.endsAt;
    final totalSeconds = widget.totalSeconds;
    if (endsAt != null && totalSeconds != null && totalSeconds > 0) {
      final remainingMs = endsAt.difference(DateTime.now()).inMilliseconds;
      fraction = (remainingMs / (totalSeconds * 1000)).clamp(0.0, 1.0);
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 3,
              color: widget.color,
              backgroundColor: widget.color.withValues(alpha: 0.18),
            ),
          ),
          Padding(padding: const EdgeInsets.all(4), child: widget.child),
        ],
      ),
    );
  }
}
