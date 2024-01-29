import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data'; // Add this import for Uint8List
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img; // Add this import
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/login.dart';

class MapsWebview extends StatefulWidget {
  String stnName;
  String amenityType;
  String? imgFile;

  MapsWebview(
      {Key? key,
      required this.stnName,
      required this.amenityType,
      required this.imgFile});

  @override
  _MapsWebviewState createState() => _MapsWebviewState();
}

class _MapsWebviewState extends State<MapsWebview> {
  bool loading = true;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  late CameraPosition initialCameraPosition;
  late bool isSatelliteView = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Check location permissions
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
    fetchData();
  }

  Future<void> fetchData() async {
    final String url =
        base_url + 'getstalldetails'; // Replace with your API URL
    final body = {
      'stnName': widget.stnName,
      'amenityType': widget.amenityType,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final data = List<Map<String, dynamic>>.from(jsonData);

          // Use FutureBuilder to handle the asynchronous operation
          setState(() {
            loading = true;
          });

          final markers = await _generateMarkers(data);

          setState(() {
            _markers = markers;
            if (_markers.isNotEmpty) {
              initialCameraPosition = CameraPosition(
                target: _markers.first.position,
                zoom: 16,
              );
            } else {
              // Default position if no markers are available
              initialCameraPosition = CameraPosition(
                target: LatLng(0, 0),
                zoom: 10,
              );
            }
            loading = false;
          });
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch data from API: $error'),
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
  }

  Future<Uint8List> _loadMarkerIcon(String assetName,
      {int width = 50, int height = 50}) async {
    ByteData byteData = await rootBundle.load('assets/images/$assetName');
    Uint8List markerIconBytes = byteData.buffer.asUint8List();

    // Resize the image using the image package
    img.Image markerImage = img.decodeImage(markerIconBytes)!;
    img.Image resizedImage =
        img.copyResize(markerImage, width: width, height: height);

    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  Future<Set<Marker>> _generateMarkers(
      List<Map<String, dynamic>> locations) async {
    List<Marker> markers = await Future.wait(locations.map((location) async {
      LatLng position = LatLng(
        double.parse(location['latitude']),
        double.parse(location['longitude']),
      );

      // print('Marker Position: $position');
      // print('Image File: ${widget.imgFile}');

      Uint8List markerIcon;

      // Choose marker icon based on amenityType
      if (widget.amenityType == 'ATVMs') {
        markerIcon = await _loadMarkerIcon('atvms.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Booking Counter') {
        markerIcon =
            await _loadMarkerIcon('booking.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'PRS Counter') {
        markerIcon = await _loadMarkerIcon('prs.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Parcel Office') {
        markerIcon = await _loadMarkerIcon('pr.jpg', width: 80, height: 80);
      } else if (widget.amenityType == 'Waiting Hall') {
        markerIcon = await _loadMarkerIcon('wh.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Divyangjan Facility') {
        markerIcon = await _loadMarkerIcon('dv.jpg', width: 80, height: 80);
      } else if (widget.amenityType == 'Parking') {
        markerIcon =
            await _loadMarkerIcon('parking.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Out Gates') {
        markerIcon =
            await _loadMarkerIcon('outgate.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Stair Case') {
        markerIcon = await _loadMarkerIcon('str.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Escalator') {
        markerIcon = await _loadMarkerIcon('esc.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Lift') {
        markerIcon = await _loadMarkerIcon('lift.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Cloak Rooms') {
        markerIcon = await _loadMarkerIcon('cr.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Multi Purpose Stall') {
        markerIcon = await _loadMarkerIcon('mps.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Help Desk') {
        markerIcon =
            await _loadMarkerIcon('helpdesk.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'One Station One Product') {
        markerIcon = await _loadMarkerIcon('osop.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Drinking Water') {
        markerIcon = await _loadMarkerIcon('dw.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Catering') {
        markerIcon = await _loadMarkerIcon('catg.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Retiring Room') {
        markerIcon = await _loadMarkerIcon('rr.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Bus Stop') {
        markerIcon = await _loadMarkerIcon('bus.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Toilets') {
        markerIcon =
            await _loadMarkerIcon('washrooms.jpg', width: 80, height: 80);
      } else if (widget.amenityType == 'Medical') {
        markerIcon =
            await _loadMarkerIcon('medical.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Taxi Stand') {
        markerIcon = await _loadMarkerIcon('taxi.jpeg', width: 80, height: 80);
      } else if (widget.amenityType == 'Book Stall') {
        markerIcon =
            await _loadMarkerIcon('Book Stall.png', width: 80, height: 80);
      } else if (widget.amenityType == 'Wheel Chair') {
        markerIcon =
            await _loadMarkerIcon('wheelchair.png', width: 80, height: 80);
      } else if (widget.amenityType == 'ATM') {
        markerIcon = await _loadMarkerIcon('atm.png', width: 80, height: 80);
      } else {
        // Default icon if amenityType doesn't match any condition
        markerIcon = Uint8List.fromList([]);
      }

      return Marker(
        markerId: MarkerId(location['id'].toString()),
        position: position,
        icon: BitmapDescriptor.fromBytes(markerIcon),
        infoWindow: InfoWindow(
          title: location['location_name'],
          snippet: location['location_details'],
        ),
      );
    }));

    print('Generated Markers: $markers');

    return markers.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web View'),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    Login(), // Replace with the actual login screen widget
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
                        fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_markers.isNotEmpty)
            GoogleMap(
              mapType: isSatelliteView ? MapType.satellite : MapType.normal,
              initialCameraPosition: initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: _markers,
              myLocationEnabled: true,
              compassEnabled: false,
              onTap: (LatLng latLng) {
                _onMapTapped(latLng);
              },
            ),
          if (loading)
            Center(
              child: SpinKitCircle(
                color: Colors.white,
                size: 50.0,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {
          setState(() {
            isSatelliteView = !isSatelliteView;
          });
        },
        child: Icon(
          isSatelliteView ? Icons.map : Icons.satellite,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _onMapTapped(LatLng latLng) {
    // Iterate through markers to check if any marker is tapped
    for (Marker marker in _markers) {
      // Convert the marker position to LatLng
      LatLng markerPosition = marker.position;

      // Define a threshold for considering it as a tap on the marker
      double threshold = 0.0001; // Adjust as needed

      // Check if the tapped position is close to the marker position
      if ((markerPosition.latitude - latLng.latitude).abs() < threshold &&
          (markerPosition.longitude - latLng.longitude).abs() < threshold) {
        // Handle marker tap
        if (marker.infoWindow != null) {
          _showCustomInfoWindow(marker);
        }
        break;
      }
    }
  }

void _showCustomInfoWindow(Marker marker) async {
  // Extract the location details from your data
  Map<String, dynamic> locationData = /* Get your location data based on marker */ {};

  print('Image File1: ${widget.imgFile}');

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        width: 200, // Set the width of the InfoWindow
        height: 200, // Set the height of the InfoWindow
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locationData['location_name'] ?? '',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              locationData['location_details'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            // Show image if available
            if (widget.imgFile != null)
              Image(
                image: NetworkImage(base_url + widget.imgFile!),
                width: 150, // Set the width of the image
                height: 100, // Set the height of the image
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  return Center(
                    child: Text('Failed to load image'),
                  );
                },
              ),
            // Add more details or widgets as needed
          ],
        ),
      );
    },
  );
}


}
