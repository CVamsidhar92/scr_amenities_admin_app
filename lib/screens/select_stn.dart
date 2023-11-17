import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:scr_amenities_admin/screens/stations_list.dart';
import 'package:scr_amenities_admin/screens/users_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'home.dart';

class SelectStn extends StatefulWidget {
  final String id;
  final String zone;
  final String division;
  final String section;
  final String role;
  const SelectStn(
      {Key? key,
      required this.id,
      required this.zone,
      required this.division,
      required this.section,
      required this.role})
      : super(key: key);

  @override
  State<SelectStn> createState() => _SelectStnState();
}

class _SelectStnState extends State<SelectStn> {
  String selectedStation = '';
  final myVersion = '1.5';
  List<dynamic> data = [];
  late BuildContext dialogContext;
  // GlobalKey to access the ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUpdates();
    print(widget.role);

    if (widget.role == '0') {
      getAllStations();
    } else {
      getData();
    }
  }

  Future<void> getUpdates() async {
    try {
      final data = {'name': myVersion};

      final String url = base_url + '/appversiondatafeeding';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      final result1 = json.decode(response.body);
      print(result1);

      if (myVersion != result1[0]['appversion']) {
        showDialog(
          context: context,
          barrierDismissible:
              false, // Set this to false to disable touching the background
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Please Update'),
              content: Text(
                'You must update the app to the latest version to continue using. Latest version is ${result1[0]['appversion']} and your version is $myVersion',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    String url = (result1[0]['update_url']);
                    try {
                      await launch(url);
                      SystemNavigator.pop(); // Add this line to exit the app
                    } catch (e) {
                      print("URL can't be launched.");
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      } else {
        // Uncomment the below line if you have implemented AsyncStorage in your app
        // await AsyncStorage.setItem('forceUpdateAlertShown', 'false');
        print('No update available.');
      }
    } catch (error) {
      print("Error: $error");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> getData() async {
    final String url = base_url + '/getstationbysec';
    final Map<String, dynamic> requestData = {'section': widget.section};

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData), // Remove the extra comma here
    );

    if (res.statusCode == 200) {
      final fetchedData = jsonDecode(res.body);
      if (fetchedData is List) {
        setState(() {
          data.addAll(fetchedData);
        });
      }
    } else {
      // Handle the error case
      print('Failed to fetch data');
    }
  }

  Future<void> getAllStations() async {
    final String url = base_url + '/getstationbyadmin';

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final fetchedData = jsonDecode(res.body);
      if (fetchedData is List) {
        setState(() {
          data.addAll(fetchedData);
        });
      }
    } else {
      // Handle the error case
      print('Failed to fetch data');
    }
  }

  void navigateToHome() {
    if (selectedStation.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please select a station.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
              id: widget.id,
              role: widget.role,
              zone: widget.zone,
              division: widget.division,
              section: widget.section,
              selectedStation: selectedStation),
        ),
      ).then((value) {
        if (value != null) {
          setState(() {
            selectedStation = value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      appBar: AppBar(
        title: Text('Station Amenities'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Login(),
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
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        leading: widget.role == '0'
            ? IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              )
            : null, // Set to null if role is not 0
      ),
      drawer: widget.role == '0'
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Stations'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StationsList(id: widget.id, role: widget.role),
                        ),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    title: Text('Users'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UsersList(id: widget.id, role: widget.role),
                        ),
                      );
                    },
                  ),
                  Divider(),
                ],
              ),
            )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.03,
                vertical: screenSize.height * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: screenSize.height * 0.05),
                Text(
                  'Station Amenities Admin',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'South Central Railway',
                  style: TextStyle(
                    fontSize: screenSize.width * 0.06,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'Please Enter Station Name',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.left,
                ),
                TypeAheadFormField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      labelText: 'Select a Station',
                      suffixIcon: selectedStation.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStation =
                                      ''; // Clear the selected station
                                });
                              },
                              child: Icon(Icons.close), // Close icon button
                            )
                          : null,
                    ),
                    controller: TextEditingController(text: selectedStation),
                  ),
              suggestionsCallback: (pattern) async {
  await Future.delayed(Duration(seconds: 1));

  pattern = pattern.toLowerCase(); // Convert the pattern to lowercase

  return data
      .where((item) =>
          item['station_name']
              .toString()
              .toLowerCase()
              .contains(pattern) ||
          item['code'].toString().toLowerCase().contains(pattern))
      .map<String>((item) => item['station_name'].toString())
      .toList();
},



                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedStation = suggestion;
                    });
                  },
                  validator: (value) {
                    if (selectedStation.isEmpty) {
                      return 'Please select a station';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenSize.height * 0.02),
                FractionallySizedBox(
                  widthFactor:
                      0.5, // Adjust the width factor as per your requirement
                  child: ElevatedButton(
                    onPressed: navigateToHome,
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: screenSize.width * 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
