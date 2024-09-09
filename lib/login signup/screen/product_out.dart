import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductOutPage extends StatefulWidget {
  const ProductOutPage({Key? key}) : super(key: key);

  @override
  _ProductOutPageState createState() => _ProductOutPageState();
}

class _ProductOutPageState extends State<ProductOutPage> {
  String? selectedProductId;
  int quantityOut = 0;
  int availableStock = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Out'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Product to Deduct Stock',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildProductDropdown(),
            const SizedBox(height: 20),
            Text(
              'Available Stock: $availableStock',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildQuantityInput(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedProductId == null || quantityOut <= 0
                  ? null
                  : () {
                _updateStock();
              },
              child: const Text('Update Stock'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> productItems = snapshot.data!.docs.map((doc) {
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(doc['productName']),
          );
        }).toList();

        return DropdownButton<String>(
          value: selectedProductId,
          hint: const Text('Select a product'),
          items: productItems,
          onChanged: (value) {
            setState(() {
              selectedProductId = value;
              _getAvailableStock();
            });
          },
        );
      },
    );
  }

  Widget _buildQuantityInput() {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Quantity to Deduct',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          quantityOut = int.tryParse(value) ?? 0;
        });
      },
    );
  }

  Future<void> _getAvailableStock() async {
    if (selectedProductId == null) return;

    final doc = await FirebaseFirestore.instance.collection('products').doc(selectedProductId).get();
    if (doc.exists) {
      setState(() {
        availableStock = doc['quantity'];
      });
    }
  }

  Future<void> _updateStock() async {
    if (selectedProductId == null || quantityOut <= 0) return;

    final docRef = FirebaseFirestore.instance.collection('products').doc(selectedProductId);

    // Check available stock before deducting
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists && (docSnapshot['quantity'] as int) >= quantityOut) {
      await docRef.update({
        'quantity': FieldValue.increment(-quantityOut),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated successfully!')),
      );

      // Clear the selection
      setState(() {
        selectedProductId = null;
        quantityOut = 0;
        availableStock = 0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient stock available!')),
      );
    }
  }
}
