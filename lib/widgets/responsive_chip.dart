import 'package:flutter/material.dart';

class ResponsiveChip {
  static Widget wrapFromList(List items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: items.map((e) => Chip(label: Text(e.toString()))).toList(),
    );
  }
}