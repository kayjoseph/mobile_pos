import 'package:flutter/material.dart';
import 'package:mobile_pos/db/app_database.dart';
import 'package:mobile_pos/home.dart';
import 'package:mobile_pos/products.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/supplier.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/products_report.dart';
import 'package:mobile_pos/profit&loss_report.dart';
import 'package:mobile_pos/sales_report.dart';
import 'package:mobile_pos/settings.dart';
import 'package:mobile_pos/LoginPage.dart';
import 'package:drift/drift.dart' as drift;

class Expenses extends StatefulWidget {
  const Expenses({super.key}
      );
  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime? filterStart;
  DateTime? filterEnd;

  late AppDatabase db;
  List<ExpenseEntry> expensesList = [];

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final allExpenses = await db.getAllExpenses();
    setState(() {
      expensesList = allExpenses;
    });
  }

  List<ExpenseEntry> get displayedExpenses {
    if (filterStart != null && filterEnd != null) {
      return expensesList.where((e) {
        return e.date.isAfter(filterStart!.subtract(const Duration(days: 1))) &&
            e.date.isBefore(filterEnd!.add(const Duration(days: 1)));
      }).toList();
    }
    return expensesList;
  }

  Future<void> _pickDate(BuildContext context, bool isFilter) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFilter) {
          filterStart ??= picked;
          filterEnd ??= picked;
        } else {
          selectedDate = picked;
        }
      });
    }
  }

  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      await db.insertExpense(
        ExpenseEntriesCompanion.insert( // <-- NO drift. prefix here
          name: _nameController.text,
          amount: double.parse(_amountController.text),
          date: selectedDate,
          note: _noteController.text.isEmpty
              ? const drift.Value.absent() // <-- drift.Value only
              : drift.Value(_noteController.text),
        ),
      );
      // Clear input fields
      _nameController.clear();
      _amountController.clear();
      _noteController.clear();

      // Reload expenses
      await _loadExpenses();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense saved'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Expenses', style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Add Expense', icon: Icon(Icons.add)),
              Tab(text: 'Expense List', icon: Icon(Icons.list)),
            ],
          ),
        ),
        drawer: _buildDrawer(context),
        body: TabBarView(
          children: [
            _buildAddExpenseTab(),
            _buildExpenseListTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExpenseTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Expense Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Amount', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Note', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('Date: ${selectedDate.toString().split(' ')[0]}'),
                const Spacer(),
                TextButton(
                  onPressed: () => _pickDate(context, false),
                  child: const Text('Pick date'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.blueAccent,
                  side: const BorderSide(color: Colors.blueAccent, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  minimumSize: Size.zero,
                ),
                child: const Text('Create Expense',
                    style: TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseListTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  filterStart = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  setState(() {});
                },
                child: const Text('Start date'),
              ),
              TextButton(
                onPressed: () async {
                  filterEnd = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now(),
                  );
                  setState(() {});
                },
                child: const Text('End date'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  filterStart = null;
                  filterEnd = null;
                  setState(() {});
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: displayedExpenses.isEmpty
                ? const Center(child: Text('No expenses found'))
                : ListView.builder(
              itemCount: displayedExpenses.length,
              itemBuilder: (context, index) {
                final e = displayedExpenses[index];
                return Card(
                  child: ListTile(
                    title: Text(e.name),
                    subtitle: Text(
                      '${e.date.toString().split(' ')[0]}'
                          '${e.note != null ? '\n${e.note}' : ''}',
                    ),
                    trailing: Text(
                      'KSH ${e.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
                  context, MaterialPageRoute(builder: (context) => Home()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.blue),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Products()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.blue),
            title: const Text('Sales'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Sales()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.wallet, color: Colors.blue),
            title: const Text('Expenses'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Expenses()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping, color: Colors.blue),
            title: const Text('Suppliers'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateSupplierPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('Customers'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreateCustomerPage()));
            },
          ),
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
    );
  }
}