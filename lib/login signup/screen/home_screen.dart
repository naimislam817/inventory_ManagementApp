import 'package:authentication_experiement/login%20signup/screen/pdf_generator.dart';
import 'package:authentication_experiement/login%20signup/screen/product_out.dart';
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
import 'deleted_products_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalProducts = 0;
  double totalPrice = 0.0;
  int totalSales = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  // Calculate total products, stock price, and sales
  Future<void> _calculateTotals() async {
    final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
    final salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();

    int productCount = 0;
    double priceSum = 0.0;
    int salesCount = 0;

    // Calculate total products and stock price
    for (var doc in productsSnapshot.docs) {
      final data = doc.data();
      productCount += (data['quantity'] as int);  // Sum product quantities
      priceSum += (data['price'] as double) * (data['quantity'] as int);
    }

    // Calculate total sales count
    for (var doc in salesSnapshot.docs) {
      salesCount += (doc['quantity'] as int);
    }

    setState(() {
      totalProducts = productCount;
      totalPrice = priceSum;
      totalSales = salesCount;
    });
  }

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

    Share.shareFiles([file.path], text: 'Here is your bill.');
  }

  void _signOut(BuildContext context) async {
    await AuthServices().signOut();
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
            onPressed: () => _signOut(context),
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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching product data.'));
            }

            final products = snapshot.data?.docs ?? [];
            int totalProducts = products.fold(
              0,
                  (total, product) => total + (product['quantity'] as int),
            );
            double totalPrice = products.fold(
              0.0,
                  (sum, product) => sum + (product['price'] as double) * (product['quantity'] as int),
            );

            return Column(
              children: [
                const SizedBox(height: 20),
                // Overview Section
                Card(
                  margin: const EdgeInsets.all(16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildOverviewItem('Total Products', totalProducts.toString(), Icons.inventory),
                        const SizedBox(height: 10),
                        _buildOverviewItem('Total Stock Price', totalPrice.toStringAsFixed(2), Icons.attach_money),
                        const SizedBox(height: 10),
                        _buildOverviewItem('Total Sales', totalSales.toString(), Icons.shopping_cart),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16.0),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
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
                      _buildMenuItem(
                        context,
                        icon: Icons.inventory,
                        label: 'Warehouse',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const InventoryList()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.list_alt,
                        label: 'View Transactions',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TransactionList()),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.remove_circle,
                        label: 'Product Out',
                        onTap: () {
                          // Navigate to Product Out page (create this separately)
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ProductOutPage()),
                          );
                        },
                      ),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to fetch transactions: $e')),
                            );
                          }
                        },
                      ),
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
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
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

  Widget _buildOverviewItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 30, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Text(
          '$title: $value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
