import 'package:flutter/material.dart';
import 'package:mobile_pos/home.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  final _formKey = GlobalKey<FormState>();

  void _forgotPassword() {
    final usernameController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final username =
              usernameController.text.trim().toLowerCase();
              final newPassword = newPasswordController.text.trim();

              if (username.isEmpty || newPassword.isEmpty) {
                _showMessage('All fields are required', isError: true);
                return;
              }

              if (!_users.containsKey(username)) {
                _showMessage('Username does not exist', isError: true);
                return;
              }

              if (newPassword.length < 4) {
                _showMessage(
                  'Password must be at least 4 characters',
                  isError: true,
                );
                return;
              }

              setState(() {
                _users[username] = newPassword;
              });

              Navigator.pop(context);
              _showMessage('Password reset successful');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // In-memory user store (username → password)
  static final Map<String, String> _users = {
    'admin': '1234', // default account
  };

  bool _isCreatingAccount = false;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final username = usernameController.text.trim().toLowerCase();
      final password = passwordController.text.trim();

      if (_isCreatingAccount) {
        if (_users.containsKey(username)) {
          _showMessage('Username already exists', isError: true);
          return;
        }

        _users[username] = password;
        _showMessage('Account created successfully');
        setState(() {
          _isCreatingAccount = false;
        });
        usernameController.clear();
        passwordController.clear();
      } else {
        // ===== LOGIN =====
        if (!_users.containsKey(username)) {
          _showMessage('Username does not exist', isError: true);
          return;
        }

        if (_users[username] != password) {
          _showMessage('Wrong password', isError: true);
          return;
        }
        // ===== SUCCESS =====
        _showMessage('Login successful');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ensures Column shrinks when keyboard shows
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/Images/Reoprime Logo.png',
            width: 150,
            fit: BoxFit.contain, // keeps aspect ratio

          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Username
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter password';
                        }
                        if (_isCreatingAccount && value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        _isCreatingAccount ? 'Create Account' : 'Sign In',
                        style:
                        const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot password?',
                    style: TextStyle(fontSize: 17),),
                  ),
                  // Toggle Login / Create Account
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isCreatingAccount = !_isCreatingAccount;
                      });
                    },
                    child: Text(
                      _isCreatingAccount
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Create one',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Powered by JOSEPH - 0746050626',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
