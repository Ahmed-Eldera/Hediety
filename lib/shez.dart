import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EventCreationPage extends StatefulWidget {
  @override
  _EventCreationPageState createState() => _EventCreationPageState();
}

class _EventCreationPageState extends State<EventCreationPage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate; // Only the Date
  TimeOfDay? _selectedTime; // Only the Time

  // Pick Date
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Pick Time
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Save Event to Firestore
  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      try {
        String eventId = Uuid().v4();
        String ownerId = FirebaseAuth.instance.currentUser!.uid;

        // Convert Date and Time to Firestore Timestamp
        Timestamp dateTimestamp = Timestamp.fromDate(
          DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day),
        );

        Timestamp timeTimestamp = Timestamp.fromDate(
          DateTime(1970, 1, 1, _selectedTime!.hour, _selectedTime!.minute),
        );
        await FirebaseFirestore.instance.collection("users").doc(ownerId).update({'events':FieldValue.arrayUnion([eventId])});
        await FirebaseFirestore.instance.collection('events').doc(eventId).set({
          'id': eventId,
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
          'date': dateTimestamp, // Save date separately
          'time': timeTimestamp, // Save time separately
          'gifts': [],
          'ownerId': ownerId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event Created Successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and pick date & time')),
      );
    }
  }
  Future<void> createEvent(Map<String, dynamic> eventData) async {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Add event to Firestore and get its ID
  final eventDocRef =
      await FirebaseFirestore.instance.collection('events').add(eventData);

  // Update the user's document to include this event ID
  await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
    'events': FieldValue.arrayUnion([eventDocRef.id])
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                  validator: (value) => value!.isEmpty ? 'Enter event name' : null,
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Enter location' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Enter description' : null,
                ),
              
                
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Pick Date'
                          : '${_selectedDate!.toLocal()}'.split(' ')[0],
                    ),
                    ElevatedButton(
                      onPressed: _pickDate,
                      child: Text('Select Date'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime == null
                          ? 'Pick Time'
                          : _selectedTime!.format(context),
                    ),
                    ElevatedButton(
                      onPressed: _pickTime,
                      child: Text('Select Time'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveEvent,
                  child: Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}