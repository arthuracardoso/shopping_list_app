import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_model.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryModel> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryModel>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }
    // Para que a UI seja atualizada com o novo item
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
      body: _groceryItems.isEmpty
          ? const Center(
              child: Text('Click on (+) button to add a new item'),
            )
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (context, index) => Dismissible(
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _groceryItems.remove(_groceryItems[index]);
                },
                key: ValueKey(_groceryItems[index].id),
                child: ListTile(
                  leading: Container(
                    color: _groceryItems[index].category.color,
                    width: 20,
                    height: 20,
                  ),
                  title: Text(_groceryItems[index].name),
                  subtitle: const Text('Swipe to the left to remove the item', style: TextStyle(fontSize: 12),),
                  trailing: Text(_groceryItems[index].quantity.toString(), style: const TextStyle(fontSize: 14),),
                ),
              ),
            ),
    );
  }
}
