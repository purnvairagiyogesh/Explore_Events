import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  Future<void> _submit() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.orange),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      if (isLogin) {
        // Local Login Check
        final savedEmail = prefs.getString('reg_email');
        final savedPassword = prefs.getString('reg_password');

        if (savedEmail == email && savedPassword == password) {
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('currentUser_email', email);
          await prefs.setString('currentUser_name', prefs.getString('reg_name') ?? "User");
          
          if (mounted) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
            }
          }
        } else {
          throw "Invalid email or password";
        }
      } else {
        // Local Signup (Storing credentials locally)
        await prefs.setString('reg_email', email);
        await prefs.setString('reg_password', password);
        await prefs.setString('reg_name', name);
        
        // Auto login after signup
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('currentUser_email', email);
        await prefs.setString('currentUser_name', name);

        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
              const SizedBox(height: 40),
              Text(
                isLogin ? "Local\nLogin" : "Local\nSignup",
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 20),
              const Text("Data is stored locally on this device.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              if (!isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    hintText: "Enter your full name",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "example@mail.com",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "••••••••",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isLogin ? "Login" : "Sign Up",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(
                    isLogin ? "New here? Create Account" : "Already have an account? Login",
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
