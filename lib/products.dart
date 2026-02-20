import 'package:flutter/material.dart';
import 'package:mobile_pos/LoginPage.dart';
import 'package:mobile_pos/add_item.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/expenses.dart';
import 'package:mobile_pos/home.dart';
import 'package:mobile_pos/products_report.dart';
import 'package:mobile_pos/profit&loss_report.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/product.dart';
import 'package:mobile_pos/sales_report.dart';
import 'package:mobile_pos/settings.dart';
import 'package:mobile_pos/supplier.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  // 🔹 SHARED INVENTORY (accessible as Products.products)
  static final List<Product> products = [];
  static final List<String> categories = [];


  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(Products.products);
  }

  void _addProduct(Product product) {
    setState(() {
      Products.products.add(product);
      _filteredProducts = List.from(Products.products);
    });
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(Products.products);
      } else {
        _filteredProducts = Products.products
            .where((p) =>
        p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.qty.toString().contains(query))
            .toList();
      }
    });
  }
  void _showAddCategoryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addCategory(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  void _showEditCategoryDialog(int index) {
    final controller =
    TextEditingController(text: Products.categories[index]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();

              if (newName.isEmpty) return;

              setState(() {
                Products.categories[index] = newName;
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _addCategory(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) return;

    if (!Products.categories.contains(trimmed)) {
      setState(() {
        Products.categories.add(trimmed);
      });
    }
  }

  Widget _dialogField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showEditDialog(Product product, int index) {
    final nameController = TextEditingController(text: product.name);
    final purchaseController =
    TextEditingController(text: product.purchasePrice);
    final sellingController =
    TextEditingController(text: product.sellingPrice);
    final categoryController = TextEditingController(text: product.category);
    final qtyController =
    TextEditingController(text: product.qty.toString());

    bool showOnCatalog = product.showOnCatalog;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _dialogField('Item Name', nameController),
              _dialogField('Purchase Price', purchaseController,
                  keyboardType: TextInputType.number),
              _dialogField('Selling Price', sellingController,
                  keyboardType: TextInputType.number),
              _dialogField('Category', categoryController),
              _dialogField('Quantity', qtyController,
                  keyboardType: TextInputType.number),
              StatefulBuilder(
                builder: (context, setStateSB) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Show on catalog'),
                      Switch(
                        value: showOnCatalog,
                        onChanged: (value) {
                          setStateSB(() {
                            showOnCatalog = value;
                          });
                        },
                      ),
                    ],
                  );
                },
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
            onPressed: () {
              setState(() {
                Products.products[index] = Product(
                  name: nameController.text,
                  purchasePrice: purchaseController.text,
                  sellingPrice: sellingController.text,
                  category: categoryController.text,
                  qty: int.tryParse(qtyController.text) ?? 0,
                  showOnCatalog: showOnCatalog,
                );
                _filteredProducts = List.from(Products.products);
              });

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          elevation: 1,
          title: Text(
            'Products (${Products.products.length})',
            style: const TextStyle(color: Colors.black),
          ),
          bottom: const TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.white,
            indicatorColor: Color(0xFF1ABC9C),
            tabs: [
              Tab(text: 'ITEMS'),
              //Tab(text: 'STOCK'),
              Tab(text: 'CATEGORIES'),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: Text('Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
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
                        builder: (context) => CreateSupplierPage()),
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
                        builder: (context) => CreateCustomerPage()),
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
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Settings()),
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
        body: Column(
          children: [
            Builder(
              builder: (context) {
                final tabController = DefaultTabController.of(context);

                return AnimatedBuilder(
                  animation: tabController,
                  builder: (context, _) {
                    final isItemsTab = tabController.index == 0;

                    if (!isItemsTab) {
                      return const SizedBox.shrink(); // hide on Categories tab
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: _filterProducts,
                                decoration: const InputDecoration(
                                  hintText: 'Search items',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddItem(onProductCreated: _addProduct),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add_circle,
                                  color: Color(0xFF1ABC9C)),
                              label: const Text('Add Item'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final realIndex =
                      Products.products.indexOf(product);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                              "Price: ${product.sellingPrice} • Qty: ${product.qty}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () =>
                                    _showEditDialog(product, realIndex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete item'),
                                      content: const Text('Are you sure you want to delete this item?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('No'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    setState(() {
                                      Products.products.removeAt(realIndex);
                                      _filteredProducts = List.from(Products.products);
                                    });
                                  }
                                },
                              ),

                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _showAddCategoryDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Category'),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Products.categories.isEmpty
                            ? const Center(child: Text('No categories yet'))
                            : ListView.builder(
                          itemCount: Products.categories.length,
                          itemBuilder: (context, index) {
                            final category = Products.categories[index];
                            return Card(
                              margin:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: const Icon(Icons.category, color: Colors.blueAccent,),
                                title: Text(category),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditCategoryDialog(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Category'),
                                            content: const Text('Are you sure you want to delete this category?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('No'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          setState(() {
                                            Products.categories.removeAt(index);
                                          });
                                        }
                                      },
                                    ),

                                  ],
                                ),

                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
