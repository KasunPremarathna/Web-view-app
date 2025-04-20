import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp ({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  InAppWebViewController? webViewController;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          final controler = webViewController;

          if (controler != null) {
            if (await controler.canGoBack()) {
              controler.goBack();

            }
          }
          //hdhsjsdgajgd
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri("https://mybikes.info/login.php"),
                    ),
                    initialSettings: InAppWebViewSettings(
                      allowsBackForwardNavigationGestures: false,
                    ),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
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
