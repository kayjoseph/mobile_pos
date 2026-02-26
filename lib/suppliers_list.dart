import 'package:flutter/material.dart';
import 'package:mobile_pos/supplier.dart';
import 'package:mobile_pos/db/app_database.dart';

class SuppliersList extends StatefulWidget {
  const SuppliersList({super.key});

  @override
  State<SuppliersList> createState() => _SuppliersListState();
}

class _SuppliersListState extends State<SuppliersList> {
  Future<void> _deleteSupplier(int index) async {
    final supplier = suppliers[index];
    await db.deleteSupplier(supplier.id);
    await _loadSuppliers();
  }

  late AppDatabase db;
  List<Supplier> suppliers = [];

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    final data = await db.getAllSuppliers();
    setState(() {
      suppliers = data;
    });
  }

  void _editSupplier(int index) {
    final supplier = suppliers[index];
    final nameController = TextEditingController(text: supplier.name);
    final phoneController = TextEditingController(text: supplier.phone);
    final emailController = TextEditingController(text: supplier.email);
    final descriptionController = TextEditingController(text: supplier.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Supplier'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = supplier.copyWith(
                name: nameController.text,
                phone: phoneController.text,
                email: emailController.text,
                description: descriptionController.text,
              );

              await db.updateSupplier(updated);
              await _loadSuppliers();

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Suppliers List', style: TextStyle(color: Colors.white),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateSupplierPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Supplier',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: suppliers.isEmpty
          ? const Center(child: Text('No suppliers added yet',
      style: TextStyle(fontSize: 18,
      ),))
          : ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.store),
              title: Text(supplier.name),
              subtitle: Text('${supplier.phone} • ${supplier.email}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editSupplier(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteSupplier(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
