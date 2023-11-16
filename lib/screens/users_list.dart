import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/add_users.dart';
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'dart:convert';

import 'package:scr_amenities_admin/screens/login.dart';

class UsersList extends StatefulWidget {
  final String id;
  final String role;
  const UsersList({Key? key, required this.id, required this.role})
      : super(key: key);

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  Set<String> catgValues = {};
  late String selectedCategory;
  List<String> categories = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    final String url = base_url + '/getusers';

    final res = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 200) {
      final fetchedData = jsonDecode(res.body);
      print(
          'API Response: $fetchedData'); // Add this line to print the response

      if (fetchedData is List) {
        setState(() {
          data.addAll(fetchedData);
          filteredData.addAll(fetchedData);
        });
      }
    } else {
      // Handle the error case
      print('Failed to fetch data. Status Code: ${res.statusCode}');
    }
  }

  void filterUsers(String query) {
    setState(() {
      filteredData = data
          .where((station) =>
              station['username']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              station['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteItem(
  int id,
  String username,
  String password,
  String name,
  String desig,
  String zone,
  String division,
  String section,
  BuildContext context,
) async {
    bool confirmDelete = await showDeleteConfirmationDialog(context);

    if (confirmDelete) {
      try {
        final String url = base_url + '/deleteUser';

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
              content: Text('User deleted successfully'),
            ),
          );

          // Clear existing data and fetch new data
          setState(() {
            data.clear();
            filteredData.clear();
          });

          // Fetch new data
          getAllUsers();
        } else {
          print('Failed to delete data with ID $id');
          // Handle the error case or show an error message to the user.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to Delete User'),
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
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
                filterUsers(query);
              },
              decoration: InputDecoration(
                labelText: 'Search Users',
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
                      title: Text(filteredData[index]['username'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.role == '0')
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                deleteItem(
                                    filteredData[index]['id'],
                                    filteredData[index]['username'],
                                    filteredData[index]['password'],
                                    filteredData[index]['name'],
                                    filteredData[index]['desig'],
                                    filteredData[index]['zone'],
                                    filteredData[index]['division'],
                                    filteredData[index]['section'],
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
                      AddUsers(id: widget.id, role: widget.role),
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
