// Import necessary Flutter and Dart packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scr_amenities_admin/screens/amenities_list.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:scr_amenities_admin/screens/porterWebview.dart';
import 'package:scr_amenities_admin/screens/tadWebview.dart';
import 'package:scr_amenities_admin/screens/create_amenity.dart';

// Define the Home widget
class Home extends StatefulWidget {
    // Properties passed to the widget through the constructor
  final String id;
  final String role;
  final String zone;
  final String division;
  final String section;
  final String selectedStation;

  // Constructor to initialize properties
  const Home(
      {Key? key,
      required this.id,
      required this.role,
      required this.zone,
      required this.division,
      required this.section,
      required this.selectedStation})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

// Define the state for the Home widget
class _HomeState extends State<Home> {
  List<Map<String, dynamic>> dataa = [];

  // Static data for different types of amenities
  final List<Map<String, dynamic>> staticData = [
    {
      'id': '01',
      'title': 'ATVMs',
      'value': 'ATVMs',
      'image': 'assets/images/atvms.jpeg',
    },
    {
      'id': '02',
      'title': 'Booking Counter',
      'value': 'Booking Counter',
      'image': 'assets/images/booking.jpeg',
    },
    {
      'id': '03',
      'title': 'PRS Counter',
      'value': 'PRS Counter',
      'image': 'assets/images/prs.jpeg',
    },
    {
      'id': '04',
      'title': 'Parcel Office',
      'value': 'Parcel Office',
      'image': 'assets/images/pr.jpg',
    },
    {
      'id': '05',
      'title': 'Waiting Hall',
      'value': 'Waiting Hall',
      'image': 'assets/images/wh.jpeg',
    },
    {
      'id': '06',
      'title': 'Divyangjan Facility',
      'value': 'Divyangjan Facility',
      'image': 'assets/images/dv.jpg',
    },
    {
      'id': '07',
      'title': 'Parking',
      'value': 'Parking',
      'image': 'assets/images/parking.jpeg',
    },
    {
      'id': '08',
      'title': 'Out Gates',
      'value': 'Out Gates',
      'image': 'assets/images/outgate.jpeg',
    },
    {
      'id': '09',
      'title': 'Stair Case',
      'value': 'Stair Case',
      'image': 'assets/images/str.jpeg',
    },
    {
      'id': '10',
      'title': 'Escalator',
      'value': 'Escalator',
      'image': 'assets/images/esc.jpeg',
    },
    {
      'id': '11',
      'title': 'Lift',
      'value': 'Lift',
      'image': 'assets/images/lift.jpeg',
    },
    {
      'id': '12',
      'title': 'Cloak Rooms',
      'value': 'Cloak Rooms',
      'image': 'assets/images/cr.jpeg',
    },
    {
      'id': '13',
      'title': 'Multi Purpose Stall',
      'value': 'Multi Purpose Stall',
      'image': 'assets/images/mps.jpeg',
    },
    {
      'id': '14',
      'title': 'Help Desk',
      'value': 'Help Desk',
      'image': 'assets/images/helpdesk.jpeg',
    },
    {
      'id': '15',
      'title': '1 Station 1 Product',
      'value': 'One Station One Product',
      'image': 'assets/images/osop.jpeg',
    },
    {
      'id': '16',
      'title': 'Drinking Water',
      'value': 'Drinking Water',
      'image': 'assets/images/dw.jpeg',
    },
    {
      'id': '17',
      'title': 'Catering Stall',
      'value': 'Catering',
      'image': 'assets/images/catg.jpeg',
    },
    {
      'id': '18',
      'title': 'Train Arr/Dep',
      'value': 'TAD',
      'image': 'assets/images/trad.jpeg',
    },
    {
      'id': '19',
      'title': 'Retiring Room',
      'value': 'Retiring Room',
      'image': 'assets/images/rr.jpeg',
    },
    {
      'id': '20',
      'title': 'Bus Stop',
      'value': 'Bus Stop',
      'image': 'assets/images/bus.jpeg',
    },
    {
      'id': '21',
      'title': 'Restrooms',
      'value': 'Toilets',
      'image': 'assets/images/washrooms.jpg',
    },
    {
      'id': '22',
      'title': 'Medical',
      'value': 'Medical',
      'image': 'assets/images/medical.jpeg',
    },
    {
      'id': '23',
      'title': 'Taxi Stand',
      'value': 'Taxi Stand',
      'image': 'assets/images/taxi.jpeg',
    },
    {
      'id': '24',
      'title': 'Book Stall',
      'value': 'Book Stall',
      'image': 'assets/images/Book Stall.png',
    },
    {
      'id': '25',
      'title': 'Wheel Chair',
      'value': 'Wheel Chair',
      'image': 'assets/images/wheelchair.png',
    },
    {
      'id': '26',
      'title': 'Porter Information',
      'value': 'Porter',
      'image': 'assets/images/porter.jpeg',
    },
     {
       'id':'27',
      'title': 'ATM',
      'value': 'ATM',
      'image': 'assets/images/atm.png',
    },
  ];

