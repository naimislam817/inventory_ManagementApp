import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class BillPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const BillPage({Key? key, required this.transactions}) : super(key: key);

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  // Filter transactions based on the selected date range
  List<Map<String, dynamic>> get _filteredTransactions {
    if (_startDate == null || _endDate == null) return widget.transactions;
    return widget.transactions.where((transaction) {
      DateTime purchaseDate = (transaction['purchaseDate'] as Timestamp).toDate();
      return purchaseDate.isAfter(_startDate!) && purchaseDate.isBefore(_endDate!);
    }).toList();
  }

  // Generate and share the PDF
  Future<void> _generateAndSharePDF() async {
    final pdf = pw.Document();
    final transactions = _filteredTransactions;

    if (transactions.isEmpty) {
      // Show a message if no transactions are available for the selected date range
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No transactions available for the selected date range.")),
      );
      return;
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Product Bill',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.blue300,
                ),
                headerAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
                data: [
                  ['Product Name', 'Quantity', 'Price', 'Purchase Date'],
                  ...transactions.map((transaction) => [
                    transaction['productName'],
                    transaction['quantity'].toString(),
                    transaction['price'].toString(),
                    (transaction['purchaseDate'] as Timestamp).toDate().toLocal().toString(),
                  ])
                ],
              ),
            ],
          );
        },
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final file = File("${outputDir.path}/bill.pdf");
    await file.writeAsBytes(await pdf.save());

    Share.shareFiles([file.path], text: 'Here is your bill.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Bill'),
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
                      if (pickedDate != null && pickedDate != _startDate) {
                        setState(() {
                          _startDate = pickedDate;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text(_startDate != null ? "Start Date: ${_startDate!.toLocal().toString().split(' ')[0]}" : "Select Start Date"),
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
                      if (pickedDate != null && pickedDate != _endDate) {
                        setState(() {
                          _endDate = pickedDate.add(const Duration(days: 1));
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: Text(_endDate != null ? "End Date: ${_endDate!.toLocal().toString().split(' ')[0]}" : "Select End Date"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Purchase Date')),
                  ],
                  rows: _filteredTransactions.map((transaction) {
                    return DataRow(
                      cells: [
                        DataCell(Text(transaction['productName'])),
                        DataCell(Text(transaction['quantity'].toString())),
                        DataCell(Text(transaction['price'].toString())),
                        DataCell(Text((transaction['purchaseDate'] as Timestamp).toDate().toLocal().toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Generate PDF Button
            ElevatedButton(
              onPressed: _generateAndSharePDF,
              child: const Text('Generate PDF'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
