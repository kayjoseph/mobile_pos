import 'package:flutter/material.dart';
import 'package:mobile_pos/LoginPage.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/expenses.dart';
import 'package:mobile_pos/home.dart';
import 'package:mobile_pos/products_report.dart';
import 'package:mobile_pos/profit&loss_report.dart';
import 'package:mobile_pos/sales_report.dart';
import 'package:mobile_pos/settings.dart';
import 'package:mobile_pos/supplier.dart';
import 'product.dart';
import 'sale.dart';
import 'package:mobile_pos/products.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  static final List<Sale> sales = [];

  static double get grandTotal {
    return sales.fold(0.0, (sum, s) => sum + s.total);
  }

  static int get completedSalesCount => sales.length;


  @override
  State<Sales> createState() => _SalesState();
}
class _SalesState extends State<Sales> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  List<Product> _filteredProducts = [];
  Product? _selectedProduct;

  /// 🛒 Cart: product -> quantity
  final Map<Product, int> _cart = {};

  DateTime? _startDate;
  DateTime? _endDate;

  List<Sale> get _filteredSales {
    if (_startDate == null || _endDate == null) {
      return Sales.sales;
    }

    return Sales.sales.where((sale) {
      final saleDate = DateTime(
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

      return saleDate.isAtSameMomentAs(start) ||
          saleDate.isAtSameMomentAs(end) ||
          (saleDate.isAfter(start) && saleDate.isBefore(end));
    }).toList();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }


  double get _cartTotal {
    double total = 0.0;
    _cart.forEach((product, qty) {
      final price = double.tryParse(product.sellingPrice) ?? 0;
      total += qty * price;
    });
    return total;
  }

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(Products.products);
  }

  double get _grandTotal {
    return Sales.sales.fold(0.0, (sum, s) => sum + s.total);
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(Products.products);
      } else {
        _filteredProducts = Products.products
            .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showSaleDetails(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sale Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...sale.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.productName} x${item.qtySold}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        item.total.toStringAsFixed(2),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    sale.total.toStringAsFixed(2),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _qtyController.clear();
    });
  }

  void _addToCart() {
    if (_selectedProduct == null) return;

    final qty = int.tryParse(_qtyController.text) ?? 0;

    if (qty <= 0) {
      _showMessage('Enter a valid quantity');
      return;
    }

    if (qty > _selectedProduct!.qty) {
      _showMessage('Insufficient stock available');
      return;
    }

    setState(() {
      _cart[_selectedProduct!] =
          (_cart[_selectedProduct!] ?? 0) + qty;

      _selectedProduct = null;
      _qtyController.clear();
      _searchController.clear();
      _filteredProducts = List.from(Products.products);
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cart.remove(product);
    });
  }

  void _completeSale() {
    if (_cart.isEmpty) {
      _showMessage('Cart is empty');
      return;
    }

    final List<SaleItem> items = [];

    setState(() {
      _cart.forEach((product, qty) {

        // Deduct stock
        product.qty -= qty;

        // Build sale item
        final sellingPrice =
            double.tryParse(product.sellingPrice) ?? 0;
        final purchasePrice =
            double.tryParse(product.purchasePrice) ?? 0;
        final itemTotal = qty * sellingPrice;
        final itemProfit =
            (sellingPrice - purchasePrice) * qty;
        items.add(
          SaleItem(
            productName: product.name,
            qtySold: qty,
            sellingPrice: sellingPrice,
            purchasePrice: purchasePrice,
            total: itemTotal,
            profit: itemProfit,
          ),
        );
      });

      Sales.sales.add(
        Sale(
          items: items,
          total: _cartTotal,
          date: DateTime.now(),
        ),
      );

      _cart.clear();
      _filteredProducts = List.from(Products.products);
    });

    _showMessage('Sale completed successfully');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sales'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'MAKE SALE'),
              Tab(text: 'SALES LIST'),
            ],
          ),
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
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: const InputDecoration(
                      hintText: 'Search product',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];

                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text(
                            'Price: ${product.sellingPrice} • Qty: ${product.qty}'),
                        trailing: ElevatedButton(
                          onPressed: product.qty <= 0
                              ? null
                              : () => _selectProduct(product),
                          child: const Text('Select'),
                        ),
                      );
                    },
                  ),
                ),

                // ➕ Add-to-cart panel
                if (_selectedProduct != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: const Border(
                          top: BorderSide(color: Colors.grey)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected: ${_selectedProduct!.name}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          TextField(
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: _addToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // padding around text
                                minimumSize: Size.zero, // important: allow width to shrink
                              ),
                              child: const Text('Add to Cart',
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

                // 🛒 Cart section
                if (_cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: const Border(
                          top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 8),

                        ..._cart.entries.map((entry) {
                          final product = entry.key;
                          final qty = entry.value;
                          final price = double.tryParse(
                              product.sellingPrice) ??
                              0;
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text(
                                'Qty: $qty • Unit: ${price.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (qty * price)
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _removeFromCart(product),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cart Total',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _cartTotal.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: _completeSale,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Complete Sale',
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
              ],
            ),
            Column(
              children: [
                // 📅 Date filter bar
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: true),
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _startDate == null
                                ? 'Start Date'
                                : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: false),
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            _endDate == null
                                ? 'End Date'
                                : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          ),
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

                Expanded(
                  child: _filteredSales.isEmpty
                      ? const Center(child: Text('No sale found'))
                      : ListView.builder(
                    itemCount: _filteredSales.length,
                    itemBuilder: (context, index) {
                      final sale = _filteredSales[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(
                            'Sale #${index + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${sale.items.length} items • '
                                '${sale.date.toLocal().toString().substring(0, 16)}',
                          ),
                          trailing: Text(
                            sale.total.toStringAsFixed(2),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () => _showSaleDetails(sale),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    border:
                    const Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Grand Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _grandTotal.toStringAsFixed(2),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


