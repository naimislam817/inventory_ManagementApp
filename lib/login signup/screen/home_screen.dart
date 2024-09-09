import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../Services/authentication.dart';
import 'add_product.dart';
import 'bill_page.dart';
import 'inventoryList.dart';
import 'login.dart';
import 'transaction_page.dart';
import 'deleted_products_page.dart'; // Import the DeletedProductsPage

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Function to generate PDF and share it
  Future<void> _generateAndShareBill(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Bill PDF Example'),
        ),
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final file = File("${outputDir.path}/bill.pdf");

    await file.writeAsBytes(await pdf.save());

    // Share the generated PDF
    Share.shareFiles([file.path], text: 'Here is your bill.');
  }

  // Function to log out the user
  void _signOut(BuildContext context) async {
    await AuthServices().signOut();
    // After sign out, navigate to the login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management System'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context), // Call the sign-out function
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2, // Two items per row
          padding: const EdgeInsets.all(16.0),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // Add Product Button
            _buildMenuItem(
              context,
              icon: Icons.add_circle,
              label: 'Add Product',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddProductPage()),
                );
              },
            ),
            // View Inventory Button
            _buildMenuItem(
              context,
              icon: Icons.inventory,
              label: 'View Inventory',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const InventoryList()),
                );
              },
            ),
            // View Transactions Button
            _buildMenuItem(
              context,
              icon: Icons.list_alt,
              label: 'View Transactions',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TransactionPage()),
                );
              },
            ),
            // Generate Bill Button
            _buildMenuItem(
              context,
              icon: Icons.receipt,
              label: 'Generate Bill',
              onTap: () async {
                try {
                  final snapshot = await FirebaseFirestore.instance.collection('products').get();

                  final transactions = snapshot.docs.map((doc) {
                    final data = doc.data();
                    return {
                      'productName': data['productName'],
                      'quantity': data['quantity'],
                      'price': data['price'],
                      'purchaseDate': data['purchaseDate']
                    };
                  }).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BillPage(transactions: transactions),
                    ),
                  );
                } catch (e) {
                  // Handle errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to fetch transactions: $e')),
                  );
                }
              },
            ),
            // View Deleted Products Button
            _buildMenuItem(
              context,
              icon: Icons.delete,
              label: 'View Deleted Products',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DeletedProductsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
