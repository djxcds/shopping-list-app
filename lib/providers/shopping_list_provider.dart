import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class ShoppingListNotifier extends StateNotifier<List<GroceryItem>> {
  ShoppingListNotifier() : super([]);

  final String url =
      'flutter-prep-5b04f-default-rtdb.asia-southeast1.firebasedatabase.app';

  addNewItem(GroceryItem item) async {
    try {
      await http.post(
        Uri.https(url, 'shopping-list.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': item.name,
          'quantity': item.quantity,
          'category': item.category.category,
        }),
      );
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  removeDismissedItem(GroceryItem item) async {
    try {
      final response =
          await http.delete(Uri.https(url, 'shopping-list/${item.id}.json'));
      if (response.statusCode >= 400) {
        throw Exception();
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  getItems() async {
    try {
      final response = await http.get(Uri.https(url, 'shopping-list.json'));
      final List<GroceryItem> items = [];
      final categoriesMap = categories.entries;

      if (response.body == 'null') {
        state = items;
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      for (var element in listData.entries) {
        final String formattedCategory =
            element.value['category'].toLowerCase();
        items.add(GroceryItem(
            id: element.key,
            name: element.value['name'],
            quantity: element.value['quantity'],
            category: categoriesMap
                .firstWhere(
                    (category) => formattedCategory == category.key.name)
                .value));
      }
      state = items;
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<GroceryItem>>(
        (ref) => ShoppingListNotifier());
