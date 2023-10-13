import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gm_appointments/screens/login.dart';
import 'package:gm_appointments/screens/home.dart';
import 'package:gm_appointments/screens/view_appointment.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GM Appointments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitialRoute(),
    );
  }
}

class InitialRoute extends StatefulWidget {
  @override
  _InitialRouteState createState() => _InitialRouteState();
}

class _InitialRouteState extends State<InitialRoute> {
  int? userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getInt('role');
    setState(() {
      userRole = role;
    });

    // Redirect to the appropriate screen based on the user's role
    if (userRole != null) {
      if (userRole == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ViewAppointments(userRole: userRole!),
        ));
      } else if (userRole == 1) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Home(userRole: userRole!),
        ));
      }
    } else {
      // If no role is stored, navigate to the login screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Login(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }
}
