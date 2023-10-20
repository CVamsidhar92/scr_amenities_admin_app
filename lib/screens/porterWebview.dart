import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PorterWebview extends StatefulWidget {
  final String url;

  PorterWebview({required this.url});

  @override
  _PorterWebviewState createState() => _PorterWebviewState();
}

class _PorterWebviewState extends State<PorterWebview> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Porter Information'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload(); // Reload the WebView content
            },
          ),
        ],
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController; // Store the controller
        },
      ),
    );
  }
}
