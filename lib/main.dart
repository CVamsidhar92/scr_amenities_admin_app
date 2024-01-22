import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scr_amenities_admin/screens/amenities_list.dart';
import 'package:scr_amenities_admin/screens/home.dart';
import 'package:scr_amenities_admin/screens/login.dart';
import 'package:scr_amenities_admin/screens/mapsWebView.dart';
import 'package:scr_amenities_admin/screens/porter_list.dart';
import 'package:scr_amenities_admin/screens/splash_screen.dart';
import 'package:scr_amenities_admin/screens/taxi_list.dart';
import './screens/select_stn.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: 'Station App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => Splash(),
        '/Login': (context) => Login(),
      
      },
    );
  }
}
