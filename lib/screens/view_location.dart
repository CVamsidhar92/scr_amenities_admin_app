import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/home.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

class ViewLocation extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final int itemId;
  String amenityType;
  String locationName;
  String zone;
  String division;
  String section;
  String station;
  String id;
  String role;

  ViewLocation(
      {required this.initialLatitude,
      required this.initialLongitude,
      required this.itemId,
      required this.amenityType,
      required this.locationName,
      required this.zone,
      required this.division,
      required this.section,
      required this.station,
      required this.id,
      required this.role});

  @override
  _ViewLocationState createState() => _ViewLocationState();
}

class _ViewLocationState extends State<ViewLocation> {
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  GoogleMapController? mapController;
  Set<Marker> markers = Set();
  double updatedLatitude = 0.0;
  double updatedLongitude = 0.0;
  MapType currentMapType = MapType.normal;
  LocationData? currentLocation;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    latitudeController.text = widget.initialLatitude.toString();
    longitudeController.text = widget.initialLongitude.toString();
    updatedLatitude = widget.initialLatitude;
    updatedLongitude = widget.initialLongitude;

    markers.add(
      Marker(
        markerId: MarkerId('marker_id'),
        position: LatLng(widget.initialLatitude, widget.initialLongitude),
        draggable: false,
      ),
    );

    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await permission.Permission.location.status;
    if (status.isDenied) {
      await permission.Permission.location.request();
    }

    if (await permission.Permission.location.isGranted) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Location',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
  children: [
    Expanded(
      child: TextField(
        controller: TextEditingController(text: widget.amenityType ?? ""),
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Amenity Type',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 16.0, 10.0),
          alignLabelWithHint: true,
        ),
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: TextField(
        controller: TextEditingController(text: widget.locationName ?? ""),
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Location Name',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          contentPadding: EdgeInsets.fromLTRB(10.0, 5.0, 16.0, 10.0),
          alignLabelWithHint: true,
        ),
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
                      // updatedLatitude = position.target.latitude;
                      // updatedLongitude = position.target.longitude;
                      // latitudeController.text = updatedLatitude.toString();
                      // longitudeController.text = updatedLongitude.toString();
                      // updateMarker();
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
          ],
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
      draggable: false, // Set draggable to false to make the marker non-movable
    ),
  );

  setState(() {});
}


  void updateLocation(int itemId, double latitude, double longitude,String station,String amenityType) async {
    final url = base_url + '/changelocationpin';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'itemId': itemId.toString(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'station':widget.station,
        'amenity_type':widget.amenityType
      },
    );

    if (response.statusCode == 200) {
      showSnackbar('Location updated successfully');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Home(
              id: widget.id,
              role:widget.role,
              zone: widget.zone,
              division: widget.division,
              section: widget.section,
              selectedStation: widget.station),
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
