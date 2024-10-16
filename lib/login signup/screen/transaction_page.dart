import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // For PDF generation
import 'package:printing/printing.dart'; // For PDF export

class TransactionList extends StatefulWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String? _searchQuery;

  // Sales data to be displayed and exported
  List<Map<String, dynamic>> salesData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Transactions'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Search Field
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
                // Date Picker Button
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );

                    if (pickedDate != null) {
                      // If a date was picked, update the selectedDate variable
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    } else {
                      // If the user canceled the date picker, you can optionally handle it here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("No date selected")),
                      );
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
              stream: _getFilteredSales(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching sales transactions.',
                        style: TextStyle(color: Colors.red)),
                  );
                }

                final sales = snapshot.data?.docs ?? [];

                if (sales.isEmpty) {
                  return const Center(
                    child: Text('No sales found.',
                        style: TextStyle(color: Colors.blueAccent)),
                  );
                }

                salesData = sales.map((sale) {
                  return {
                    'productName': sale['productName'],
                    'quantity': sale['quantity'],
                    'price': sale['price'],
                    'saleData': sale['saleData'].toDate(),
                  };
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Product Name')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Sale Date')),
                          ],
                          rows: salesData
                              .map((sale) => DataRow(cells: [
                            DataCell(Text(sale['productName'])),
                            DataCell(Text(sale['quantity'].toString())),
                            DataCell(Text(sale['price'].toString())),
                            DataCell(Text(sale['saleData'].toString())),
                          ]))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _exportToPDF, // Call the export function
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export to PDF'),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stream to get filtered sales based on product name and date
  Stream<QuerySnapshot> _getFilteredSales() {
    CollectionReference sales = FirebaseFirestore.instance.collection('sales');
    Query query = sales;

    // Filter by product name
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      query = query
          .where('productName', isGreaterThanOrEqualTo: _searchQuery)
          .where('productName', isLessThanOrEqualTo: '$_searchQuery\uf8ff');
    }

    // Filter by selected date
    if (_selectedDate != null) {
      // Set the start and end of the selected day for filtering
      DateTime startOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 0, 0, 0);
      DateTime endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);

      Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
      Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

      query = query
          .where('saleData', isGreaterThanOrEqualTo: startTimestamp)
          .where('saleData', isLessThanOrEqualTo: endTimestamp);
    }

    return query.snapshots();
  }

  // Function to export table data to PDF
  Future<void> _exportToPDF() async {
    final pdf = pw.Document();

    // Create a table in the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: ['Product Name', 'Quantity', 'Price', 'Sale Date'],
            data: salesData.map((sale) {
              return [
                sale['productName'],
                sale['quantity'].toString(),
                sale['price'].toString(),
                sale['saleData'].toString(),
              ];
            }).toList(),
          );
        },
      ),
    );

    // Save the PDF and trigger the download
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
