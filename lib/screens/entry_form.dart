import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gm_appointments/screens/base_url.dart';
import 'package:gm_appointments/screens/home.dart';
import 'package:gm_appointments/screens/login.dart'; // Import the Login screen
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class CreateForm extends StatefulWidget {
  const CreateForm({Key? key}) : super(key: key);

  @override
  _CreateFormState createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  final TextEditingController _officerNameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  DateTime? _selectedDateTime;

  Future<void> _selectDateAndTime(BuildContext context) async {
  final DateTime now = DateTime.now();
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDateTime ?? now,
    firstDate: now, // Set the minimum date to the current date
    lastDate: DateTime(2101),
  );
  if (picked != null) {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }
}


Future<void> _createAppointment() async {
  final String officerName = _officerNameController.text;
  final String purpose = _purposeController.text;
  
   // Check if officerName is null or empty
  if (officerName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter the officer name.'),
      ),
    );
    return; // Exit the function early
  }

  // Check if purpose is null or empty
  if (purpose.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter the purpose.'),
      ),
    );
    return; // Exit the function early
  }

  // Check if _selectedDateTime is null before using it
  if (_selectedDateTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please select a date and time.'),
      ),
    );
    return; // Exit the function early
  }

 
  final String dateTime =
      DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDateTime!);

  // Define your API endpoint for creating appointments
  final String apiUrl = base_url + 'dataentry';

  // Create a JSON request body
  final Map<String, dynamic> requestBody = {
    'officerName': officerName,
    'purpose': purpose,
    'dateTime': dateTime,
  };

  try {
    // Make the HTTP POST request to insert the data
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    // Print the response status code and body
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Data insertion was successful
      // You can navigate to a success screen or take other actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment created successfully.'),
        ),
      );

      // Navigate to the Home Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Home(userRole: 1)),
      );
    } else {
      // Handle other HTTP response codes (e.g., 400, 500) here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create appointment. Please try again.'),
        ),
      );
    }
  } catch (error) {
    // Handle exceptions, such as network errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error. Please check your connection.'),
      ),
    );
  }
}
// Function to log out and clear local storage
  Future<void> _logout() async {
    // Clear the local storage (remove isLoggedIn)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // Navigate to the Login Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );
  }



  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Appointment'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Call the logout function on button press
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.03,
            vertical: screenSize.height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _officerNameController,
                decoration: InputDecoration(
                  labelText: 'Officer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the officer name';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenSize.height * 0.02),
              TextFormField(
                controller: _purposeController,
                maxLines: null, // Allow for multiple lines of input
                textAlignVertical:
                    TextAlignVertical.top, // Start the cursor from the top
                decoration: InputDecoration(
                  labelText: 'Purpose',
                  labelStyle: TextStyle(
                    // Adjust the label's position to the right
                    fontSize: 14.0,
                    color: Colors.black, // You can set the desired color
                  ),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(
                      12.0, 12.0, 12.0, 100.0), // Adjust the padding as needed
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purpose';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenSize.height * 0.02),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDateTime == null
                      ? ''
                      : DateFormat('dd-MM-yyyy hh:mm a')
                          .format(_selectedDateTime!),
                ),
                onTap: () => _selectDateAndTime(context),
                decoration: InputDecoration(
                  labelText: 'Date and Time',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_selectedDateTime == null) {
                    return 'Please select a date and time';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenSize.height * 0.02),
              ElevatedButton(
                onPressed: _createAppointment,
                child: Text(
                  'Create Appointment',
                  style: TextStyle(fontSize: screenSize.width * 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
