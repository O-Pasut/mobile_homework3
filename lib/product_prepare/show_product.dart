import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_homework3/model/product_info.dart';

class ShowProduct extends StatefulWidget {
  const ShowProduct({super.key});

  @override
  State<ShowProduct> createState() => _ShowProductState();
}

class _ShowProductState extends State<ShowProduct> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  Future<void> fetchData() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.0.2.2:8001/products'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          products = jsonList.map((item) => Product.fromJson(item)).toList();
        });
      } else {
        _showSnackBar("Failed to load products", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              removeProduct(products[index].id);
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> removeProduct(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('http://10.0.2.2:8001/products/$id'));
      if (response.statusCode == 200) {
        _showSnackBar("Product deleted successfully!", Colors.green);
        fetchData();
      } else {
        _showSnackBar("Failed to delete product!", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  void _showProductDialog(
      [String? initName,
      String? initDescription,
      double? initPrice,
      int? initId]) {
    String? name = initName;
    String? description = initDescription;
    double? price = initPrice;

    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          title: Text(initId == null ? "Create Product" : "Update Product",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: initName ?? '',
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Product Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the product name";
                  }
                  return null;
                },
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: initDescription ?? '',
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Product Description"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the product description";
                  }
                  return null;
                },
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: initPrice == null ? '' : initPrice.toString(),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Product Price"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the product price";
                  }
                  final double? price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return "Enter a valid price";
                  }
                  return null;
                },
                onChanged: (value) => price = double.tryParse(value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              onPressed: () {
                initId == null
                    ? createProduct(name, description, price)
                    : updateProduct(name, description, price, initId);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createProduct(
      String? name, String? description, double? price) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8001/products'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "description": description,
          "price": price,
        }),
      );
      if (response.statusCode == 201) {
        _showSnackBar("Product added successfully!", Colors.green);
        fetchData();
      } else {
        _showSnackBar("Failed to create product!", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  Future<void> updateProduct(
      String? name, String? description, double? price, int? id) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8001/products/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "description": description,
          "price": price,
        }),
      );
      if (response.statusCode == 200) {
        _showSnackBar("Product updated successfully!", Colors.green);
        fetchData();
      } else {
        _showSnackBar("Failed to updated product!", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        title: const Text(
          "Products",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  product.description,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "฿ ${product.price}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.green),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: () => _showProductDialog(
                                                product.name,
                                                product.description,
                                                product.price,
                                                product.id),
                                            icon: const Icon(Icons.create)),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _showDeleteDialog(index),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
