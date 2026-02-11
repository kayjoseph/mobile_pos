import 'package:flutter/material.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/help.dart';
import 'package:mobile_pos/home.dart';
import 'package:mobile_pos/products.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/settings.dart';
import 'package:mobile_pos/supplier.dart';
import 'LoginPage.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Dashboard',
          style: TextStyle(color: Colors.white),),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Loginpage(),
                ),
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),

      // Left-side navigation drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.home_filled),
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
              leading: Icon(Icons.inventory),
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
              leading: Icon(Icons.point_of_sale),
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
              leading: Icon(Icons.local_shipping),
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
              leading: Icon(Icons.people),
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
            ListTile(
              leading: Icon(Icons.settings),
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
              leading: Icon(Icons.help_outline),
              title: Text('Help'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Help(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_outlined),
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

      body: Padding(

        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 1,
          childAspectRatio: 2.0, // Adjust the aspect ratio to control card size
          mainAxisSpacing: 16.0,  // Space between rows
          crossAxisSpacing: 16.0,
          children: [
            _buildCard('Today\'s Sales', '100', Icons.attach_money, context, Colors.lightGreen),
            _buildCard('Purchases Due', '50', Icons.shopping_cart, context, Colors.lightBlue),
            _buildCard('Sales Due', '30', Icons.receipt, context, Colors.lightGreen),
            _buildCard('Customers', '5', Icons.people, context, Colors.lightBlue),
            _buildCard('suppliers', '3', Icons.local_shipping, context, Colors.lightGreen),
            _buildCard('Sales Invoice', '12', Icons.people, context, Colors.lightBlue),
          ],
        ),
      ),
    );
  }
  Widget _buildCard(String title, String amount, IconData icon, BuildContext context, Color color) {
    return Card(
      elevation: 4,
      color: color,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title: $amount')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white), // Smaller icon size
              SizedBox(height: 6), // Reduced space
              Text(
                title,
                style: TextStyle(
                  fontSize: 16, // Smaller font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6), // Reduced space
              Text(
                amount,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white), // Adjust amount font size
              ),
            ],
          ),
        ),
      ),
    );
  }
}
