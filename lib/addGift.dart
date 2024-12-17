import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hediety/colors.dart';
import 'UserProvider.dart';

class AddGiftPage extends StatefulWidget {
  final String eventId; // ID of the event to which the gift belongs

  const AddGiftPage({required this.eventId, Key? key}) : super(key: key);

  @override
  State<AddGiftPage> createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = "Home Appliances"; // Default category
  final List<String> _categories = [
    "Home Appliances",
    "Electronics",
    "Fashion",
    "Food",
    "Books",
    "Other"
  ];

  bool _isSaving = false;

  Future<void> _saveGift() async {
    // Validate inputs
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Access the current user's ID from the Provider
    final String currentUserId = Provider.of<UserProvider>(context, listen: false).user!.id;

    // Generate a unique ID for the gift using uuid
    String giftId = Uuid().v4();

    // Prepare the gift data
    Map<String, dynamic> giftData = {
      "id": giftId,
      "name": _nameController.text.trim(),
      "price": _priceController.text.trim(),
      "description": _descriptionController.text.trim(),
      "category": _selectedCategory,
      "eventId": widget.eventId,
      "userId": currentUserId,
      "buyer": "", // Initially empty
      "status": "available",
      'pic':"" // Initially available
    };

    setState(() {
      _isSaving = true;
    });

    // Save to Firestore
    try {
      await FirebaseFirestore.instance.collection("gifts").doc(giftId).set(giftData);
      await FirebaseFirestore.instance.collection("events").doc(widget.eventId).update({'gifts':FieldValue.arrayUnion([giftId])});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift added successfully!")),
      );
      Navigator.pop(context); // Go back to the previous page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding gift: $e")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Add Gift",
          style: TextStyle(color: gold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Placeholder for image picker (to be implemented later)
              Container(
                height: 150,
                color: Colors.grey[800],
                child: Center(
                  child: Text(
                    "Image Placeholder (Image Picker to be added)",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Name Text Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              // Price Text Field
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              // Description Text Field
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              // Category Dropdown Menu
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                dropdownColor: Colors.grey[800],
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 24),
              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Add Gift",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
