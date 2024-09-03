import 'package:flutter/material.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';
import 'package:shopping_list_app/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Groceries',
      theme: AppTheme.themeData(),
      debugShowCheckedModeBanner: false,
      home: const GroceryList(),
    );
  }
}
