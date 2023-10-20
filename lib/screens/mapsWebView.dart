import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsWebview extends StatefulWidget {
  final String geturl;

  MapsWebview({required this.geturl});

  @override
  _MapsWebviewState createState() => _MapsWebviewState();
}

class _MapsWebviewState extends State<MapsWebview> {
  bool loading = true;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handleNavigationRequest(NavigationRequest request) async {
    if (request.url.startsWith('google.navigation:q=')) {
      // Open Google Maps in a separate app
      if (await canLaunch(request.url)) {
        await launch(request.url);
      } else {
        throw 'Could not launch Google Maps.';
      }
    } else {
      _webViewController.loadUrl(request.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.geturl,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (value) {
              setState(() {
                loading = false;
              });
            },
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
            },
            navigationDelegate: (NavigationRequest request) {
              _handleNavigationRequest(request);
              return NavigationDecision.prevent;
            },
          ),
          if (loading)
            Center(
              child: SpinKitCircle(
                color: Colors.white,
                size: 50.0,
              ),
            ),
        ],
      ),
    );
  }
}
