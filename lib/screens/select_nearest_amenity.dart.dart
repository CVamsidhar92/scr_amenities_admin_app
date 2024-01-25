import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui'; // For backdrop filter

class GridPoint {
  final double latitude;
  final double longitude;

  GridPoint({required this.latitude, required this.longitude});

  factory GridPoint.fromJson(Map<String, dynamic> json) {
    return GridPoint(
      latitude: double.parse(json['latitude'] as String),
      longitude: double.parse(json['longitude'] as String),
    );
  }
}

class SelectNearestAmenity extends StatefulWidget {
  final String stnName;
  final String amenityType;

  const SelectNearestAmenity({
    Key? key,
    required this.stnName,
    required this.amenityType,
    required String locationName,
    required double currentLatitude,
    required double currentLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) : super(key: key);

  @override
  _SelectNearestAmenityState createState() => _SelectNearestAmenityState();
}

class _SelectNearestAmenityState extends State<SelectNearestAmenity> {
  late Future<List<Map<String, dynamic>>> amenitiesData;
  late Future<String> webviewUrl;
  bool isItemListVisible = false;
  List<Map<String, dynamic>> itemList = [];
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _accuracy = 0.0;
  late Future<List<GridPoint>> gridPoints;

  @override
  void initState() {
    super.initState();
    amenitiesData = fetchData();
    webviewUrl = fetchWebviewUrl();
    gridPoints = fetchGridPoints();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _accuracy = position.accuracy;
        });

        print('Latitude: $_latitude');
        print('Longitude: $_longitude');
        print('Accuracy: ${position.accuracy} meters');
      } catch (e) {
        print(e);
      }
    } else if (status.isDenied) {
      print('Location permission is denied.');
    } else if (status.isPermanentlyDenied) {
      print('Location permission is permanently denied.');
    }
  }

  Future<List<GridPoint>> fetchGridPoints() async {
    final String gridPointsUrl =
        base_url + 'getgridviewpoints'; // Change URL as needed

    final body = {
      'station': widget.stnName,
    };
    try {
      final response =
          await http.post(Uri.parse(gridPointsUrl), body: body); // Use http.post here
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List) {
          final gridPointList =
              jsonData.map((json) => GridPoint.fromJson(json)).toList();

          // Print grid points
          for (var gridPoint in gridPointList) {
            print(
                'Grid Point - Latitude: ${gridPoint.latitude}, Longitude: ${gridPoint.longitude}');
          }

          return gridPointList;
        } else {
          throw Exception('Invalid data format received from API');
        }
      } else {
        throw Exception(
            'Failed to fetch grid points from API: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching grid points: $error');
      return [];
    }
  }

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

  Future<void> openGoogleChrome(String url) async {
    final chromeUrl = 'googlechrome://navigate?url=$url';
    try {
      await launch(chromeUrl);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to launch Google Chrome.'),
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

  Future<void> openGoogleMaps(
    double destLatitude,
    double destLongitude,
    String locationName,
  ) async {
    final gridPointList = await gridPoints;
    if (gridPointList.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No grid points available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Find the nearest grid point
    GridPoint nearestGridPoint = gridPointList[0];
    double minDistance = double.infinity;
    for (final gridPoint in gridPointList) {
      final distance = Geolocator.distanceBetween(
        _latitude,
        _longitude,
        gridPoint.latitude,
        gridPoint.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearestGridPoint = gridPoint;
      }
    }

    final url =
        'https://www.google.com/maps/dir/${nearestGridPoint.latitude},${nearestGridPoint.longitude}/$destLatitude,$destLongitude';

    try {
      // Navigate to the SelectNearestAmenity screen with necessary data
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to open Google Maps.'),
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

  Future<void> showItemListModal(String itemId) async {
    itemList = await fetchItem();
    print(itemList); // Print the fetched data
    setState(() {
      isItemListVisible = itemList.isNotEmpty;
    });
  }

  void _showBottomCard() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Nearest Amenity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                DropdownButton<String>(
                  // Implement your dropdown logic here
                  // Example:
                  items: <String>['Option 1', 'Option 2', 'Option 3']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearest Amenity'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: amenitiesData,
          builder: (context, snapshot) {
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
                    FutureBuilder<String>(
                      future: webviewUrl,
                      builder: (context, urlSnapshot) {
                        final showAerialViewButton =
                            snapshot.connectionState == ConnectionState.done &&
                                snapshot.hasData &&
                                data.isNotEmpty &&
                                urlSnapshot.connectionState ==
                                    ConnectionState.done &&
                                urlSnapshot.hasData &&
                                urlSnapshot.data!.isNotEmpty;

                        if (showAerialViewButton) {
                          return ElevatedButton(
                            onPressed: () async {
                              String url = await webviewUrl;
                              if (url.isNotEmpty) {
                                openGoogleChrome(url);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Error'),
                                      content: Text('URL not found.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            child: Text('Aerial View'),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
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
                                        item['location_name'] as String,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                      Text(
                                        item['location_details'] as String,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        item['station_name'] as String,
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
                                        item['amenity_type'] as String,
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
                                  right: 100,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8.0),
                                    child: isItemListVisible
                                        ? ElevatedButton(
                                            onPressed: () {
                                              showItemListModal(item['id']);
                                            },
                                            child: Text('Item List'),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.green),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final latitude =
                                            item['latitude'] != null
                                                ? double.parse(
                                                    item['latitude'] as String)
                                                : 0.0;
                                        final longitude =
                                            item['longitude'] != null
                                                ? double.parse(
                                                    item['longitude'] as String)
                                                : 0.0;
                                        final accuracy =
                                            item['accuracy'] != null
                                                ? double.parse(
                                                    item['accuracy'] as String)
                                                : 0.0;
                                        openGoogleMaps(
                                          latitude,
                                          longitude,
                                          item['location_name'] as String,
                                        );
                                      },
                                      child: Text('Direction'),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blue),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 2,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error fetching data: ${snapshot.error}');
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomCard,
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
}
