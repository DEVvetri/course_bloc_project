import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/presentation/product/bloc/product_bloc.dart';
import '../../core/presentation/product/bloc/product_event.dart';
import '../../core/data/product/models/product_model.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController categoryCtrl;
  late TextEditingController priceCtrl;

  String selectedEmoji = "📦";
  final List<String> emojiOptions = [
    "📦",
    "💻",
    "🔧",
    "📑",
    "🔋",
    "🖨️",
    "🚜",
    "🏗️",
    "💡",
  ];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product?.name ?? "");
    categoryCtrl = TextEditingController(text: widget.product?.category ?? "");
    priceCtrl = TextEditingController(
      text: widget.product?.price.toString() ?? "",
    );
    selectedEmoji = widget.product?.image ?? "📦";

    // Listener to update the Hero UI in real-time
    nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    categoryCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    final product = ProductModel(
      productId: widget.product?.productId ?? const Uuid().v4(),
      name: nameCtrl.text.trim(),
      category: categoryCtrl.text.trim(),
      price: double.tryParse(priceCtrl.text) ?? 0.0,
      image: selectedEmoji,
      rating: widget.product?.rating ?? 4.5,
    );

    if (widget.product == null) {
      context.read<ProductBloc>().add(AddProduct(product));
    } else {
      context.read<ProductBloc>().add(UpdateProduct(product));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final primaryBlue = const Color(0xFF1e3c72);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFC,
      ), // Light grey professional background
      appBar: AppBar(
        title: Text(isEdit ? "Update Inventory" : "New Procurement Entry"),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Visual Preview Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: primaryBlue.withOpacity(0.1),
                    child: Text(
                      selectedEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nameCtrl.text.isEmpty ? "Product Name" : nameCtrl.text,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  Text(
                    categoryCtrl.text.isEmpty
                        ? "General Category"
                        : categoryCtrl.text,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),

            // 2. Form Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ITEM IDENTITY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: nameCtrl,
                      label: "Formal Name",
                      icon: Icons.inventory_2_outlined,
                      validator: (v) =>
                          v!.isEmpty ? "Enter product name" : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: categoryCtrl,
                      label: "Department/Category",
                      icon: Icons.category_outlined,
                      onChanged: (v) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: priceCtrl,
                      label: "Unit Price (USD)",
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v!) == null
                          ? "Enter valid price"
                          : null,
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "SELECT ICON",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Emoji Picker
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: emojiOptions.length,
                        itemBuilder: (context, index) {
                          final emoji = emojiOptions[index];
                          final isSelected = selectedEmoji == emoji;
                          return GestureDetector(
                            onTap: () => setState(() => selectedEmoji = emoji),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryBlue : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryBlue
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 4. Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          isEdit ? "CONFIRM UPDATE" : "REGISTER ITEM",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1e3c72), size: 20),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1e3c72), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
