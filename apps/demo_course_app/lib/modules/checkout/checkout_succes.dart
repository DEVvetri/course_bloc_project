import 'dart:async';
import 'package:flutter/material.dart';

class CheckoutSuccessScreen extends StatefulWidget {
  const CheckoutSuccessScreen({super.key});

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-back logic: Hold for 2 seconds then pop
    
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        // Navigates back to the main screen (HomeScreen/ProductList)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Animation Container
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Order Placed Successfully!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your items are being prepared for shipping.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator to show it's processing the redirect
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}