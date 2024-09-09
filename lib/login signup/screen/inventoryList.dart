import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_product_page.dart'; // Import the EditProductPage

class InventoryList extends StatelessWidget {
  const InventoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory List'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
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
              return const Center(child: Text('Error fetching inventory.'));
            }

            final products = snapshot.data?.docs ?? [];

            if (products.isEmpty) {
              return const Center(
                child: Text(
                  'No products found.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                String? imageUrl;

                // Safely try to get the imageUrl field
                try {
                  imageUrl = product.get('imageUrl');
                } catch (e) {
                  imageUrl = null; // If the field doesn't exist, fallback to null
                }

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        if (imageUrl != null)
                          Image.network(
                            imageUrl ?? 'https://via.placeholder.com/150',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'images/placeholder.png',
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        else
                          Image.asset(
                            'images/placeholder.png',
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(width: 10), // Add spacing between image and text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['productName'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.shopping_bag, color: Colors.blue, size: 18),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Quantity: ${product['quantity']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money, color: Colors.green, size: 18),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Price: \$${product['price']}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.orange, size: 18),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Purchase Date: ${product['purchaseDate'].toDate().toLocal()}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Navigate to EditProductPage to update product
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditProductPage(
                                      productId: product.id,
                                      currentName: product['productName'],
                                      currentQuantity: product['quantity'],
                                      currentPrice: product['price'].toDouble(),
                                      currentPurchaseDate: product['purchaseDate'],
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Show confirmation dialog before deletion
                                _showDeleteConfirmationDialog(context, product.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Function to show the confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog and do nothing
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                try {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(productId)
                      .delete(); // Delete the product

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete product: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
