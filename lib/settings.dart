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
import 'package:mobile_pos/supplier.dart';
import 'package:mobile_pos/db/app_database.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  final AppDatabase appDb = AppDatabase();

  Future<void> _confirmAndResetDatabase() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset database'),
        content: const Text(
          'This will permanently delete all data, proceed with caution 💀☠️ ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, reset'),
          ),
        ],
      ),
    );

    if (result == true) {
      await appDb.resetDatabase();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database reset successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
      ),

      // ---------------- Drawer (unchanged) ----------------
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
              leading: const Icon(Icons.home_filled, color: Colors.blue),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue),
              title: const Text('Products'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Products()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.blue),
              title: const Text('Sales'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Sales()),
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
                  MaterialPageRoute(builder: (context) => const Expenses()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.blue),
              title: const Text('Suppliers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateSupplierPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('Customers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateCustomerPage()),
                );
              },
            ),

            ExpansionTile(
              leading: const Icon(Icons.folder_open, color: Colors.blue),
              title: const Text('Reports Manager'),
              children: [
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined,
                      color: Colors.blueAccent, size: 20),
                  title: const Text('Products Report',
                      style: TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        const ProductsValuationReport(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.show_chart,
                      color: Colors.blueAccent, size: 20),
                  title: const Text('Sales Report',
                      style: TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SalesReport(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_chart_outlined,
                      color: Colors.blueAccent, size: 20),
                  title: const Text('Profit & Loss Report',
                      style: TextStyle(fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfitLossReport(),
                      ),
                    );
                  },
                ),
              ],
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout_outlined, color: Colors.red),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Loginpage()),
                );
              },
            ),
          ],
        ),
      ),

      // ---------------- Settings content ----------------
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.backup, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Backup Database',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),


            const Text(
              'Advanced Settings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmAndResetDatabase,   // ✅ method is referenced here
                icon: const Icon(Icons.delete_forever),
                label: const Text('Reset database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


