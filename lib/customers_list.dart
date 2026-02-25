import 'package:flutter/material.dart';
import 'package:mobile_pos/db/app_database.dart';
import 'package:mobile_pos/customer.dart';

class CustomersList extends StatefulWidget {
  const CustomersList({super.key});

  @override
  State<CustomersList> createState() => _CustomersListState();
}

class _CustomersListState extends State<CustomersList> {

  late AppDatabase db;
  List<Customer> customers = [];

  Future<void> _deleteCustomer(int index) async {
    final customer = customers[index];
    await db.deleteCustomer(customer.id);
    await _loadCustomers();
  }

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final data = await db.getAllCustomers();
    setState(() {
      customers = data;
    });
  }

  void _editcustomer(int index) {
    final customer = customers[index];
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final emailController = TextEditingController(text: customer.email);
    final descriptionController = TextEditingController(text: customer.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {

              final updated = customer.copyWith(
                name: nameController.text,
                phone: phoneController.text,
                email: emailController.text,
                //description: descriptionController.text,

              );

              await db.updateCustomer(updated);

              Navigator.pop(context);
              await _loadCustomers();
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
        title: const Text('Customers List', style: TextStyle(color: Colors.white),),
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
                    builder: (context) => CreateCustomerPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Customer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: customers.isEmpty
          ? const Center(child: Text('No Customers added yet',
      style: TextStyle(fontSize: 18,
      ),
      ),
      )
          : ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.store),
              title: Text(customer.name),
              subtitle: Text('${customer.phone} • ${customer.email} • ${customer.description}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editcustomer(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCustomer(index),
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
