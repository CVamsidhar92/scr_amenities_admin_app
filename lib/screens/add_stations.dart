import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:scr_amenities_admin/screens/stations_list.dart';

class AddStation extends StatefulWidget {
  final String id;
  final String role;
  const AddStation({Key? key, required this.id,required this.role}) : super(key: key);

  @override
  State<AddStation> createState() => _AddStationState();
}

class _AddStationState extends State<AddStation> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController zoneController = TextEditingController();
  TextEditingController divisionController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController stationNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  String selectedCategory = '-Select-'; // Default value

  Future<void> saveStationData() async {
    final String url = base_url + '/poststn';
    Map<String, dynamic> data = {
      'zone': zoneController.text,
      'division': divisionController.text,
      'section': sectionController.text,
      'station_name': stationNameController.text,
      'code': codeController.text,
      'category':
          selectedCategory, // Use selectedCategory instead of categoryController.text
      'created_by': widget.id,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Data sent successfully, show a success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station Created Successfully.'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
      // Navigate to the Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StationsList(id: widget.id,role:widget.role)),
      );
    } else {
      // Handle the error case
      print('Failed to send data to the backend');
      // You can show an error message to the user or perform error handling as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Station'),
         actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Login(),
              ));
            },
            child:Row(
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
                  items: [
                    '-Select-',
                    'NSG1',
                    'NSG2',
                    'NSG3',
                    'NSG4',
                    'NSG5',
                    'NSG6'
                  ].map((String category) {
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
                                Text("Saving station data..."),
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
