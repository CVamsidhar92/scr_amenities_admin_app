import 'package:flutter/material.dart';
import 'package:gm_appointments/screens/base_url.dart';
import 'package:gm_appointments/screens/entry_form.dart';
import 'package:gm_appointments/screens/login.dart';
import 'package:gm_appointments/screens/view_appointment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  final int userRole;

  const Home({Key? key, required this.userRole}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final myVersion = '1.0';
  late BuildContext dialogContext;
  bool _isAlertShown = false; // Variable to track if the alert dialog is shown
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    getUpdates();
  }

  Future<void> getUpdates() async {
    try {
      final data = {'name': myVersion};

      final String url = base_url + 'appversion';
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
          builder: (BuildContext context) {
            dialogContext = context;
            return AlertDialog(
              title: const Text('Please Update'),
              content: Text(
                'You must update the app to the latest version to continue using. Latest version is ${result1[0]['appversion']} and your version is $myVersion',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
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
          dialogContext = context;
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Home'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  // Implement your logout logic here and clear the login status
                  _clearLoginStatus();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
              ),
            ],
          ),
          body: FutureBuilder<bool>(
            future: _isLoggedIn(), // Check if the user is logged in
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while checking the login status
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Handle errors, e.g., if unable to check login status
                return Text('Error: ${snapshot.error}');
              } else {
                final isLoggedIn = snapshot.data ?? false;
                if (isLoggedIn) {
                  // If the user is logged in, show the Home screen
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.03,
                        vertical: screenSize.height * 0.03,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome to the Home Screen',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.06,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the CreateForm screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateForm(),
                                ),
                              );
                            },
                            child: Text(
                              'Create Appointment',
                              style: TextStyle(fontSize: screenSize.width * 0.05),
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the ViewAppointments screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ViewAppointments(userRole: widget.userRole),
                                ),
                              );
                            },
                            child: Text(
                              'View Appointments',
                              style: TextStyle(fontSize: screenSize.width * 0.05),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  // If the user is not logged in, navigate to the Login screen
                  return const Login();
                }
              }
            },
          ),
        ),
        if (_isAlertShown)
          Container(
            color: Colors.black.withOpacity(0.6), // Adjust opacity as needed
            child: Center(),
          ),
      ],
    );
  }

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  void _clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }
}

void main() {
  runApp(MaterialApp(
    home: Home(userRole: 0), // Replace 0 with the actual user role
  ));
}
