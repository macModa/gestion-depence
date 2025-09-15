import 'package:flutter/material.dart';
import '../models/category.dart';

const List<Category> appCategories = [
  Category(name: 'Alimentation', icon: Icons.fastfood),
  Category(name: 'Transport', icon: Icons.directions_car),
  Category(name: 'Logement', icon: Icons.home),
  Category(name: 'Loisirs', icon: Icons.sports_esports),
  Category(name: 'Santé', icon: Icons.local_hospital),
  Category(name: 'Factures', icon: Icons.receipt),
  Category(name: 'Salaire', icon: Icons.attach_money),
  Category(name: 'Autre', icon: Icons.category),
];

/// Finds the icon for a given category name.
/// Returns the 'Autre' category icon if not found.
IconData getIconForCategory(String categoryName) {
  return appCategories
      .firstWhere((cat) => cat.name == categoryName,
          orElse: () => appCategories.firstWhere((c) => c.name == 'Autre'))
      .icon;
}