import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoping_list/models/grocery_model.dart';
import '../data/dummyData.dart';
import '../models/category_models.dart';
import 'package:http/http.dart' as http;

class NewItems extends StatefulWidget {
  const NewItems({super.key});

  @override
  State<NewItems> createState() => _NewItemsState();
}

class _NewItemsState extends State<NewItems> {
  final _formkey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  Future<void> _saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
        'shopping-list-3a7c7-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'Application/json'},
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItems(
          id: responseData['name'],
          name: _enteredName,
          category: _selectedCategory,
          quantity: _enteredQuantity,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Item')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Item Name:')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length > 50) {
                    return 'Must between 1 to 50 Characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity: '),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! < 0) {
                          return 'Must be a valid, positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 10),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formkey.currentState!.reset();
                            },
                      child: Text(
                        'Reset',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: _isSending ? null : _saveItem,
                      child: Text(
                        'Save',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
