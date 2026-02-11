import 'package:flutter/material.dart';
import 'product.dart';

class AddItem extends StatefulWidget {
  final Function(Product) onProductCreated;

  const AddItem({super.key, required this.onProductCreated});

  @override
  State<AddItem> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItem> {
  final _itemNameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _qtyController = TextEditingController();
  bool showOnCatalog = true;

  Future<void> _createProduct() async {
    // Collect product data
    final product = Product(
      name: _itemNameController.text,
      purchasePrice: _purchasePriceController.text,
      sellingPrice: _sellingPriceController.text,
      category: _categoryController.text,
      qty: int.tryParse(_qtyController.text) ?? 0,
      showOnCatalog: showOnCatalog,
    );

    widget.onProductCreated(product);

    _itemNameController.clear();
    _purchasePriceController.clear();
    _sellingPriceController.clear();
    _categoryController.clear();
    _qtyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Item Name', controller: _itemNameController),
            _buildTextField('Purchase Price', keyboardType: TextInputType.number, controller: _purchasePriceController),
            _buildTextField('Selling Price', keyboardType: TextInputType.number, controller: _sellingPriceController),
            _buildTextField('Category', controller: _categoryController),
            _buildTextField('Quantity', controller: _qtyController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show item on catalog'),
                Switch(
                  value: showOnCatalog,
                  onChanged: (value) {
                    setState(() {
                      showOnCatalog = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30,),
            Align(
              alignment: Alignment.center, // or Alignment.center if you want it centered
              child: ElevatedButton(
                onPressed: () {
                  _createProduct();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // padding around text
                  minimumSize: Size.zero, // important: allow width to shrink
                ),
                child: const Text(
                  'Create Product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, {TextEditingController? controller, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}