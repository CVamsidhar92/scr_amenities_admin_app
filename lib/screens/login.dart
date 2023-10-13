import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gm_appointments/screens/base_url.dart';
import 'package:gm_appointments/screens/home.dart';
import 'package:gm_appointments/screens/view_appointment.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Define the API endpoint for login
  final String apiUrl = base_url + 'login'; // Replace with your API URL

  // Function to make the API call for login
  Future<void> _login() async {
  final username = _usernameController.text;
  final password = _passwordController.text;

  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter both username and password.'),
      ),
    );
    return;
  }

  // Create a JSON request body
  final requestBody = jsonEncode({'username': username, 'password': password});

  try {
    // Make the API request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['status'] == 200) {
        // Save the role and a flag indicating that the user is logged in
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        final int role = responseData['role'];
        
        // Store the role in shared preferences
        await prefs.setInt('role', role);

        // Navigate to the appropriate screen based on the role
        if (role == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ViewAppointments(userRole: role)),
          );
        } else if (role == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home(userRole: role)),
          );
        }
      } else {
        // Handle login failure with an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed. Please try again.'),
          ),
        );
      }
    } else {
      // Handle other HTTP response codes (e.g., 500, 404) here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  } catch (error) {
    // Handle exceptions, such as network errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error. Please check your connection.'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.03,
            vertical: screenSize.height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/g20.jpeg',
                        width: screenSize.width * 0.2,
                        height: screenSize.width * 0.2,
                      ),
                      Column(
                        children: [
                          Text(
                            'South Central Railway',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.06,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'GM Appointments',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/loginLogo.jpeg',
                      width: screenSize.width * 0.2,
                      height: screenSize.width * 0.2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.05),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenSize.height * 0.02),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenSize.height * 0.02),
              ElevatedButton(
                onPressed: _login,
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: screenSize.width * 0.05),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
