import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_course_app/core/presentation/auth/bloc/auth_bloc.dart';
import 'package:demo_course_app/core/presentation/auth/bloc/events/auth_events.dart';
import 'package:demo_course_app/core/presentation/auth/bloc/state/auth_state.dart';
import 'package:demo_course_app/modules/auth/root_navi.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_bloc.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_event.dart';
import 'package:demo_course_app/core/presentation/product/bloc/product_bloc.dart';
import 'package:demo_course_app/core/presentation/product/bloc/product_event.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern Deep Gradient Background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1e3c72), // Deep Navy
              Color(0xFF2a5298), // Professional Blue
              Color(0xFF2193b0), // Subtle Teal
            ],
          ),
        ),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.read<CartBloc>().add(LoadCart());
              context.read<ProductBloc>().add(LoadProducts());
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainNavigationScreen()),
              );
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    children: [
                      // Branding Section
                      const Icon(
                        Icons.shield_outlined,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "E-COM DEMO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const Text(
                        "Supply Chain Management System",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 40),

                      // Login Card
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1e3c72),
                                ),
                              ),
                              const Text("Sign in to your dashboard"),
                              const SizedBox(height: 32),

                              // Email
                              _buildTextField(
                                controller: _emailController,
                                label: "Corporate Email",
                                icon: Icons.alternate_email,
                                validator: _validateEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),

                              // Password
                              _buildTextField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_open_rounded,
                                validator: _validatePassword,
                                obscureText: _obscurePassword,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {}, // Forgot password logic
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<AuthBloc>().add(
                                              LoginRequested(
                                                _emailController.text,
                                                _passwordController.text,
                                              ),
                                            );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1e3c72),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: state is AuthLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "SIGN IN",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Sign Up Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("New here?"),
                                  TextButton(
                                    onPressed: state is AuthLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              context.read<AuthBloc>().add(
                                                SignUpRequested(
                                                  _emailController.text,
                                                  _passwordController.text,
                                                ),
                                              );
                                            }
                                          },
                                    child: const Text(
                                      "Request Access",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom TextField Builder to keep the UI clean
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF1e3c72), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1e3c72), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red.shade200),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
