import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'dart:io'; // Import File

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  DateTime? selectedDate;
  bool _isLoading = false; // Loading state for when the product is being added

  // For Image selection
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;
      });
    }
  }

  // Upload Image to Firebase Storage
  Future<String?> _uploadImageToFirebase() async {
    if (_imageFile == null) {
      // No image selected, skip upload
      return null;
    }

    try {
      final file = File(_imageFile!.path);
      final storageRef = FirebaseStorage.instance.ref();
      final filePath = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child(filePath);

      // Upload the file to Firebase Storage
      await imageRef.putFile(file);

      // Get the download URL
      return await imageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
      return null;
    }
  }

  // Select Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Add Product to Firestore
  Future<void> addProduct() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final productName = productNameController.text.trim();
    final quantity = int.tryParse(quantityController.text);
    final price = double.tryParse(priceController.text);
    final imageUrl = await _uploadImageToFirebase(); // Upload image and get URL

    // Debug prints for tracking values
    print('Product Name: $productName');
    print('Quantity: $quantity');
    print('Price: $price');
    print('Purchase Date: $selectedDate');
    print('Image URL: $imageUrl');

    if (imageUrl == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image upload failed. Please try again.')));
      setState(() {
        _isLoading = false; // Stop loading if image upload fails
      });
      return;
    }

    // Ensure all fields are filled correctly
    if (productName.isNotEmpty &&
        quantity != null &&
        price != null &&
        selectedDate != null) {
      await FirebaseFirestore.instance.collection('products').add({
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'purchaseDate': selectedDate,
        'imageUrl': imageUrl, // Store the image URL if available
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }

    setState(() {
      _isLoading = false; // Stop loading after adding the product
    });
  }

  @override
  void dispose() {
    productNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Product Name Input
                        TextField(
                          controller: productNameController,
                          decoration: InputDecoration(
                            labelText: 'Product Name',
                            prefixIcon: const Icon(Icons.production_quantity_limits, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Quantity Input
                        TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            prefixIcon: const Icon(Icons.format_list_numbered, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        // Price Input
                        TextField(
                          controller: priceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            prefixIcon: const Icon(Icons.attach_money, color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        // Image Picker Button and UI
                        Column(
                          children: [
                            _imageFile != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(_imageFile!.path),
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Text('No image selected'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Pick from Gallery'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Take Photo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Select Date Button
                        ElevatedButton.icon(
                          onPressed: () => _selectDate(context),
                          icon: const Icon(Icons.calendar_today),
                          label: Text(selectedDate != null
                              ? 'Purchase Date: ${selectedDate!.toLocal()}'.split(' ')[0]
                              : 'Select Purchase Date'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add Product Button
                        ElevatedButton.icon(
                          onPressed: addProduct,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add Product'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
