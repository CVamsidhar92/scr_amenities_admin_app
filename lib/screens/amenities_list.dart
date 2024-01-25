import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/edit_location.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:scr_amenities_admin/screens/mapsWebView.dart';
import 'package:scr_amenities_admin/screens/view_location.dart';
import 'dart:convert';

class AmenitiesList extends StatefulWidget {
  final String id;
  final String role;
  final String zone;
  final String division;
  final String section;
  final String stnName;
  final String amenityType;

  // Properties for the widget
  const AmenitiesList({
    Key? key,
    required this.id,
    required this.role,
    required this.zone,
    required this.division,
    required this.section,
    required this.stnName,
    required this.amenityType,
  }) : super(key: key);

  @override
  _AmenitiesListState createState() => _AmenitiesListState();
}

// Function to parse dynamic values to double
double parseDouble(dynamic value) {
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  } else if (value is num) {
    return value.toDouble();
  } else {
    return 0.0; // or throw an error, depending on your requirements
  }
}

class _AmenitiesListState extends State<AmenitiesList> {
  // State variables
  List<Map<String, dynamic>> dataa = [];
  late Future<List<Map<String, dynamic>>> amenitiesData;
  late Future<String> webviewUrl;
  bool isItemListVisible = false;
  List<Map<String, dynamic>> itemList = [];
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _accuracy = 0.0;
  List<String> nearestLocations = [];
  String? selectedPlatform;
  String? selectedLatitude;
  String? selectedLongitude;
  List<String> platforms = []; // List to store platforms
  List<DropdownMenuItem<String>> platformsDropdownItems = []; // Dropdown items

  @override
  void initState() {
    super.initState();
    amenitiesData = fetchData();
    webviewUrl = fetchWebviewUrl();
  }

  void refreshData() {
    setState(() {
      amenitiesData = fetchData();
    });
  }

  // Function to fetch the location name
  Future<String> fetchLocationName() async {
    final data = await amenitiesData;
    if (data.isNotEmpty) {
      return data[0]['location_name'] as String;
    } else {
      return '';
    }
  }

