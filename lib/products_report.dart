import 'package:flutter/material.dart';
import 'package:mobile_pos/LoginPage.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/expenses.dart';
import 'package:mobile_pos/home.dart';
import 'package:mobile_pos/products.dart';
import 'package:mobile_pos/profit&loss_report.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/sales_report.dart';
import 'package:mobile_pos/settings.dart';
import 'package:mobile_pos/supplier.dart';
import 'product.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ProductsValuationReport extends StatelessWidget {
  const ProductsValuationReport({super.key});

  double getTotalPurchaseValue(Product product) {
    final purchasePrice = double.tryParse(product.purchasePrice) ?? 0;
    return purchasePrice * product.qty;
  }

  double getTotalSellingValue(Product product) {
    final sellingPrice = double.tryParse(product.sellingPrice) ?? 0;
    return sellingPrice * product.qty;
  }

  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final products = Products.products;

    final grandPurchaseValue = products.fold(
        0.0, (sum, product) => sum + getTotalPurchaseValue(product));
    final grandSellingValue = products.fold(
        0.0, (sum, product) => sum + getTotalSellingValue(product));

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Products & Valuation Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),

          // Table of products
          pw.Table.fromTextArray(
            headers: [
              'Product',
              'Category',
              'Qty',
              'Unit Cost',
              'Selling Price',
              'Total Cost',
              'Total Sell'
            ],
            data: products.map((product) {
              return [
                product.name,
                product.category,
                product.qty.toString(),
                product.purchasePrice,
                product.sellingPrice,
                getTotalPurchaseValue(product).toStringAsFixed(2),
                getTotalSellingValue(product).toStringAsFixed(2),
              ];
            }).toList(),
          ),

          pw.Divider(height: 30),

          // Grand totals
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Grand Total Purchase: ${grandPurchaseValue.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
                pw.Text(
                  'Grand Total Selling: ${grandSellingValue.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'products_valuation_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = Products.products;

    final grandPurchaseValue = products.fold(
        0.0, (sum, product) => sum + getTotalPurchaseValue(product));
    final grandSellingValue = products.fold(
        0.0, (sum, product) => sum + getTotalSellingValue(product));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Products & Valuation Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: products.isEmpty ? null : () => _generatePdf(context),
          ),
        ],
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
      body: Column(
        children: [
          // Summary totals
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Total Purchase Value',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(grandPurchaseValue.toStringAsFixed(2)),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Total Selling Value',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(grandSellingValue.toStringAsFixed(2)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Product list
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final purchaseValue = getTotalPurchaseValue(product);
                final sellingValue = getTotalSellingValue(product);

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        'Category: ${product.category} • Qty: ${product.qty} • Unit Cost: ${product.purchasePrice} • Selling: ${product.sellingPrice}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Total Cost: ${purchaseValue.toStringAsFixed(2)}'),
                        Text('Total Sell: ${sellingValue.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
