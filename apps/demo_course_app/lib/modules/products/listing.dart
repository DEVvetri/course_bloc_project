// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:demo_course_app/core/presentation/cart/bloc/cart_bloc.dart';
import 'package:demo_course_app/core/presentation/cart/bloc/cart_event.dart';
import 'package:demo_course_app/core/data/product/models/cart_product_model.dart';
import 'package:demo_course_app/core/data/product/models/product_model.dart';
import 'package:demo_course_app/modules/products/add_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/presentation/product/bloc/product_bloc.dart';
import '../../core/presentation/product/bloc/product_event.dart';
import '../../core/presentation/product/bloc/product_state.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 300), () {
        context.read<ProductBloc>().add(SearchProducts(_searchController.text));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          return RefreshIndicator(onRefresh: ()async{
            context.read<ProductBloc>().add(SyncProducts());
          }, child:   CustomScrollView(
            slivers: [
              // 1. Modern AppBar with Search
              SliverAppBar(
                expandedHeight: 140.0,
                floating: true,
                pinned: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search products...",
                            prefixIcon: const Icon(Icons.search),

                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();

                                context.read<ProductBloc>().add(
                                  SearchProducts(""),
                                );
                              },
                            ),
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                title: const Text(
                  "Store Catalog",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () =>
                        context.read<ProductBloc>().add(SyncPendingProducts()),
                    icon: const Icon(Icons.sync, color: Colors.blueAccent),
                  ),
                ],
              ),

              // 2. Category Filter
              if (state is ProductLoaded && state.products.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // ✅ ALL FILTER (FIRST ITEM)
                        _buildCategoryChip(
                          "All",
                          isSelected: state.selectedFilter == 'All',
                        ),

                        // ✅ DYNAMIC CATEGORY FILTERS
                        ...state.products
                            .map((p) => p.category)
                            .toSet()
                            .toList()
                            .map((cat) {
                              return _buildCategoryChip(
                                cat,
                                isSelected: state.selectedFilter == cat,
                              );
                            })
                            .toList(),
                      ],
                    ),
                  ),
                ),

              // 3. Product Grid/List Logic
              if (state is ProductLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is ProductLoaded && state.products.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildProductCard(state.filteredProducts[index]),
                      childCount: state.filteredProducts.length,
                    ),
                  ),
                )
              else
                const SliverFillRemaining(
                  child: Center(child: Text("No products found")),
                ),
            ],
          )
        );
         
        
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
        ),
        label: const Text("Add Product"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String category, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (_) {
          if (category == 'All') {
            context.read<ProductBloc>().add(ClearFilters());
          } else {
            context.read<ProductBloc>().add(FilterByCategory(category));
          }
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(p.image, style: const TextStyle(fontSize: 30)),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(
                  p.isSynced ? Icons.check_circle : Icons.cloud_upload,
                  size: 16,
                  color: p.isSynced ? Colors.green : Colors.orange,
                ),
              ],
            ),
            subtitle: Text("₹${p.price} • ${p.category}"),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Edit")),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
              onSelected: (val) {
                if (val == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditProductScreen(product: p),
                    ),
                  );
                } else {
                  context.read<ProductBloc>().add(DeleteProduct(p.productId));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      final cartProduct = CartProductModel(
                        productId: p.productId,
                        name: p.name,
                        price: p.price,
                        quantity: 1,
                        updatedAt: DateTime.now().millisecondsSinceEpoch,
                      );

                      context.read<CartBloc>().add(AddCartProduct(cartProduct));

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${p.name} added to cart"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Add Cart"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Buy Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
