import 'package:flutter/material.dart';
import 'package:mobile_homework3/product_prepare/show_product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/',
        routes: {'/': (context) => const ShowProduct()});
  }
}
