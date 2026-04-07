// ignore_for_file: deprecated_member_use

import 'package:demo_course_app/core/presentation/cart/bloc/cart_bloc.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_event.dart';
import 'package:demo_course_app/core/data/product/models/cart_product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartItemTile extends StatelessWidget {
  final CartProductModel item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image Placeholder
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text("📦", style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${item.price}",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Quantity Controls
                Row(
                  children: [
                    _qtyBtn(
                      Icons.remove,
                      () => context.read<CartBloc>().add(
                        DecreaseQuantity(item.productId),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _qtyBtn(
                      Icons.add,
                      () => context.read<CartBloc>().add(
                        IncreaseQuantity(item.productId),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status & Delete
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                item.isSynced ? Icons.check_circle : Icons.cloud_upload,
                color: item.isSynced ? Colors.green : Colors.orange,
                size: 18,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () =>
                    context.read<CartBloc>().add(RemoveProduct(item.productId)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
