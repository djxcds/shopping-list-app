import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class ShoppingListItem extends StatelessWidget {
  const ShoppingListItem({super.key, required this.groceryItem});

  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: groceryItem.category.color,
                border: Border.all(color: Colors.black, width: 1),
                shape: BoxShape.circle),
          ),
        ),
        Text(groceryItem.name),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            '${groceryItem.quantity}',
            textAlign: TextAlign.start,
          ),
        )
      ],
    );
  }
}
