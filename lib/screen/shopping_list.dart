import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/providers/shopping_list_provider.dart';
import 'package:shopping_list/screen/new_item.dart';
import 'package:shopping_list/widgets/shopping_list_item.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListState();
}

class _ShoppingListState extends ConsumerState<ShoppingListScreen> {
  List<GroceryItem> groceryItemList = [];
  bool isLoading = false;

  @override
  initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      await ref.read(shoppingListProvider.notifier).getItems();
    } on Exception catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot retrieve shopping list at this time.'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    groceryItemList = ref.watch(shoppingListProvider);
    Widget activeScreen = Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                  ),
                Text(isLoading ? 'Fetching data' : 'No items to display.')
              ],
            ),
          ),
          if (!isLoading)
            ElevatedButton.icon(
              onPressed: () {
                loadData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            )
        ],
      ),
    );

    if (groceryItemList.isNotEmpty) {
      activeScreen = RefreshIndicator(
        onRefresh: () async {
          await loadData();
        },
        child: ListView.builder(
          itemCount: groceryItemList.length,
          itemBuilder: (ctx, index) => Dismissible(
            key: ValueKey(groceryItemList[index].id),
            child: ShoppingListItem(groceryItem: groceryItemList[index]),
            confirmDismiss: (direction) async {
              try {
                await ref
                    .read(shoppingListProvider.notifier)
                    .removeDismissedItem(groceryItemList[index]);
                return true;
              } on Exception catch (_) {
                if (!context.mounted) {
                  return false;
                }
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Cannot retrieve shopping list entry at this time.'),
                  ),
                );
                return false;
              }
            },
            onDismissed: (direction) async {
              try {
                await ref.read(shoppingListProvider.notifier).getItems();
              } on Exception catch (_) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Cannot delete shopping list entry at this time.'),
                  ),
                );
              }
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const NewItem(),
                  ),
                );
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: activeScreen,
    );
  }
}
