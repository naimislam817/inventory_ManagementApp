import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_product_page.dart'; // Import the EditProductPage

class InventoryList extends StatefulWidget {
  const InventoryList({Key? key}) : super(key: key);

  @override
  _InventoryListState createState() => _InventoryListState();
}

class _InventoryListState extends State<InventoryList> {
  TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String? _searchQuery;

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Search Field with Blue Border and Style
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by product name',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                        filled: true,
                        fillColor: Colors.blue[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                          enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Date Picker Button with Darker Color and Larger Size
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.black87, size: 28),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Display Selected Date - Bold and prominent
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedDate != null
                        ? "Selected Date: ${_selectedDate!.toLocal()}".split(' ')[0]
                        : 'No Date Selected',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Larger font size for prominence
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: _getFilteredInventory(),
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

                      try {
                        imageUrl = product.get('imageUrl');
                      } catch (e) {
                        imageUrl = null;
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
                              const SizedBox(width: 10),
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
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredInventory() {
    CollectionReference products = FirebaseFirestore.instance.collection('products');
    Query query = products;

    // Filter by product name
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      query = query
          .where('productName', isGreaterThanOrEqualTo: _searchQuery)
          .where('productName', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    // Filter by selected date
    if (_selectedDate != null) {
      Timestamp startOfDay = Timestamp.fromDate(DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day));
      Timestamp endOfDay = Timestamp.fromDate(DateTime(
          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day)
          .add(Duration(days: 1)));

      query = query
          .where('purchaseDate', isGreaterThanOrEqualTo: startOfDay)
          .where('purchaseDate', isLessThan: endOfDay);
    }

    return query.snapshots();
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(productId)
                      .delete();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting product: $e'),
                    ),
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
