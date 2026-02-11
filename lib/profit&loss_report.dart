import 'package:flutter/material.dart';
import 'sale.dart';
import 'sales.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class ProfitLossReport extends StatefulWidget {
  const ProfitLossReport({super.key});

  @override
  State<ProfitLossReport> createState() => _ProfitLossReportState();
}

class _ProfitLossReportState extends State<ProfitLossReport> {
  DateTime? _startDate;
  DateTime? _endDate;

  List<SaleItem> get _filteredItems {
    List<SaleItem> allItems = [];

    for (var sale in Sales.sales) {
      if (_startDate != null && _endDate != null) {
        final saleDate = DateTime(sale.date.year, sale.date.month, sale.date.day);
        final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

        if (saleDate.isBefore(start) || saleDate.isAfter(end)) {
          continue;
        }
      }

      allItems.addAll(sale.items);
    }

    return allItems;
  }

  double get totalRevenue =>
      _filteredItems.fold(0, (sum, item) => sum + item.total);

  double get totalCost =>
      _filteredItems.fold(0, (sum, item) => sum + item.purchasePrice * item.qtySold);

  double get totalProfit =>
      _filteredItems.fold(0, (sum, item) => sum + item.profit);

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final items = _filteredItems;

    final grandRevenue = totalRevenue;
    final grandCost = totalCost;
    final grandProfit = totalProfit;

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Profit & Loss Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Period: ${_startDate != null ? _startDate!.toString().substring(0, 10) : 'All'}'
                ' - ${_endDate != null ? _endDate!.toString().substring(0, 10) : 'All'}',
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Revenue', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(grandRevenue.toStringAsFixed(2)),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Cost', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(grandCost.toStringAsFixed(2)),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Profit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      grandProfit.toStringAsFixed(2),
                      style: pw.TextStyle(
                        color: grandProfit >= 0 ? PdfColors.green : PdfColors.red,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ]),
            ],
          ),
          pw.SizedBox(height: 20),

          // Table of items
          pw.Table.fromTextArray(
            headers: ['Product', 'Qty', 'Cost', 'Selling', 'Profit'],
            data: items.map((item) {
              return [
                item.productName,
                item.qtySold.toString(),
                item.purchasePrice.toStringAsFixed(2),
                item.sellingPrice.toStringAsFixed(2),
                item.profit.toStringAsFixed(2),
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
                  'Total Revenue: ${grandRevenue.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Total Cost: ${grandCost.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Total Profit: ${grandProfit.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: grandProfit >= 0 ? PdfColors.green : PdfColors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'profit_loss_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: items.isEmpty ? null : _generatePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date filter
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: true),
                    icon: const Icon(Icons.date_range),
                    label: Text(_startDate == null
                        ? 'Start Date'
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDate(isStart: false),
                    icon: const Icon(Icons.date_range),
                    label: Text(_endDate == null
                        ? 'End Date'
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear Filter',
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                ),
              ],
            ),
          ),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(totalRevenue.toStringAsFixed(2)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Cost', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(totalCost.toStringAsFixed(2)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Profit', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(totalProfit.toStringAsFixed(2),
                        style: TextStyle(
                            color: totalProfit >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Itemized list
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No sales found'))
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('${item.productName} x${item.qtySold}'),
                    subtitle: Text(
                        'Cost: ${item.purchasePrice.toStringAsFixed(2)} • Selling: ${item.sellingPrice.toStringAsFixed(2)}'),
                    trailing: Text(
                      item.profit.toStringAsFixed(2),
                      style: TextStyle(
                          color: item.profit >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold),
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