  // Function to fetch dynamic amenity data from the API
  Future<void> fetchData() async {
        // API endpoint URL
    final String url = base_url + '/stnam';

    // Send a POST request to the API
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'StnName': widget.selectedStation,
      }),
    );

    // Check if the API response is successful (status code 200)
    if (response.statusCode == 200) {
            // Parse the response JSON
      print('API Response: ${response.body}');
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Check the status from the API response
      if (responseData['status'] == 'ok') {
                // Extract data from the API response
        final List<dynamic> parsedData = responseData['data'];

        // Update the state with the fetched data
        setState(() {
          dataa = List<Map<String, dynamic>>.from(parsedData);
        });
      } else {
                // Log the API status if not 'ok'
        print('API Status: ${responseData['status']}');
      }
    } else {
            // Log the API error if the status code is not 200
      print('API Error: ${response.statusCode}');
      // Handle error
    }
  }

  // Function to fetch TAD (Train Arrival/Departure) data
  Future<String> fetchtaddata() async {
        // TAD API endpoint URL
    final String url = base_url + '/gettadurl';

        // Request body parameters
    final body = {'station': widget.selectedStation, 'amenityType': 'TAD'};

    try {
            // Send a POST request to the TAD API
      final response = await http.post(Uri.parse(url), body: body);
            // Check if the TAD API response is successful (status code 200)
      if (response.statusCode == 200) {
                // Decode the JSON data from the TAD API response
        final jsonData = json.decode(response.body);
                // Check if the data is in the expected format
        if (jsonData is List && jsonData.isNotEmpty) {
                    // Extract the URL from the first map in the response
          final firstMap = jsonData[0] as Map<String, dynamic>;
          final url = firstMap['url'] as String?;
                    // Check if the URL is not null or empty
          if (url != null && url.isNotEmpty) {
                        // Return the fetched URL
            return url;
          } else {
                        // Throw an exception if the URL is not found in the API response
            throw Exception('URL not found in the API response');
          }
        } else {
                    // Throw an exception if the data format is invalid
          throw Exception('Invalid data format received from API');
        }
      } else {
                // Throw an exception if the status code is not 200
        throw Exception(
            'Failed to fetch data from API: ${response.statusCode}');
      }
    } catch (error) {
            // Return an empty string when the URL is not found or an error occurs
      return ''; // Return a default value when URL is not found
    }
  }

  // Override to perform tasks when the widget is first created
  @override
  void initState() {
    super.initState();
        // Fetch dynamic amenity data when the widget is initialized
    fetchData();
  }

  // Override to perform tasks when the widget is updated
@override
void didUpdateWidget(covariant Home oldWidget) {
  super.didUpdateWidget(oldWidget);
      // Fetch dynamic amenity data when the widget is updated
  fetchData();
}


  // Override to build the UI for the Home widget
  @override
  Widget build(BuildContext context) {
        // Extract properties from the widget
    String id = widget.id;
    String role = widget.role;
    String zone = widget.zone;
    String division = widget.division;
    String section = widget.section;
    String selectedStation = widget.selectedStation;

    // Calculate card dimensions based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardsPerRow = 3;
    final cardSpacing = 120.0;
    final cardWidth =
        (screenWidth - (cardsPerRow - 1) * cardSpacing) / cardsPerRow;
    final cardHeight = cardWidth + 30;

    // Build the main Scaffold containing the app bar, welcome message, and amenity cards
    return Scaffold(
      appBar: AppBar(
        title: Text('Home',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue, 
        actions: <Widget>[
     // Logout action in the app bar
          InkWell(
            onTap: () {
      // Navigate to the login screen when clicked
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
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Welcome To $selectedStation Station',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: List.generate(
                  (staticData.length / cardsPerRow).ceil(),
                  (rowIndex) {
                    final int startIdx = rowIndex * cardsPerRow;
                    final int endIdx =
                        (startIdx + cardsPerRow > staticData.length)
                            ? staticData.length
                            : startIdx + cardsPerRow;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          staticData.sublist(startIdx, endIdx).map((item) {
                        // final bool isTaxi = item['value'] == 'Taxi Stand';
                        if (
                            // isTaxi ||
                            dataa.any((apiItem) =>
                                apiItem['amenity_type']
                                    .toString()
                                    .toLowerCase() ==
                                item['value'].toString().toLowerCase())) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (item['value'] == 'Porter') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PorterWebview(
                                        url:
                                            'https://scrailway.co.in/webops/php/liscporterforapp/#/inputreq',
                                      ),
                                    ),
                                  );
                                } else if (item['value'] == 'TAD') {
                                  final tadUrl = await fetchtaddata();
                                  if (tadUrl.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TadWebview(
                                          url: tadUrl,
                                          station: selectedStation,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AmenitiesList(
                                        id: id,
                                        role:role,
                                        stnName: selectedStation,
                                        zone: zone,
                                        division: division,
                                        section: section,
                                        amenityType: item['value'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: cardWidth,
                                height: cardHeight,
                                child: Card(
                                  elevation: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        item['image'],
                                        fit: BoxFit.contain,
                                        height: cardWidth * 0.6,
                                        width: cardWidth * 0.6,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox.shrink(); // Hide the card
                        }
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        
          FloatingActionButton(
            mini: true,
            onPressed: () {
              // Navigate to the CreateAmenity screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAmenity(
                    id: id,
                    role:role,
                    zone: zone,
                    division: division,
                    section: section,
                    station: selectedStation,
                  ), // Replace with the actual CreateAmenity screen
                ),
              );
            },
            child: Icon(Icons.add),
            
          ),
          SizedBox(height: 6),
            Text('Add Amenity',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold,color: Colors.blue)),
          
        ],
      ),
    );
  }
}
