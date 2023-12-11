import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleMapsWebView extends StatelessWidget {
  final String googleMapsUrl;

  const GoogleMapsWebView({Key? key, required this.googleMapsUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Remove the waypoints parameter from the URL
    final modifiedUrl = googleMapsUrl.replaceAll(RegExp(r'&waypoints=.+'), '');

    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue, 
      ),
      body: WebView(
        initialUrl: modifiedUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
