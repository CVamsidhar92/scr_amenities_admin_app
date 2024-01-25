import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/add_stations.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'dart:convert';

import 'package:scr_amenities_admin/screens/login.dart';

class StationsList extends StatefulWidget {
  final String id;
  final String role;
  const StationsList({Key? key, required this.id, required this.role})
      : super(key: key);

  @override
  State<StationsList> createState() => _StationsListState();
}

class _StationsListState extends State<StationsList> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  Set<String> catgValues = {};
  late String selectedCategory;
  List<String> categories = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllStations();
    getCatgValues();
  }

  Future<void> getAllStations() async {
    final String url = base_url + 'getstationbyadmin';

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

  Future<void> getCatgValues() async {
    try {
      List<String> catgList = await fetchCatgValues();
      if (catgList.isNotEmpty) {
        setState(() {
          categories = catgList;
          // Set a default value if needed
          selectedCategory = categories.isNotEmpty ? categories.first : '';
        });
      } else {
        print('Empty category list received.');
        // Handle the case when no categories are received from the server.
      }
    } catch (error) {
      print('Error fetching catg values: $error');
      // Handle any errors that may occur during the request.
    }
  }

  Future<List<String>> fetchCatgValues() async {
    final String url = base_url + 'getcatgvalues';

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> catgValues = jsonDecode(res.body);

      // Use map to extract "category" values from the response
      return catgValues
          .map<String>((value) => value['category'].toString())
          .toList();
    } else {
      // Handle the error case
      print('Failed to fetch catg values');
      return [];
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

  Future<void> deleteItem(
    int id,
    String zone,
    String division,
    String section,
    String stationName,
    String createdBy,
    BuildContext context,
  ) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);

    if (confirmDelete) {
      try {
        final String url = base_url + 'deleteStation';

        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'zone': zone,
            'division': division,
            'section': section,
            'stationName': stationName,
            'createdBy': createdBy
          }),
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
          // Close the keyboard
        FocusScope.of(context).unfocus();
           // Clear the search bar data
        searchController.clear();
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
    TextEditingController editedZoneController =
        TextEditingController(text: filteredData[stationId]['zone']);
    TextEditingController editedDivisionController =
        TextEditingController(text: filteredData[stationId]['division']);
    TextEditingController editedSectionController =
        TextEditingController(text: filteredData[stationId]['section']);
    TextEditingController editedStationNameController =
        TextEditingController(text: filteredData[stationId]['station_name']);
    TextEditingController editedCodeController =
        TextEditingController(text: filteredData[stationId]['code']);

    final screenSize = MediaQuery.of(context).size;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Edit Station'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editedZoneController,
                      decoration: InputDecoration(
                        labelText: 'Zone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    TextField(
                      controller: editedDivisionController,
                      decoration: InputDecoration(
                        labelText: 'Division',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    TextField(
                      controller: editedSectionController,
                      decoration: InputDecoration(
                        labelText: 'Section',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    TextField(
                      controller: editedStationNameController,
                      decoration: InputDecoration(
                        labelText: 'Station Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    TextField(
                      controller: editedCodeController,
                      decoration: InputDecoration(
                        labelText: 'Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: screenSize.height * 0.02,
                    ),
                    Container(
                      width: 250,
                      child: DropdownButtonFormField<String>(
                        value: filteredData[stationId]['catg'] ?? '',
                        items: categories.toSet().map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedCategory = value ?? '';
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
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
                      await updateStation(
                        filteredData[stationId]['id'], // Pass the station ID
                        editedZoneController.text,
                        editedDivisionController.text,
                        editedSectionController.text,
                        editedStationNameController.text,
                        editedCodeController.text,
                        selectedCategory,
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> updateStation(
    int stationId,
    String zone,
    String division,
    String section,
    String stationName,
    String code,
    String catg,
  ) async {
    try {
      final String url = base_url + 'updateStation';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': stationId, // Pass the station ID
          'zone': zone,
          'division': division,
          'section': section,
          'station_name': stationName,
          'code': code,
          'catg': catg,
        }),
      );

      if (response.statusCode == 200) {
        print('Data with ID $stationId updated successfully');

        // Show a Snackbar to inform the user about the successful update.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Station updated successfully'),
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
        print('Failed to update data with ID $stationId');
        // Handle the error case or show an error message to the user.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to Update Station'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      // Handle any exceptions that may occur during the HTTP request.
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Stations',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue, 
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
                                deleteItem(
                                    filteredData[index]['id'],
                                    filteredData[index]['zone'],
                                    filteredData[index]['division'],
                                    filteredData[index]['section'],
                                    filteredData[index]['station_name'],
                                    filteredData[index]['created_by'],
                                    context);
                              },
                            ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddStation(id: widget.id, role: widget.role),
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
