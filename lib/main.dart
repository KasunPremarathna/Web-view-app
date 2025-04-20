import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  InAppWebViewController? webViewController;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          final controller = webViewController;
          if (controller != null && await controller.canGoBack()) {
            controller.goBack();
            return Future.value(false); // Prevent default back action
          }
          return Future.value(true); // Allow back exit if no history
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('WebView Example'),
            actions: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                        "https://mybikes.info/login.php",
                      ), // Updated this line
                    ),
                    initialSettings: InAppWebViewSettings(
                      allowsBackForwardNavigationGestures: true,
                      javaScriptEnabled: true, // Enable JS support
                    ),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        isLoading =
                            true; // Show loading indicator when a page starts loading
                      });
                    },
                    onLoadStop: (controller, url) async {
                      setState(() {
                        isLoading =
                            false; // Hide loading indicator when the page finishes loading
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        setState(() {
                          isLoading = false;
                        });
                      } else {
                        setState(() {
                          isLoading = true;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
