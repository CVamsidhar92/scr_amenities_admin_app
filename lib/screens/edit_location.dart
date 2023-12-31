// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/home.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

// Define the EditLocation widget
class EditLocation extends StatefulWidget {
    // Properties for initial data
  final double initialLatitude;
  final double initialLongitude;
  final int itemId;
  String amenityType;
  String locationName;
  String locationDetails;
  String zone;
  String division;
  String section;
  String station;
  String id;
  String role;

  // Constructor for the widget
  EditLocation(
      {required this.initialLatitude,
      required this.initialLongitude,
      required this.itemId,
      required this.amenityType,
      required this.locationName,
      required this.locationDetails,
      required this.zone,
      required this.division,
      required this.section,
      required this.station,
      required this.id,
      required this.role});

  @override
  _EditLocationState createState() => _EditLocationState();
}

// Define the state for the EditLocation widget
class _EditLocationState extends State<EditLocation> {
    // Global key for the form
  final _formKey = GlobalKey<FormState>();

    // Controllers for text fields
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController locationNameController = TextEditingController();
  TextEditingController locationDetailsController = TextEditingController();
   
    // Google Map related variables
  GoogleMapController? mapController;
  Set<Marker> markers = Set();
  double updatedLatitude = 0.0;
  double updatedLongitude = 0.0;
  MapType currentMapType = MapType.normal;
  LocationData? currentLocation;
  Location location = Location();

  // Override initState method for initialization
  @override
  void initState() {
    super.initState();

    // Set initial values for text fields and markers
    latitudeController.text = widget.initialLatitude.toString();
    longitudeController.text = widget.initialLongitude.toString();
    updatedLatitude = widget.initialLatitude;
    updatedLongitude = widget.initialLongitude;

    // Use default values if the original values are null
    locationNameController.text = widget.locationName ?? '';
    locationDetailsController.text = widget.locationDetails ?? '';

    markers.add(
      Marker(
        markerId: MarkerId('marker_id'),
        position: LatLng(widget.initialLatitude, widget.initialLongitude),
      ),
    );

    // Check and request location permission
    _checkLocationPermission();
  }

  // Function to check location permission
  Future<void> _checkLocationPermission() async {
    final status = await permission.Permission.location.status;
    if (status.isDenied) {
      await permission.Permission.location.request();
    }

    if (await permission.Permission.location.isGranted) {
      _getCurrentLocation();
    }
  }

  // Build method for creating the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Location',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: widget.station),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Station Name',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        contentPadding: EdgeInsets.fromLTRB(
                            10.0, 5.0, 16.0, 10.0), // Add left padding
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller:
                          TextEditingController(text: widget.amenityType),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Amenity Type',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        contentPadding: EdgeInsets.fromLTRB(
                            10.0, 5.0, 16.0, 10.0), // Add left padding
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: latitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        contentPadding: EdgeInsets.fromLTRB(
                            10.0, 5.0, 16.0, 10.0), // Add left padding
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: longitudeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        contentPadding: EdgeInsets.fromLTRB(
                            10.0, 5.0, 16.0, 10.0), // Add left padding
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: locationNameController,
                      initialValue: widget.locationName ?? '',
                      decoration: InputDecoration(
                        labelText: 'Location Name',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 5.0, 16.0, 10.0),
                        alignLabelWithHint: true,
                      ),
                      // Add validator for required validation
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location Name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: locationDetailsController,
                      initialValue: widget.locationDetails ?? '',
                      decoration: InputDecoration(
                        labelText: 'Location Details',
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 5.0, 16.0, 10.0),
                        alignLabelWithHint: true,
                      ),
                      // Add validator for required validation
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location Details is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    GoogleMap(
                      mapType: currentMapType,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            widget.initialLatitude, widget.initialLongitude),
                        zoom: 20.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                      },
                      onCameraMove: (CameraPosition position) {
                        updatedLatitude = position.target.latitude;
                        updatedLongitude = position.target.longitude;
                        latitudeController.text = updatedLatitude.toString();
                        longitudeController.text = updatedLongitude.toString();
                        updateMarker();
                      },
                      markers: markers,
                      zoomControlsEnabled: true,
                      myLocationButtonEnabled:
                          true, // Enable the default location button
                      myLocationEnabled:
                          true, // Show user's location as a blue dot on the map
                    ),
                    Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Adjust the padding as needed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            mini: true,
                            onPressed: () {
                              setState(() {
                                currentMapType =
                                    (currentMapType == MapType.normal)
                                        ? MapType.satellite
                                        : MapType.normal;
                              });
                            },
                            child: Icon(Icons.map, size: 20),
                          ),
                          if (currentLocation != null)
                            FloatingActionButton(
                              mini: true,
                              onPressed: () {
                                mapController?.animateCamera(
                                  CameraUpdate.newLatLng(
                                    LatLng(currentLocation!.latitude!,
                                        currentLocation!.longitude!),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.gps_fixed,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, update the location
                      mapController?.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(updatedLatitude, updatedLongitude),
                        ),
                      );

                      latitudeController.text = updatedLatitude.toString();
                      longitudeController.text = updatedLongitude.toString();

                      updateMarker();
                      updateLocation(
                        widget.itemId,
                        updatedLatitude,
                        updatedLongitude,
                        widget.station,
                        widget.amenityType,
                        locationNameController,
                        locationDetailsController,
                      );
                    }
                  },
                  child: Text('Update Location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateMarker() {
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId('marker_id'),
        position: LatLng(updatedLatitude, updatedLongitude),
      ),
    );
    setState(() {});
  }

  void updateLocation(
    int itemId,
    double latitude,
    double longitude,
    String station,
    String amenityType,
    TextEditingController locationNameController,
    TextEditingController locationDetailsController,
  ) async {
    final url = base_url + '/changelocationpin';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'itemId': itemId.toString(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'locationName': locationNameController.text ?? '',
        'locationDetails': locationDetailsController.text ?? '',
        'station': station,
        'amenity_type': amenityType,
      },
    );

    if (response.statusCode == 200) {
      showSnackbar('Location updated successfully');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Home(
            id: widget.id,
            role: widget.role,
            zone: widget.zone,
            division: widget.division,
            section: widget.section,
            selectedStation: widget.station,
          ),
        ),
      );
    } else {
      showSnackbar('Error updating location: ${response.body}');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _getCurrentLocation() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location service is disabled.');
        return;
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('Location permission is denied.');
          return;
        }
      }

      LocationData locationData = await location.getLocation();
      setState(() {
        currentLocation = locationData;
      });
    }
  }
}
