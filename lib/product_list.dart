import 'package:flutter/material.dart';
import 'product.dart';
import 'add_item.dart';

class ProductList extends StatefulWidget {
  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final List<Product> _products = [];

  void _addProduct(Product product) {
    setState(() {
      _products.add(product);
    });
    Navigator.pop(context);
  }

  void _deleteProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddItem page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItem(onProductCreated: _addProduct),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_products[index].name),
            subtitle: Text("Price: ${_products[index].sellingPrice}"),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteProduct(index),
            ),
          );
        },
      ),
    );
  }
}