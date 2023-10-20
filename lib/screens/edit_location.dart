import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EditLocation extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final int itemId;
  String amenityType;
  String locationName;

  EditLocation({
    required this.initialLatitude,
    required this.initialLongitude,
    required this.itemId,
    required this.amenityType,
    required this.locationName,
  });

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  GoogleMapController? mapController;
  Set<Marker> markers = Set();

  double updatedLatitude = 0.0;
  double updatedLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with initial values.
    latitudeController.text = widget.initialLatitude.toString();
    longitudeController.text = widget.initialLongitude.toString();
    updatedLatitude = widget.initialLatitude;
    updatedLongitude = widget.initialLongitude;
    // Add a marker at the initial latitude and longitude.
    markers.add(
      Marker(
        markerId: MarkerId('marker_id'),
        position: LatLng(widget.initialLatitude, widget.initialLongitude),
      ),
    );
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
            // Input fields for Amenity Type and Location Name in the same row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: widget.amenityType),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Amenity Type',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: widget.locationName),
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Location Name',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Input fields for Edit Latitude and Edit Longitude in the same row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latitudeController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Edit Latitude',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: longitudeController,
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Edit Longitude',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Update the text fields with the current latitude and longitude.
                  latitudeController.text = updatedLatitude.toString();
                  longitudeController.text = updatedLongitude.toString();
                  // Move the map camera to the updated position.
                  mapController?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(updatedLatitude, updatedLongitude),
                    ),
                  );
                  // Update the marker position.
                  updateMarker();
                },
                child: Text('Update Location'),
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.initialLatitude, widget.initialLongitude),
                  zoom: 20.0, // Initial zoom level
                ),
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                onCameraMove: (CameraPosition position) {
                  // Update the latitude and longitude when the map camera moves.
                  updatedLatitude = position.target.latitude;
                  updatedLongitude = position.target.longitude;
                  // Update the text fields.
                  latitudeController.text = updatedLatitude.toString();
                  longitudeController.text = updatedLongitude.toString();
                  // Update the marker position.
                  updateMarker();
                },
                markers: markers,
                zoomControlsEnabled: true, // Enable zoom controls
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateMarker() {
    // Update the marker position.
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('marker_id'),
        position: LatLng(updatedLatitude, updatedLongitude),
      ),
    );
    setState(() {}); // Rebuild the widget to update the marker position.
  }
}
