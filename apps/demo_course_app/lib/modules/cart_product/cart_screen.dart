import 'package:demo_course_app/core/presentation/cart/bloc/cart_bloc.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_event.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_state.dart';
import 'package:demo_course_app/modules/cart_product/widget/empty.dart';
import 'package:demo_course_app/modules/cart_product/widget/items.dart';
import 'package:demo_course_app/modules/cart_product/widget/summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CartView();
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "My Shopping Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.blueAccent),
            onPressed: () => context.read<CartBloc>().add(SyncCart()),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded) {
            if (state.cart.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CartBloc>().add(SyncCartFromFirebase());
                },
                child: ListView(
                  children: const [SizedBox(height: 400), EmptyCart()],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<CartBloc>().add(SyncCartFromFirebase());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: state.cart.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) =>
                          CartItemTile(item: state.cart[index]),
                    ),
                  ),
                ),
                CartSummary(cart: state.cart),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
