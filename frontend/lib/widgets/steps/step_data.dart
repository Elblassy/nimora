import 'package:flutter/material.dart';

class CategoryData {
  final String key, label, image;
  final Color color;
  const CategoryData(this.key, this.label, this.image, this.color);
}

class StyleData {
  final String key, label, image;
  final Color color;
  const StyleData(this.key, this.label, this.image, this.color);
}

const categories = [
  CategoryData('forest_journey', 'Forest Journey', 'assets/images/adventure/01_forest_journey.jpg', Color(0xFF4CAF50)),
  CategoryData('space_mission', 'Space Mission', 'assets/images/adventure/02_space_mission.jpg', Color(0xFF7C4DFF)),
  CategoryData('pirate_island', 'Pirate Island', 'assets/images/adventure/03_pirate_island.jpg', Color(0xFFFF7043)),
  CategoryData('dinosaur_world', 'Dinosaur World', 'assets/images/adventure/04_dinosaur_world.jpg', Color(0xFF8D6E63)),
  CategoryData('magic_kingdom', 'Magic Kingdom', 'assets/images/adventure/05_magic_kingdom.jpg', Color(0xFFE040FB)),
  CategoryData('ocean_quest', 'Ocean Quest', 'assets/images/adventure/06_ocean_quest.jpg', Color(0xFF29B6F6)),
  CategoryData('desert_treasure', 'Desert Treasure', 'assets/images/adventure/07_desert_treasure.jpg', Color(0xFFFFB74D)),
  CategoryData('castle_mystery', 'Castle Mystery', 'assets/images/adventure/08_castle_mystery.jpg', Color(0xFF78909C)),
];

const styles = [
  StyleData('watercolor', 'Watercolor', 'assets/images/look/01_watercolor.jpg', Color(0xFF81D4FA)),
  StyleData('digital_painting', 'Digital Painting', 'assets/images/look/02_digital.jpg', Color(0xFFCE93D8)),
  StyleData('clay', 'Clay', 'assets/images/look/03_clay.jpg', Color(0xFFFFCC80)),
  StyleData('3d', '3D', 'assets/images/look/04_3d.jpg', Color(0xFFA5D6A7)),
];

const foxConfig = [
  ['assets/images/nimora_fox/fox_light.png', false],  // 0: welcome — right
  ['assets/images/nimora_fox/fox_earch.png', true],    // 1: upload — left
  ['assets/images/nimora_fox/fox_teach.png', false],   // 2: name — right
  ['assets/images/nimora_fox/fox_study.png', true],    // 3: adventure — left
  ['assets/images/nimora_fox/fox_student.png', false],   // 4: look — right
];
