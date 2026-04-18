import 'package:flutter/material.dart';
import 'package:shoping_list/widgets/grocery_list.dart';

// ...

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          surface: const Color.fromARGB(255, 47, 51, 59),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
      ),
      debugShowCheckedModeBanner: false,
      home: const GroceryList(),
    );
  }
}
