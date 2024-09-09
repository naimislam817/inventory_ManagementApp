import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeletedProductsPage extends StatefulWidget {
  const DeletedProductsPage({Key? key}) : super(key: key);

  @override
  _DeletedProductsPageState createState() => _DeletedProductsPageState();
}

class _DeletedProductsPageState extends State<DeletedProductsPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<List<Map<String, dynamic>>> _fetchDeletedProducts() async {
    // Fetch deleted products from Firestore
    final snapshot = await FirebaseFirestore.instance.collection('deleted_products').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deleted Products'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Range Selector
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _startDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      _startDate != null ? "Start Date: ${_startDate!.toLocal().toString().split(' ')[0]}" : "Select Start Date",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _endDate = pickedDate.add(const Duration(days: 1));
                        });
                      }
                    },
                    child: Text(
                      _endDate != null ? "End Date: ${_endDate!.toLocal().toString().split(' ')[0]}" : "Select End Date",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display Table
            Expanded(
              child: FutureBuilder(
                future: _fetchDeletedProducts(),
                builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No deleted products found.'));
                  } else {
                    final products = snapshot.data!;
                    final filteredProducts = products.where((product) {
                      DateTime deletionDate = (product['deletedAt'] as Timestamp).toDate();
                      // Only include products deleted within the selected date range
                      return (deletionDate.isAfter(_startDate ?? DateTime(2000)) &&
                          deletionDate.isBefore(_endDate ?? DateTime.now()));
                    }).toList();

                    if (filteredProducts.isEmpty) {
                      return const Center(child: Text('No products found for the selected date range.'));
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Product Name')),
                          DataColumn(label: Text('Quantity')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Deleted At')),
                        ],
                        rows: filteredProducts.map((product) {
                          return DataRow(
                            cells: [
                              DataCell(Text(product['productName'] ?? '')),
                              DataCell(Text(product['quantity'].toString())),
                              DataCell(Text(product['price'].toString())),
                              DataCell(Text((product['deletedAt'] as Timestamp).toDate().toLocal().toString())),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
