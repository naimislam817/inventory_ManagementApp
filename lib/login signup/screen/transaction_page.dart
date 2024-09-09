import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String? _searchQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Page'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
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
                // Date Picker Button with Icon
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.blueAccent),
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
                const SizedBox(width: 10),
                // Display Selected Date
                Text(
                  _selectedDate != null
                      ? "${_selectedDate!.toLocal()}".split(' ')[0]
                      : 'Select Date',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder(
              stream: _getFilteredTransactions(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching transactions.',
                        style: TextStyle(color: Colors.red)),
                  );
                }

                final transactions = snapshot.data?.docs ?? [];

                if (transactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions found.',
                        style: TextStyle(color: Colors.blueAccent)),
                  );
                }

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.inventory, color: Colors.white),
                        ),
                        title: Text(
                          transaction['productName'],
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${transaction['quantity']}',
                                style: TextStyle(color: Colors.black54)),
                            Text('Price: \$${transaction['price']}',
                                style: TextStyle(color: Colors.black54)),
                            Text(
                              'Purchase Date: ${transaction['purchaseDate'].toDate().toLocal().toString()}',
                              style: TextStyle(color: Colors.black54),
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
    );
  }

  Stream<QuerySnapshot> _getFilteredTransactions() {
    CollectionReference transactions =
    FirebaseFirestore.instance.collection('products');

    Query query = transactions;

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
}
