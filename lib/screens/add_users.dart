import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scr_amenities_admin/screens/base_url.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:scr_amenities_admin/screens/stations_list.dart';
import 'package:scr_amenities_admin/screens/users_list.dart';

class AddUsers extends StatefulWidget {
  final String id;
  final String role;
  const AddUsers({Key? key, required this.id, required this.role})
      : super(key: key);

  @override
  State<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController desigController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController zoneController = TextEditingController();
  TextEditingController divisionController = TextEditingController();
  TextEditingController sectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveUserData() async {
    final String url = base_url + '/postUser';
    Map<String, dynamic> data = {
      'username': usernameController.text,
      'password': passwordController.text,
      'name': nameController.text,
      'desig': desigController.text,
      'mobile_no': mobileController.text,
      'e_mail': emailController.text,
      'zone': zoneController.text,
      'division': divisionController.text,
      'section': sectionController.text,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Data sent successfully, show a success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station Created Successfully.'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
      // Navigate to the Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UsersList(id: widget.id, role: widget.role)),
      );
    } else {
      // Handle the error case
      print('Failed to send data to the backend');
      // You can show an error message to the user or perform error handling as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Username';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: desigController,
                  decoration: InputDecoration(
                    labelText: 'Designation',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Designation';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Mobile Number';
                    } else if (value.length != 10) {
                      return 'Please enter 10 digit mobile number';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'e-Mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: zoneController,
                  decoration: InputDecoration(
                    labelText: 'Zone',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter zone';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: divisionController,
                  decoration: InputDecoration(
                    labelText: 'Division',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Division';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                TextFormField(
                  controller: sectionController,
                  decoration: InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Section';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenSize.height * 0.02,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 16.0),
                                Text("Saving User data..."),
                              ],
                            ),
                          ),
                        );

                        // Call the function to save station data
                        await saveUserData();

                        // Hide the loading indicator
                        ScaffoldMessenger.of(context).clearSnackBars();
                      }
                    },
                    child: Text('Save'),
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
