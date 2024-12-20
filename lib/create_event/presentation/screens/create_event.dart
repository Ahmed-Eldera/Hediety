import 'package:flutter/material.dart';
import 'package:hediety/colors.dart';
import 'package:provider/provider.dart';
import 'package:hediety/UserProvider.dart';
import 'package:hediety/widgets/MyButton.dart';
import 'package:hediety/database_helper.dart';
import 'package:hediety/widgets/MyTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class EventCreationPage extends StatefulWidget {
  @override
  _EventCreationPageState createState() => _EventCreationPageState();
}

class _EventCreationPageState extends State<EventCreationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory; // Variable to store selected category

  // Save as Draft feature
  void _saveAsDraft() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;

    if (nameController.text.isEmpty ||
        locationController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    final draftEvent = {
      'id': Uuid().v4(),
      'name': nameController.text.trim(),
      'author': userId, // Add the author's ID
      'location': locationController.text.trim(),
      'date': dateController.text.trim(),
      'time': timeController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory, // Include category
    };

    await DatabaseHelper.instance.insertEvent(draftEvent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Event saved as draft")),
    );

    Navigator.of(context).pop();
  }

  // Function to create the event in Firestore
  Future<void> _createEvent() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    var uuid = Uuid();
    final String eventId = uuid.v4(); // Generates a random UUID (v4)

    if (nameController.text.isEmpty ||
        locationController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    final event = {
      'id': eventId,
      'name': nameController.text.trim(),
      'author': userId, // Add the author's ID
      'location': locationController.text.trim(),
      'date': dateController.text.trim(),
      'time': timeController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': selectedCategory, // Include category
      'gifts': [],
      'coming': [],
    };

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .set(event);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'events': FieldValue.arrayUnion([eventId])});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Event Created Successfully!")),
      );
      Navigator.of(context).pop(); // Go back after successful creation
    } catch (e) {
      print("Error creating event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create event. Try again.")),
      );
    }
  }

  // Function to pick a date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Function to pick a time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        iconTheme: IconThemeData(color: gold),
        backgroundColor: bg,
        title: Text(
          "Create Event",
          style: TextStyle(color: gold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MyTextField(
                controller: nameController,
                labelText: "Event Name",
                hintText: "Enter the event name",
              ),
              SizedBox(height: 16),
              MyTextField(
                controller: descriptionController,
                labelText: "Event Description",
                hintText: "Enter the description (optional)",
              ),
              SizedBox(height: 16),
              MyTextField(
                controller: locationController,
                labelText: "Location",
                hintText: "Enter the location",
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: MyTextField(
                    controller: dateController,
                    labelText: "Date",
                    hintText: "Pick a date",
                  ),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickTime,
                child: AbsorbPointer(
                  child: MyTextField(
                    controller: timeController,
                    labelText: "Time",
                    hintText: "Pick a time",
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Work', 'Personal', 'Family'].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  filled: true,
                  fillColor: lighter,
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: gold),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: a7mar),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: MyButton(
                      label: "Save as Draft",
                      onPressed: _saveAsDraft,
                      backgroundColor: gold,
                      textColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: MyButton(
                      label: "Create",
                      onPressed: _createEvent,
                      backgroundColor: a7mar,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
