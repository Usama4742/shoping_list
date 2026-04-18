import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoping_list/data/dummyData.dart';
import 'package:shoping_list/models/grocery_model.dart';
import 'package:shoping_list/widgets/new_items.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItems> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'shopping-list-3a7c7-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Sorry.. Operation Failed, Please try again later...';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = jsonDecode(response.body);

      final List<GroceryItems> loadedItems = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value['category'],
            )
            .value;

        loadedItems.add(
          GroceryItems(
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
        _error = 'Sorry.. Operation Failed, Please try again later...';
      });
    }
  }

  void _addItems() async {
    final newItems = await Navigator.of(
      context,
    ).push<GroceryItems>(MaterialPageRoute(builder: (ctx) => const NewItems()));

    if (newItems == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItems);
    });
  }

  void _removeItems(GroceryItems item) async {
    final int index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'shopping-list-3a7c7-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'Nothing to Show.. Add Items',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItems(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Text(
            _error!,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(onPressed: _addItems, icon: const Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}
