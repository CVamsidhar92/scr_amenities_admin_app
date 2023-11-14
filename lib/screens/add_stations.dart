import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/stations_list.dart';

class AddStation extends StatefulWidget {
  final String id;
  const AddStation({Key? key,required this.id}) : super(key: key);

  @override
  State<AddStation> createState() => _AddStationState();
}

class _AddStationState extends State<AddStation> {
  TextEditingController zoneController = TextEditingController();
  TextEditingController divisionController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController stationNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  Future<void> saveStationData() async {
    try {
      final response = await http.post(
        Uri.parse(base_url + 'poststn'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'zone': zoneController.text,
          'division': divisionController.text,
          'section': sectionController.text,
          'station_name': stationNameController.text,
          'code': codeController.text,
          'category': categoryController.text,
          'created_by':widget.id
        }),
      );

      if (response.statusCode == 200) {
        // Handle the success case
        print('Station data saved successfully');

        // Show a SnackBar to inform the user about the successful submission
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Station data saved successfully'),
          ),
        );

        // Navigate to the station list screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => StationsList(id:widget.id),
          ),
        );
      } else {
        // Handle the error case
        print('Failed to save station data');
        // You can show an error message or handle the error as needed
      }
    } catch (error) {
      print('Error: $error');
      // Handle any exceptions that may occur during the HTTP request.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Station'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: zoneController,
                decoration: InputDecoration(
                  labelText: 'Zone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: divisionController,
                decoration: InputDecoration(
                  labelText: 'Division',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: sectionController,
                decoration: InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: stationNameController,
                decoration: InputDecoration(
                  labelText: 'Station Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Call the function to save station data
                    saveStationData();
                  },
                  child: Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
