import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TextEditingController _searchController = TextEditingController();
  String? _searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Product Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();  // Trim extra spaces from search query
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _getFilteredTransactions(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching transactions.'));
                }

                final transactions = snapshot.data?.docs ?? [];

                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions found.'));
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(transaction['productName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${transaction['quantity']}'),
                            Text('Price: \$${transaction['price']}'),
                            Text('Purchase Date: ${transaction['purchaseDate'].toDate().toLocal()}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Add edit functionality
                                },
                              ),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.delete_outline),
                                title: Text('Delete'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // Add delete functionality
                                },
                              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add new transaction
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredTransactions() {
    CollectionReference transactions = FirebaseFirestore.instance.collection('products');

    Query query = transactions;

    // Apply search filter for product name
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      query = query
          .where('productName', isGreaterThanOrEqualTo: _searchQuery)
          .where('productName', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    return query.snapshots();
  }
}
