import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_pos/LoginPage.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/expenses.dart';
import 'package:mobile_pos/products.dart';
import 'package:mobile_pos/product.dart';
import 'package:mobile_pos/products_report.dart';
import 'package:mobile_pos/profit&loss_report.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/sales_report.dart';
import 'package:mobile_pos/settings.dart';
import 'package:mobile_pos/supplier.dart';

void main() {
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  Map<String, double> getTodaySalesByCategory() {
    final today = DateTime.now();
    final Map<String, double> data = {};

    for (var sale in Sales.sales) {
      if (sale.date.year == today.year &&
          sale.date.month == today.month &&
          sale.date.day == today.day) {
        for (var item in sale.items) {
          final product = Products.products.firstWhere(
                (p) => p.name == item.productName,
            orElse: () => Product(
                name: item.productName,
                purchasePrice: '0',
                sellingPrice: '0',
                category: 'Unknown',
                qty: 0,
                showOnCatalog: true),
          );
          data[product.category] = (data[product.category] ?? 0) + item.total;
        }
      }
    }
    return data;
  }

  Widget buildSalesPieChart() {
    final salesData = getTodaySalesByCategory();

    if (salesData.isEmpty) {
      return const Center(child: Text('No sales today'));
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.yellow
    ];
    int i = 0;

    // Calculate total sales for today
    final totalSales = salesData.values.fold(0.0, (sum, value) => sum + value);

    return PieChart(
      PieChartData(
        sections: salesData.entries.map((entry) {
          final color = colors[i % colors.length];
          i++;

          // Calculate percentage
          final percentage = (entry.value / totalSales) * 100;

          return PieChartSectionData(
            value: entry.value,
            title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
            color: color,
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        //centerSpaceRadius: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double grandTotal = Sales.grandTotal;
    final int completedSales = Sales.completedSalesCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Homepage',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MobilePOS',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Image.asset(
                    'lib/Images/Reoprime Logo.png',
                    width: 100,
                    height: 80,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_filled, color: Colors.blue),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const Products(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const Sales(),
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
              leading: const Icon(Icons.local_shipping, color: Colors.blue),
              title: const Text('Suppliers'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateSupplierPage(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const CreateCustomerPage(),
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
                        builder: (context) => const SalesReport(),
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
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Settings(),
                  ),
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
                  MaterialPageRoute(
                    builder: (context) => const Loginpage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODAY summary container
        Container(
          width: double.infinity,
          color: Colors.blue,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('TODAY', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text(
                'KSH ${grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$completedSales completed sales',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Sales()),
                  );
                  // refresh homepage after returning from Sales
                  (context as Element).markNeedsBuild();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Log a sale',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),

        // POS mobile info container
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'With POS mobile, you have access to exclusive tools that make all the difference. Check out our plans!',
            style: TextStyle(fontSize: 16),
          ),
        ),

        // Pie chart container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales by Category Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: buildSalesPieChart(),
              ),
            ],
          ),
        ),
      ],
    ),
    ),
    );
  }
}
