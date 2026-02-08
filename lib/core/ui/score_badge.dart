import 'package:flutter/material.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({super.key, required this.qs});

  final int qs;

  @override
  Widget build(BuildContext context) {
    final bg = qs < 60
        ? Colors.red.shade100
        : (qs < 80 ? Colors.orange.shade100 : Colors.green.shade100);
    final fg = qs < 60
        ? Colors.red.shade800
        : (qs < 80 ? Colors.orange.shade800 : Colors.green.shade800);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'QS $qs',
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
