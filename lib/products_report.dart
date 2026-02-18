import 'package:flutter/material.dart';
import 'package:mobile_pos/products.dart';
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
