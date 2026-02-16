import 'package:flutter/material.dart';
import 'package:mobile_pos/LoginPage.dart';
import 'package:mobile_pos/products.dart';
import 'package:mobile_pos/customer.dart';
import 'package:mobile_pos/help.dart';
import 'package:mobile_pos/home.dart';
import 'package:mobile_pos/sales.dart';
import 'package:mobile_pos/settings.dart';
import 'package:mobile_pos/supplier.dart';
import 'expense_model.dart';
import 'expense_repository.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime? filterStart;
  DateTime? filterEnd;

  List<Expense> get displayedExpenses {
    if (filterStart != null && filterEnd != null) {
      return ExpenseRepository.filterByDateRange(filterStart!, filterEnd!);
    }
    return ExpenseRepository.expenses;
  }

  void _pickDate(BuildContext context, bool isFilter) async {
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

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      ExpenseRepository.addExpense(
        Expense(
          name: nameController.text,
          amount: double.parse(amountController.text),
          date: selectedDate,
          note: noteController.text.isEmpty ? null : noteController.text,
        ),
      );

      nameController.clear();
      amountController.clear();
      noteController.clear();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // two tabs
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Expenses', style: TextStyle(color: Colors.white),),
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
                leading: const Icon(Icons.help_outline, color: Colors.blue),
                title: const Text('Help'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Help()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_outlined, color: Colors.blue),
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
        body: TabBarView(
          children: [
            // Tab 1: Add Expense
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Expense Name',
                        border: OutlineInputBorder(), // simple border
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(), // simple border
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          labelText: 'Note',
                        border: OutlineInputBorder(), // simple border
                      ),
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
                      alignment: Alignment.center, // or Alignment.center if you want it centered
                      child: ElevatedButton(
                        onPressed: _addExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.blueAccent,
                          side: const BorderSide(color: Colors.blueAccent, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // padding around text
                          minimumSize: Size.zero, // important: allow width to shrink
                        ),
                        child: const Text(
                          'Create Expense',
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

            // Tab 2: Expense List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filter Row
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
                  // Expense List
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
            ),
          ],
        ),
      ),
    );
  }
}
