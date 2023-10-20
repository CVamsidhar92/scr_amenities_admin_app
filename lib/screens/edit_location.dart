import 'package:flutter/material.dart';

class EditLocation extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  EditLocation({
    required this.initialLatitude,
    required this.initialLongitude,
  });

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with initial values.
    latitudeController.text = widget.initialLatitude.toString();
    longitudeController.text = widget.initialLongitude.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Latitude:',
              style: TextStyle(fontSize: 18),
            ),
            TextFormField(
              controller: latitudeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Latitude',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Edit Longitude:',
              style: TextStyle(fontSize: 18),
            ),
            TextFormField(
              controller: longitudeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Longitude',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Get the latitude and longitude as strings from the text controllers.
                String latitudeText = latitudeController.text;
                String longitudeText = longitudeController.text;

                // Check if the input is not empty and can be parsed to a double.
                if (latitudeText.isNotEmpty && longitudeText.isNotEmpty) {
                  double editedLatitude = double.parse(latitudeText);
                  double editedLongitude = double.parse(longitudeText);

                  // Here, you can implement the code to update the backend database
                  // with the edited latitude and longitude.
                  // You can send a request to your API to perform the update.

                  // After updating, you can navigate back to the previous screen.
                  Navigator.pop(context);
                } else {
                  // Handle invalid input (empty or non-numeric values).
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid Input'),
                        content: Text('Please enter valid latitude and longitude values.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
