import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Define a StatefulWidget for the AdminWebview screen
class AdminWebview extends StatefulWidget {
  final String url;

  // Constructor to receive the URL when creating an instance of the widget
  AdminWebview({required this.url});

  @override
  _AdminWebviewState createState() => _AdminWebviewState();
}

// Define the state for the AdminWebview screen
class _AdminWebviewState extends State<AdminWebview> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.blue, 
        // Remove the back button from the app bar
        // automaticallyImplyLeading: false,
        actions: [
          // Refresh button in the app bar
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload(); // Reload the WebView content
            },
          ),
        ],
      ),
      body: WillPopScope(
        // Prevent the user from navigating back with the Android back button
        onWillPop: () async {
          // Check if the WebView can go back
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack(); // Navigate back in the WebView
            return false; // Do not allow the app to be popped from the stack
          }
          return true; // Allow the app to be popped from the stack
        },
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted, // Enable JavaScript
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController; // Store the controller
          },
          // Disable gesture recognizer for WebView navigation
          gestureNavigationEnabled: false,
        ),
      ),
    );
  }
}
