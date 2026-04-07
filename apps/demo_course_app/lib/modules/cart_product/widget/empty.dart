import 'package:flutter/material.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "🛒 Cart is empty",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}