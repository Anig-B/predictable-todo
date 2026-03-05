import 'package:flutter/material.dart';

enum LootRarity { rare, epic, legendary }

extension LootRarityExt on LootRarity {
  String get label => name[0].toUpperCase() + name.substring(1);
}

class LootItemModel {
  final String icon;
  final String name;
  final String desc;
  final LootRarity rarity;
  final Color color;

  const LootItemModel({
    required this.icon,
    required this.name,
    required this.desc,
    required this.rarity,
    required this.color,
  });
}
