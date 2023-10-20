import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/edit_location.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class AmenitiesList extends StatefulWidget {
  final String stnName;
  final String amenityType;

  const AmenitiesList({
    Key? key,
    required this.stnName,
    required this.amenityType,
  }) : super(key: key);

  @override
  _AmenitiesListState createState() => _AmenitiesListState();
}

class _AmenitiesListState extends State<AmenitiesList> {
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

  Future<String> fetchLocationName() async {
    final data = await amenitiesData;
    if (data.isNotEmpty) {
      return data[0]['location_name'] as String;
    } else {
      return '';
    }
  }

  Future<void> getCompleteData(String locationName) async {
    final String url = base_url + '/getstationalldetails';

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

  Future<List<Map<String, dynamic>>> fetchPlatforms(String station) async {
    final apiUrl = base_url + '/getplatforms';

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
          final latitude = double.tryParse(item['latitude'] as String) ?? 0.0;
          final longitude = double.tryParse(item['longitude'] as String) ?? 0.0;
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

  Future<String> fetchWebviewUrl() async {
    final String url = base_url + '/getmapurl';
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
    final String url = base_url + '/getstalldetails';
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
    final String url = base_url + '/getItemsList';
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

  Future<void> fetchNearestLocations(String selectedPlatform) async {
    final String nearestLocations = base_url + '/getnearestLocations';

    final body = {
      'station': widget.stnName,
      'platform': selectedPlatform,
    };
  }

  @override
  Widget build(BuildContext context) {
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
                "Loading..."); // You can provide a loading state for the title.
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
          // Background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  "assets/background.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
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
                          FutureBuilder<String>(
                            future: webviewUrl,
                            builder: (context, urlSnapshot) {
                              final showAerialViewButton =
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
                                  child: Text('View On Map'),
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
                                              item['location_name'] as String? ?? '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                              ),
                                            ),
                                            Text(
                                              item['location_details']
                                                  as String? ?? '',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              item['station_name'] as String? ?? '',
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
  right: 0,
  child: Container(
    margin: EdgeInsets.only(right: 8.0),
    child: ElevatedButton(
  onPressed: () {
    // Parse latitude and longitude as doubles
    double initialLatitude = double.tryParse(item['latitude'] ?? '0.0') ?? 0.0;
    double initialLongitude = double.tryParse(item['longitude'] ?? '0.0') ?? 0.0;
    
    // Pass the Amenity type, latitude, longitude, id, and location_name to the EditLocation screen.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditLocation(
          amenityType:  data[0]['amenity_type'], // Pass the Amenity type
          initialLatitude: initialLatitude, // Pass the initial latitude
          initialLongitude: initialLongitude, // Pass the initial longitude
          itemId: item['id'], // Pass the item id
          locationName: item['location_name'], // Pass the location_name
        ),
      ),
    );
  },
  child: Text('Edit'),
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.blue),
    foregroundColor: MaterialStateProperty.all(Colors.white),
  ),
)

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
