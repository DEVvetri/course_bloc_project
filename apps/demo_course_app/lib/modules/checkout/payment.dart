import 'dart:async';
import 'package:demo_course_app/modules/checkout/checkout_succes.dart';
import 'package:flutter/material.dart';

class ProcessingPaymentScreen extends StatefulWidget {
  const ProcessingPaymentScreen({super.key});

  @override
  State<ProcessingPaymentScreen> createState() => _ProcessingPaymentScreenState();
}

class _ProcessingPaymentScreenState extends State<ProcessingPaymentScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate payment processing for 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CheckoutSuccessScreen()),
        );
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
            // Using a large, stylish CircularProgressIndicator
            const SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Processing Payment...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            const SizedBox(height: 12),
            Text(
              "Please do not refresh or close the app",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}