  // Function to get complete data
  Future<void> getCompleteData(String locationName) async {
    final String url = base_url + 'getstationalldetails';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'station': widget.stnName,
      }),
    );

    if (response.statusCode == 200) {
      print('API Response: ${response.body}');
      final List<dynamic> responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        setState(() {
          dataa = List<Map<String, dynamic>>.from(responseData);
        });
      } else {
        print('API Status: No data found.');
      }
    } else {
      print('API Error: ${response.statusCode}');
      // Handle error
    }
  }

  // Function to fetch platforms
  Future<List<Map<String, dynamic>>> fetchPlatforms(String station) async {
    final apiUrl = base_url + 'getplatforms';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'station': widget.stnName,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        final platformsData = responseData.map((item) {
          final platform = item['platform'] as String;
          final latitudeStr = item['latitude'];
          final longitudeStr = item['longitude'];

          final latitude = parseDouble(latitudeStr);
          final longitude = parseDouble(longitudeStr);

          return {
            'platform': platform,
            'latitude': latitude,
            'longitude': longitude,
          };
        }).toList();

        return platformsData;
      } else {
        throw Exception('Invalid data format received from API');
      }
    } else {
      throw Exception(
          'Failed to fetch platforms from API: ${response.statusCode}');
    }
  }

  // Function to fetch the webview URL
  Future<String> fetchWebviewUrl() async {
    final String url = base_url + 'getmapurl';
    final body = {
      'station': widget.stnName,
      'amenityType': widget.amenityType,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List && jsonData.isNotEmpty) {
          final firstMap = jsonData[0] as Map<String, dynamic>;
          final url = firstMap['url'] as String?;
          if (url != null && url.isNotEmpty) {
            return url;
          } else {
            throw Exception('URL not found in the API response');
          }
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
      return ''; // Return a default value when URL is not found
    }
  }

  // Function to fetch data
  Future<List<Map<String, dynamic>>> fetchData() async {
    final String url = base_url + 'getstalldetails';
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

          return data;
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
      return [];
    }
  }

  // Function to show a confirmation dialog for navigation
  Future<bool> showConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Navigation'),
          content: Text(
              'You are about to navigate to a third-party application. Do you want to continue?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel navigation
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm navigation
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    return result ??
        false; // Return false if the dialog is dismissed without a choice
  }

  // Function to fetch item data
  Future<List<Map<String, dynamic>>> fetchItem() async {
    final String url = base_url + 'getItemsList';
    final body = {
      'amenityType': widget.amenityType,
    };

    try {
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final data = List<Map<String, dynamic>>.from(jsonData);
          return data;
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
      return [];
    }
  }

  // Function to delete an item
  Future<void> deleteItem(
    int id,
    String stationName,
    String amenityType,
    String locationName,
    dynamic latitude, // Use dynamic type
    dynamic longitude, // Use dynamic type
    BuildContext context,
  ) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);

    if (confirmDelete) {
      try {
        final String url = base_url + 'deleteAmenity';

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'station': stationName,
            'amenity_type': amenityType,
            'location_name': locationName,
            'latitude': parseDouble(latitude), // Convert to double
            'longitude': parseDouble(longitude), // Convert to double
          }),
        );

        if (response.statusCode == 200) {
          print('Data with ID $id deleted successfully');

          // Show a Snackbar to inform the user about the successful deletion.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data deleted successfully'),
            ),
          );

          // Update the amenitiesData Future after deletion
          setState(() {
            amenitiesData = fetchData();
          });
        } else {
          print('Failed to delete data with ID $id');
          // Handle the error case or show an error message to the user.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to Delete Data'),
            ),
          );
        }
      } catch (error) {
        print('Error: $error');
        // Handle any exceptions that may occur during the HTTP request.
      }
    }
  }

  // Function to show a delete confirmation dialog
  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the data?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    return result ??
        false; // Return false if the dialog is dismissed without a choice
  }

  // Widget build method
  @override
  Widget build(BuildContext context) {
    String id = widget.id;
    String role = widget.role;
    String zone = widget.zone;
    String division = widget.division;
    String section = widget.section;
    String station = widget.stnName;
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<Map<String, dynamic>>>(
          future: amenitiesData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final data = snapshot.data;
              if (data != null && data.isNotEmpty) {
                return Text(
                  data[0]['amenity_type'] as String,
                  style: TextStyle(
                    //color: Colors.red,
                    fontSize: 18,
                  ),
                );
              }
            }
            return Text(
              "Loading...",
              style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white, // Change the text color to blue
              ),
            ); // You can provide a loading state for the title.
          },
        ),
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
          Container(
            padding: EdgeInsets.all(16.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: amenitiesData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    if (data.isEmpty) {
                      return Center(
                        child: Text(
                          'No Amenities Found.',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              bool confirmNavigation =
                                  await showConfirmationDialog(context);

                              if (confirmNavigation) {
                                List<Map<String, dynamic>> data =
                                    await amenitiesData;

                                if (data.isNotEmpty) {
                                  Map<String, dynamic> item = data[
                                      0]; // Assuming you want the first item

                                  String? imgFile = item[
                                      'img_file']; // Store the value of img_file in a variable
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => MapsWebview(
                                        stnName: widget.stnName,
                                        amenityType: widget.amenityType,
                                        imgFile:
                                            imgFile, // Pass the variable to MapsWebview
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text("Bird's Eye View"),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final item = data[index];

                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: Card(
                                  child: Stack(
                                    children: [
                                      ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              item['location_name']
                                                      as String? ??
                                                  '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Text(
                                              item['location_details']
                                                      as String? ??
                                                  '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              item['station_name'] as String? ??
                                                  '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 30),
                                            Text(
                                              'Service: ${item['service_type'] as String? ?? ''}',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 5,
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                // Parse latitude and longitude as doubles
                                                double initialLatitude =
                                                    double.tryParse(
                                                            item['latitude'] ??
                                                                '0.0') ??
                                                        0.0;
                                                double initialLongitude =
                                                    double.tryParse(
                                                            item['longitude'] ??
                                                                '0.0') ??
                                                        0.0;

                                                // Pass the Amenity type, latitude, longitude, id, and location_name to the EditLocation screen.
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ViewLocation(
                                                            amenityType: data[0]
                                                                [
                                                                'amenity_type'], // Pass the Amenity type
                                                            initialLatitude:
                                                                initialLatitude, // Pass the initial latitude
                                                            initialLongitude:
                                                                initialLongitude, // Pass the initial longitude
                                                            itemId: item[
                                                                'id'], // Pass the item id
                                                            locationName: item[
                                                                'location_name'], // Pass the location_name
                                                            id: id,
                                                            role: role,
                                                            zone: zone,
                                                            division: division,
                                                            section: section,
                                                            station: station,
                                                            Img_file: item[
                                                                'img_file']),
                                                  ),
                                                );
                                              },
                                              child: Text('View'),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.blue),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Parse latitude and longitude as doubles
                                                double initialLatitude =
                                                    double.tryParse(
                                                            item['latitude'] ??
                                                                '0.0') ??
                                                        0.0;
                                                double initialLongitude =
                                                    double.tryParse(
                                                            item['longitude'] ??
                                                                '0.0') ??
                                                        0.0;

                                                // Pass the Amenity type, latitude, longitude, id, and location_name to the EditLocation screen.
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditLocation(
                                                            amenityType: data[0]
                                                                [
                                                                'amenity_type'], // Pass the Amenity type
                                                            initialLatitude:
                                                                initialLatitude, // Pass the initial latitude
                                                            initialLongitude:
                                                                initialLongitude, // Pass the initial longitude
                                                            itemId: item[
                                                                'id'], // Pass the item id
                                                            locationName: item[
                                                                'location_name'], // Pass the location_name
                                                            locationDetails: item[
                                                                'location_details'],
                                                            id: id,
                                                            role: role,
                                                            zone: zone,
                                                            division: division,
                                                            section: section,
                                                            station: station,
                                                            Img_file: item[
                                                                'img_file']),
                                                  ),
                                                );
                                              },
                                              child: Text('Edit'),
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.blue),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                              ),
                                            ),
                                            Visibility(
                                              visible: role ==
                                                  '0', // Show the "Delete" button only when role is equal to 0
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 4.0,
                                                    right:
                                                        8.0), // Add margin for the gap
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    // showDeleteAlert(context, item['id']);
                                                    deleteItem(
                                                        item['id'],
                                                        item['amenity_type'],
                                                        item['station_name'],
                                                        item['location_name'],
                                                        item['latitude'],
                                                        item['longitude'],
                                                        context);
                                                  },
                                                  child: Text('Delete'),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.red),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 2,
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error fetching data: ${snapshot.error}');
                  }
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
