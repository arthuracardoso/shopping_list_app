import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_model.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryModel> _groceryItems = [];
  late Future<List<GroceryModel>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryModel>> _loadItems() async {
    final url = Uri.https(
        'flutter-prep-b7f8f-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch data');
    }

    /// Esse "if" serve para que não dê ruim no aplicativo para o caso de não ter
    /// ao menos 1 item na lista. Pois, se não tiver nenhum, ele retorna "null" o que
    /// dá problema, já que ele vai tentar colocar "null" como um Map<String,dynamic>
    /// Nesse caso, está como "null", entre aspas, porque é a String que o json retorna
    if (response.body == 'null') {
      return [];
    }
    final Map<String, dynamic> listData = jsonDecode(response.body);
    final List<GroceryModel> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryModel(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    return loadedItems;
  }

  /*void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-b7f8f-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please, try again later.';
        });
      }

      /// Esse "if" serve para que não dê ruim no aplicativo para o caso de não ter
      /// ao menos 1 item na lista. Pois, se não tiver nenhum, ele retorna "null" o que
      /// dá problema, já que ele vai tentar colocar "null" como um Map<String,dynamic>
      /// Nesse caso, está como "null", entre aspas, porque é a String que o json retorna
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = jsonDecode(response.body);
      final List<GroceryModel> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryModel(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong. Please, try again later.';
      });
    }
  } */

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryModel>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    _loadItems();
    if (newItem == null) {
      return;
    }
    // Para que a UI seja atualizada com o novo item
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryModel item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-b7f8f-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      // Se der erro, adiciona novamente o item na lista
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
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
      body: FutureBuilder(
        // Usa o "_loadedItems" ao inves da função "_loadItems" para que a função não seja executada
        // toda vez que o método "build" seja chamado, que ai ele só é executado no "initState"
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Items added yet.'),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length, // Antes era _groceryItems.length
            itemBuilder: (context, index) => Dismissible(
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                _removeItem(snapshot.data![index]);
              },
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                leading: Container(
                  color: snapshot.data![index].category.color,
                  width: 20,
                  height: 20,
                ),
                title: Text(snapshot.data![index].name),
                subtitle: const Text(
                  'Swipe to the left to remove the item',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Text(
                  snapshot.data![index].quantity.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
