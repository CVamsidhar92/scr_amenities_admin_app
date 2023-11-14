import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/add_stations.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'dart:convert';

import 'package:scr_amenities_admin/screens/login.dart';

class StationsList extends StatefulWidget {
  final String id;
  final String role;
  const StationsList({Key? key, required this.id,required this.role}) : super(key: key);

  @override
  State<StationsList> createState() => _StationsListState();
}

class _StationsListState extends State<StationsList> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllStations();
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
          filteredData.addAll(fetchedData);
        });
      }
    } else {
      // Handle the error case
      print('Failed to fetch data');
    }
  }

void filterStations(String query) {
  setState(() {
    filteredData = data
        .where((station) =>
            station['station_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            station['code']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  });
}


  Future<void> deleteItem(int id, BuildContext context) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);

    if (confirmDelete) {
      try {
        final String url = base_url + '/deleteStation';

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id}),
        );

        if (response.statusCode == 200) {
          print('Data with ID $id deleted successfully');

          // Show a Snackbar to inform the user about the successful deletion.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Station deleted successfully'),
            ),
          );

          // Clear existing data and fetch new data
          setState(() {
            data.clear();
            filteredData.clear();
          });

          // Fetch new data
          getAllStations();
        } else {
          print('Failed to delete data with ID $id');
          // Handle the error case or show an error message to the user.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to Delete Station'),
            ),
          );
        }
      } catch (error) {
        print('Error: $error');
        // Handle any exceptions that may occur during the HTTP request.
      }
    }
  }

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

   Future<void> showEditDialog(int stationId) async {
  TextEditingController editedStationNameController =
      TextEditingController(text: filteredData[stationId]['station_name']);

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: filteredData[stationId]['station_name']),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cancel the edit
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Submit the changes
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Stations'),
         actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Login(),
              ));
            },
            child:Row(
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
      ),
      body: Column(
        children: [
          SizedBox(height: screenSize.height * 0.02),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                filterStations(query);
              },
              decoration: InputDecoration(
                labelText: 'Search Stations',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title:
                          Text(filteredData[index]['station_name'].toString()),
                      // Add other information if needed

                      // Edit and Delete buttons in a row
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            color: Colors.black,
                            onPressed: () {
                               showEditDialog(index);
                            },
                          ),
                          if (widget.role == '0')
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // Call the deleteItem function with the item ID
                                deleteItem(filteredData[index]['id'], context);
                              },
                            ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1, // Adjust the height as needed
                      color: Colors.grey, // Divider color
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
                  builder: (context) => AddStation(
                      id: widget.id,role:widget.role)
                ),
              );
            },
            child: Icon(Icons.add),
            tooltip: 'Add',
          ),
          SizedBox(height: 6),
          Text(
            'Add',
            style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
