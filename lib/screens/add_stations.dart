// Import necessary packages and files
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:scr_amenities_admin/screens/stations_list.dart';

// Define a StatefulWidget for the AddStation screen
class AddStation extends StatefulWidget {
  final String id;
  final String role;

  // Constructor to receive data when navigating to this screen
  const AddStation({Key? key, required this.id, required this.role})
      : super(key: key);

  @override
  State<AddStation> createState() => _AddStationState();
}

// Define the state for the AddStation screen
class _AddStationState extends State<AddStation> {
  // Global key for the form to access form properties
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  TextEditingController zoneController = TextEditingController();
  TextEditingController divisionController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController stationNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  // Selected category and categories list for dropdown
  String selectedCategory = '-Select-'; // Default value
  List<String> categories = ['-Select-']; // Default value

  @override
  void initState() {
    super.initState();
    // Fetch category values when the screen is initialized
    fetchCategories();
  }

  // Function to fetch category values from the backend
  Future<void> fetchCategories() async {
    final String url = base_url + '/getcatgvalues';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Decode the JSON response and update the categories list
        List<dynamic> catgValues = jsonDecode(response.body);
        setState(() {
          categories = catgValues
              .map<String>((value) => value['category'].toString())
              .toList();
          categories.insert(0, '-Select-'); // Add the default value
        });
      } else {
        print('Failed to fetch categories'); // Handle the error case
      }
    } catch (error) {
      print('Error: $error'); // Handle any exceptions during the HTTP request
    }
  }

  // Function to save station data to the backend
  Future<void> saveStationData() async {
    final String url = base_url + '/poststations';

    // Create a map containing station data
    Map<String, dynamic> data = {
      'zone': zoneController.text,
      'division': divisionController.text,
      'section': sectionController.text,
      'station_name': stationNameController.text,
      'code': codeController.text,
      'category': selectedCategory,
      'created_by': widget.id,
    };

    // Send a POST request with station data to the backend
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Show a success message and navigate to the StationsList screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station Created Successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                StationsList(id: widget.id, role: widget.role)),
      );
    } else {
      print('Failed to send data to the backend'); // Handle the error case
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Station',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue, // Set background color to blue
        actions: <Widget>[
          InkWell(
            onTap: () {
              // Navigate to the Login screen when logout is pressed
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Login(),
              ));
            },
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.logout_outlined,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: zoneController,
                  decoration: InputDecoration(
                    labelText: 'Zone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter zone';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: divisionController,
                  decoration: InputDecoration(
                    labelText: 'Division',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter division';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: sectionController,
                  decoration: InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter section';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: stationNameController,
                  decoration: InputDecoration(
                    labelText: 'Station Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter station';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: 'Code',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter code';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value == '-Select-') {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 16.0),
                                Text("Saving Station data..."),
                              ],
                            ),
                          ),
                        );

                        // Call the function to save station data
                        await saveStationData();

                        // Hide the loading indicator
                        ScaffoldMessenger.of(context).clearSnackBars();
                      }
                    },
                    child: Text('Save'),
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
