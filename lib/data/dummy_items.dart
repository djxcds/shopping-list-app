import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/data/categories.dart';

List<GroceryItem> groceryItemList = [
  GroceryItem(
      name: 'Milk', quantity: 1, category: categories[Categories.dairy]!),
  GroceryItem(
      name: 'Bananas', quantity: 5, category: categories[Categories.fruit]!),
  GroceryItem(
      name: 'Beef Steak', quantity: 1, category: categories[Categories.meat]!),
];
