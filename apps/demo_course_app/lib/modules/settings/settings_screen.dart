// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_course_app/modules/auth/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool isLoading = true;
  bool isEditing = false;
  String email = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    setState(() {
      email = data?['email'] ?? user.email ?? '';
      _nameController.text = data?['name'] ?? '';
      _addressController.text = data?['address'] ?? '';
      isLoading = false;
    });
  }

  Future<void> updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);
    await _firestore.collection('users').doc(user.uid).update({
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
    });

    setState(() {
      isEditing = false;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: Colors.blueAccent),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isEmpty ? "User Name" : _nameController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Account Details",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Divider(height: 30),
          _buildTextField(
            label: "Full Name",
            controller: _nameController,
            icon: Icons.person_outline,
            enabled: isEditing,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: "Shipping Address",
            controller: _addressController,
            icon: Icons.location_on_outlined,
            enabled: isEditing,
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          // Email remains read-only for security
          _buildTextField(
            label: "Email Address",
            controller: TextEditingController(text: email),
            icon: Icons.email_outlined,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: enabled ? Colors.blue.withOpacity(0.05) : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (isEditing) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() => isEditing = false);
                loadProfile();
              },
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: updateProfile,
              child: const Text("Save Changes"),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          await _auth.signOut();
          if (mounted)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text(
          "Logout from Account",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
