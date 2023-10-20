import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TadWebview extends StatefulWidget {
  final String url;
  final String station;

  TadWebview({required this.url, required this.station});

  @override
  _TadWebviewState createState() => _TadWebviewState();
}

class _TadWebviewState extends State<TadWebview> {
  late WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('${widget.station} Station'), // Update the title
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
