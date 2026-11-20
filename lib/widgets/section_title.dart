import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final bool centered;

  const SectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Color(0xFF0175C2),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );

    return child;
  }
}
