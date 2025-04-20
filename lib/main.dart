import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
      ],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  int _selectedIndex = 0; // Track the selected nav bar item

  // URLs for navigation items
  final Map<int, String> navUrls = {
    0: "https://mybikes.info/dashboard.php", // Home
    1: "https://mybikes.info/profile.php", // Profile
    2: "https://mybikes.info/shop.php", // Shop
  };

  // Show About dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About My Bike'),
          content: const Text(
            'My Bike is a web-based application for bike enthusiasts. '
            'Version 1.0.0\n'
            'Developed by My Bike Team.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Handle navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) {
      // About
      _showAboutDialog();
    } else if (navUrls.containsKey(index)) {
      // Home, Profile, Shop
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(navUrls[index]!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controller = webViewController;
        if (controller != null && await controller.canGoBack()) {
          controller.goBack();
          return Future.value(false); // Prevent default back action
        }
        return Future.value(true); // Allow back exit if no history
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55), // Adjusted AppBar height
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 52, 221, 109),
                  const Color.fromARGB(255, 77, 182, 109),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              backgroundColor:
                  Colors.transparent, // Make the AppBar background transparent
              elevation: 0, // Remove shadow
              title: const Text('My Bike'),
              actions: [
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(navUrls[0]!), // Initial URL (Home)
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
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Shop',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 52, 221, 109),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Ensure all items are visible
        ),
      ),
    );
  }
}
