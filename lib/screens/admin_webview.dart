import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminWebview extends StatefulWidget {
  final String url;

  AdminWebview({required this.url});

  @override
  _AdminWebviewState createState() => _AdminWebviewState();
}

class _AdminWebviewState extends State<AdminWebview> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
        // Remove the back button from the app bar
        // automaticallyImplyLeading: false,
        actions: [
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
          if (await _webViewController.canGoBack()) {
            _webViewController.goBack();
            return false;
          }
          return true;
        },
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted, // Enable JavaScript
          onWebViewCreated: (WebViewController webViewController) {
            _webViewController = webViewController; // Store the controller
          },
          // Disable gesture recognizer
          gestureNavigationEnabled: false,
        ),
      ),
    );
  }
}
