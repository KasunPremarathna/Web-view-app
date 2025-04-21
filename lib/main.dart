import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  runApp(const MyApp());

  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize("822e2014-b899-4429-8927-61981cb3422e");
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(false);
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

  // Navigation items with URLs and actions
  final List<Map<String, dynamic>> navItems = [
    {
      'title': 'Home',
      'icon': Icons.home,
      'url': 'https://mybikes.info/login.php',
    },
    {
      'title': 'Profile',
      'icon': Icons.person,
      'url': 'https://mybikes.info/profile.php',
    },
    {
      'title': 'Shop',
      'icon': Icons.shopping_cart,
      'url': 'https://mybikes.info/shop_finder.php',
    },
    {
      'title': 'Community',
      'icon': Icons.group,
      'url': 'https://mybikes.info/community.php',
    },
    {
      'title': 'Events',
      'icon': Icons.event,
      'url': 'https://mybikes.info/events.php',
    },
    {
      'title': 'Blog',
      'icon': Icons.article,
      'url': 'https://mybikes.info/blog.php',
    },
    {
      'title': 'Support',
      'icon': Icons.support,
      'url': 'https://mybikes.info/support.php',
    },
    {'title': 'About', 'icon': Icons.info, 'action': 'showAbout'},
  ];

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
    final item = navItems[index];
    if (item['action'] == 'showAbout') {
      _showAboutDialog();
    } else if (item['url'] != null) {
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(item['url'])),
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
                    url: WebUri(navItems[0]['url']), // Initial URL (Home)
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
        bottomNavigationBar: Container(
          height: 70, // Adjust height as needed
          color: Colors.white, // Background color
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children:
                  navItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _selectedIndex == index
                                    ? const Color.fromARGB(
                                      255,
                                      52,
                                      221,
                                      109,
                                    ).withOpacity(0.2)
                                    : null,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'],
                                color:
                                    _selectedIndex == index
                                        ? const Color.fromARGB(
                                          255,
                                          52,
                                          221,
                                          109,
                                        )
                                        : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['title'],
                                style: TextStyle(
                                  color:
                                      _selectedIndex == index
                                          ? const Color.fromARGB(
                                            255,
                                            52,
                                            221,
                                            109,
                                          )
                                          : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
