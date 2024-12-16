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

  // Placeholder for the Save as Draft feature
void _saveAsDraft() async {
  // Validate inputs before saving
  if (nameController.text.isEmpty ||
      locationController.text.isEmpty ||
      dateController.text.isEmpty ||
      timeController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please fill out all fields")),
    );
    return;
  }

  // Create the draft event data
  final draftEvent = {
    'id': Uuid().v4(),
    'name': nameController.text.trim(),
    'description': descriptionController.text.trim(),
    'location': locationController.text.trim(),
    'date': dateController.text.trim(),
    'time': timeController.text.trim(),
    'category': "" // Add more categories as needed
  };

  // Save the event as a draft in SQLite
  await DatabaseHelper.instance.insertEvent(draftEvent);

  // Notify the user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Event saved as draft")),
  );

  // Optionally, go back to the previous page after saving
  Navigator.of(context).pop();
}


  // Function to create the event in Firestore
  Future<void> _createEvent() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    var uuid = Uuid();
    final String eventId = uuid.v4();  // Generates a random UUID (v4)


    // Basic validation
    if (nameController.text.isEmpty ||
        locationController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    // Create the event
    final event = {
      'id': eventId,
      'name': nameController.text.trim(),
      'author': userId,
      'location': locationController.text.trim(),
      'date': dateController.text.trim(),
      'time': timeController.text.trim(),
      'description':descriptionController.text.trim(),
      'gifts': [],
      'coming': [],
      'category':""
    };

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .set(event);

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
        title: Text("Create Event"),
      ),
      body: Padding(
        
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
              labelText: "Event description",
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
            Spacer(),
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
    );
  }
}
