import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category_model.dart';
import 'package:shopping_list_app/models/grocery_model.dart';

final groceryItems = [
  GroceryModel(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryModel(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryModel(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
];