import 'package:flutter/material.dart';
import 'package:mobile_pos/LoginPage.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/expenses.dart';
import 'package:mobile_pos/home.dart';
import 'package:mobile_pos/products.dart';
import 'package:mobile_pos/products_report.dart';
import 'package:mobile_pos/profit&loss_report.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/sales_report.dart';
import 'package:mobile_pos/settings.dart';
import 'supplier_model.dart';
import 'suppliers_list.dart';

class CreateSupplierPage extends StatefulWidget {
  const CreateSupplierPage({super.key});

  @override
  State<CreateSupplierPage> createState() => _CreateSupplierPageState();
}

class _CreateSupplierPageState extends State<CreateSupplierPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();

  static final List<SupplierModel> _suppliers = [];

  void _createSupplier() {
    if (_formKey.currentState!.validate()) {
      final supplier = SupplierModel(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        description: _descriptionController.text,
      );
      _suppliers.add(supplier);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuppliersList(suppliers: _suppliers),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text("Suppliers"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_filled, color: Colors.blue),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: Colors.blue),
              title: Text('Products'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Products(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.blue),
              title: Text('Sales'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Sales(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wallet, color: Colors.blue),
              title: const Text('Expenses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Expenses(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.local_shipping, color: Colors.blue),
              title: Text('Suppliers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateSupplierPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people, color: Colors.blue),
              title: Text('Customers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateCustomerPage(),
                  ),
                );
              },
            ),
            // Reports Manager Dropdown
            ExpansionTile(
              leading: const Icon(Icons.folder_open, color: Colors.blue),
              title: const Text('Reports Manager'),
              children: [
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Colors.blueAccent, size: 20,),
                  title: const Text('Products Report', style: TextStyle(fontSize: 14),),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ProductsValuationReport(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.show_chart, color: Colors.blueAccent, size: 20,),
                  title: const Text('Sales Report', style: TextStyle(fontSize: 14),),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalesReport(),//SalesReportPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_chart_outlined, color: Colors.blueAccent, size: 20,),
                  title: const Text('Profit & Loss Report', style: TextStyle(fontSize: 14),),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ProfitLossReport(),
                      ),
                    );
                  },
                )
              ],
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined, color: Colors.red),
              title: Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Loginpage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Supplier Name',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter supplier name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter email address' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Enter Description',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 2,
                  maxLines: null,
                  validator: (_) => null,
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center, // or Alignment.center if you want it centered
                  child: ElevatedButton(
                    onPressed: _createSupplier,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14), // padding around text
                      minimumSize: Size.zero, // important: allow width to shrink
                    ),
                    child: const Text('Create Supplier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.center, // or Alignment.center if you want it centered
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuppliersList(suppliers: _suppliers),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // padding around text
                      minimumSize: Size.zero, // important: allow width to shrink
                    ),
                    child: const Text('View SupplierList',
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
        ),
      ),
    );
  }
}
