import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/providers/shopping_list_provider.dart';

class NewItem extends ConsumerStatefulWidget {
  const NewItem({super.key});

  @override
  ConsumerState<NewItem> createState() => _NewItemState();
}

class _NewItemState extends ConsumerState<NewItem>
    with TickerProviderStateMixin {
  late AnimationController controller;
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  Category? _enteredCategory;
  bool isLoading = false;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _saveItem() async {
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        setState(() {
          isLoading = true;
          controller.repeat(reverse: true);
        });
        await ref.read(shoppingListProvider.notifier).addNewItem(
              GroceryItem(
                  name: _enteredName,
                  quantity: _enteredQuantity,
                  category: _enteredCategory!),
            );
        await ref.read(shoppingListProvider.notifier).getItems();
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();
      }
    } on Exception catch (_) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Cannot add item into shopping list at this time.'),
          duration: const Duration(milliseconds: 2500),
          width: 340.0, // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16 // Inner padding for SnackBar content.
              ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
        controller.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: isLoading
            ? const PreferredSize(
                preferredSize: Size(0, 1),
                child: LinearProgressIndicator(
                  value: null,
                  semanticsLabel: 'Linear progress indicator',
                ),
              )
            : null,
        title: const Text('Add new item'),
        actions: [
          ElevatedButton(
            onPressed: isLoading ? null : _saveItem,
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(),
                  )
                : const Text('Submit'),
          )
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: const Text('Discard changes'),
                    content: const Text(
                        'You are about to exit this form, any unsaved data will be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Discard'),
                      )
                    ],
                  ));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                    label: Text('Name'),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters.';
                    }
                    return null;
                  },
                  onSaved: ((newValue) => _enteredName = newValue!),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: _enteredQuantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Must be a non-negative number.';
                          }
                          return null;
                        },
                        onSaved: (value) =>
                            _enteredQuantity = int.parse(value!),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: _enteredCategory,
                          validator: (value) {
                            if (value == null) {
                              return 'Must select a category';
                            }
                            return null;
                          },
                          items: [
                            for (final item in categories.entries)
                              DropdownMenuItem(
                                value: item.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: item.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(item.value.category)
                                  ],
                                ),
                              ),
                          ],
                          onSaved: (value) => _enteredCategory = value!,
                          onChanged: (value) {}),
                    )
                  ],
                ),
                // Row(
                //   children: [
                //     Text(data)
                //   ],
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
