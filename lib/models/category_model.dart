import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}

class CategoryModel {
  const CategoryModel(this.category, this.color);
  final String category;
  final Color color;
}
