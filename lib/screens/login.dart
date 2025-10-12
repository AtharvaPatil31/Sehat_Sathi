import 'package:flutter/material.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(seconds: 2)); // simulate delay

      // If validations pass, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

      setState(() => _isLoading = false);
    }
  }

  bool _isAlphanumeric(String str) {
    final alphaNum = RegExp(r'^[a-zA-Z0-9]+$');
    return alphaNum.hasMatch(str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 30),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: "Email", filled: true, fillColor: Colors.white70),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter your email";
                    if (!v.endsWith("@gmail.com")) return "Email must end with @gmail.com";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Password", filled: true, fillColor: Colors.white70),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Please enter your password";
                    if (!_isAlphanumeric(v)) return "Password must be alphanumeric";
                    if (v.length < 6) return "Password must be at least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: primaryColor)
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Login",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
