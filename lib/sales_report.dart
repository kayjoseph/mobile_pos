import 'package:flutter/material.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/sale.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class SalesReport extends StatefulWidget {
  const SalesReport({super.key});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  DateTime? _startDate;
  DateTime? _endDate;

  List<Sale> get _filteredSales {
    if (_startDate == null || _endDate == null) {
      return Sales.sales;
    }

    return Sales.sales.where((sale) {
      final d = DateTime(
        sale.date.year,
        sale.date.month,
        sale.date.day,
      );

      final start = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
      );

      final end = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
      );

      return d.isAtSameMomentAs(start) ||
          d.isAtSameMomentAs(end) ||
          (d.isAfter(start) && d.isBefore(end));
    }).toList();
  }

  List<DataRow> _buildRows() {
    final List<DataRow> rows = [];

    for (int i = 0; i < _filteredSales.length; i++) {
      final sale = _filteredSales[i];

      for (int j = 0; j < sale.items.length; j++) {
        final item = sale.items[j];
        final bool isLastItem = j == sale.items.length - 1;

        rows.add(
          DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(sale.date.toString().substring(0, 10))),
              DataCell(Text(item.productName)),
              DataCell(Text(item.qtySold.toString())),
              DataCell(Text(item.total.toStringAsFixed(2))),
              DataCell(
                isLastItem
                    ? Text(
                  sale.total.toStringAsFixed(2),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
                    : const Text(''),
              ),
            ],
          ),
        );
      }
    }
    return rows;
  }
  double get _total {
    return _filteredSales.fold(0, (sum, s) => sum + s.total);
  }

  double get _itemsSubTotal {
    double sum = 0;

    for (final sale in _filteredSales) {
      for (final item in sale.items) {
        sum += item.total;
      }
    }
    return sum;
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        isStart ? _startDate = picked : _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Sales Report', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white,),
            onPressed: _filteredSales.isEmpty ? null : _generatePdf,
          )
        ],
      ),
      body: Column(
        children: [
          // 📅 Date filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  const Text(
                    'From Date:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      child: Text(
                        _startDate == null
                            ? 'Select date'
                            : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    'To Date:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(false),
                      child: Text(
                        _endDate == null
                            ? 'Select date'
                            : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _filteredSales.isEmpty
                ? const Center(child: Text('No sales found'))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.brown.shade100),
                  border: TableBorder.all(
                    color: Colors.brown,
                    width: 1.2,
                  ),
                  columns: const [
                    DataColumn(label: Text('Sale #')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Item')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Line Total')),
                    DataColumn(label: Text('Sale Total')),
                  ],
                  rows: _buildRows(),
                )

              ),
            ),
          ),

          // 💰 Total
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Items Subtotal',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _itemsSubTotal.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Sales',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _total.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          )

        ],
      ),
    );
  }

  // PDF logic will go here
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Determine if all sales are on the same date
    String periodText;
    if (_filteredSales.isNotEmpty) {
      final firstDate = _filteredSales.first.date;
      final sameDate = _filteredSales.every((sale) =>
      sale.date.year == firstDate.year &&
          sale.date.month == firstDate.month &&
          sale.date.day == firstDate.day);

      periodText = sameDate
          ? 'Date: ${firstDate.day}/${firstDate.month}/${firstDate.year}'
          : 'Period: '
          '${_startDate != null ? _startDate!.toString().substring(0, 10) : 'All'}'
          ' - '
          '${_endDate != null ? _endDate!.toString().substring(0, 10) : 'All'}';
    } else {
      periodText = 'No sales found';
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Sales Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text(periodText),
          pw.SizedBox(height: 20),

          // Combine all sales items into one table
          pw.TableHelper.fromTextArray(
            headers: ['Item', 'Qty', 'Total'],
            data: _filteredSales
                .expand((sale) => sale.items.map((item) => [
              item.productName,
              item.qtySold.toString(),
              item.total.toStringAsFixed(2),
            ]))
                .toList(),
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),

          // Grand total at the end
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Grand Total: ${_total.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'sales_report.pdf',
    );
  }


}
