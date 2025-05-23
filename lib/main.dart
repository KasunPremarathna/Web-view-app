import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize("822e2014-b899-4429-8927-61981cb3422e");
  // Use this method to prompt for push notifications.
  // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
  OneSignal.Notifications.requestPermission(false);

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
  bool errorOccurred = false; // Track if an error occurred
  String? lastUrl; // Store the last URL attempted
  int _bottomNavIndex = 0; // Track the selected bottom nav bar item
  int _drawerIndex =
      -1; // Track the selected drawer item (-1 means none selected)

  // Bottom navigation items (3 items)
  final List<Map<String, dynamic>> bottomNavItems = [
    {
      'title': 'Home',
      'icon': Icons.home,
      'url': 'https://mybikes.info/dashboard.php',
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
  ];

  // Drawer navigation items (5 items + Logout)
  final List<Map<String, dynamic>> drawerNavItems = [
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
    {'title': 'Logout', 'icon': Icons.logout, 'action': 'logout'},
  ];

  // Show About dialog
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About My Bike App'),
          content: const Text(
            'My Bike is a web-based application for bike Maintenance. '
            'Version 1.0.1\n'
            'Developed by Kasun Premarathna.',
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

  // Handle logout
  Future<void> _handleLogout() async {
    // Clear all web view data to end the session
    await webViewController?.clearCache();
    await WebStorageManager.instance().android.deleteAllData();
    await CookieManager.instance().deleteAllCookies();
    // Redirect to login page
    await webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri('https://mybikes.info')),
    );
    setState(() {
      _bottomNavIndex = 0; // Reset to Home
      _drawerIndex = -1; // Reset drawer selection
      errorOccurred = false; // Reset error state
    });
  }

  // Handle bottom navigation bar item tap
  void _onBottomNavTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      _drawerIndex = -1; // Reset drawer selection
      errorOccurred = false; // Reset error state
    });
    final item = bottomNavItems[index];
    if (item['url'] != null) {
      lastUrl = item['url']; // Store the URL
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(item['url'])),
      );
    }
  }

  // Handle drawer item tap
  void _onDrawerItemTapped(int index) {
    setState(() {
      _drawerIndex = index;
      _bottomNavIndex = -1; // Reset bottom nav selection
      errorOccurred = false; // Reset error state
    });
    final item = drawerNavItems[index];
    if (item['action'] == 'showAbout') {
      _showAboutDialog();
    } else if (item['action'] == 'logout') {
      _handleLogout();
    } else if (item['url'] != null) {
      lastUrl = item['url']; // Store the URL
      webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(item['url'])),
      );
    }
    // Close the drawer
    Navigator.pop(context);
  }

  // Retry loading the last URL
  void _retryLoading() {
    if (lastUrl != null) {
      setState(() {
        errorOccurred = false;
        isLoading = true;
      });
      webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(lastUrl!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final controller = webViewController;
        if (controller != null && await controller.canGoBack()) {
          controller.goBack();
          setState(() {
            errorOccurred = false; // Reset error state on back navigation
          });
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
                  Color.fromARGB(255, 0, 219, 145),
                  Color.fromARGB(255, 22, 84, 105),
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
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 219, 145),
                      Color.fromARGB(255, 22, 84, 105),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ...drawerNavItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return ListTile(
                  leading: Icon(item['icon']),
                  title: Text(item['title']),
                  selected: _drawerIndex == index,
                  selectedTileColor: Colors.grey[200],
                  onTap: () => _onDrawerItemTapped(index),
                );
              }),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child:
                    errorOccurred
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Page Not Available',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Unable to load the page. Please check your connection or try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _retryLoading,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    0,
                                    219,
                                    145,
                                  ),
                                ),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                        : InAppWebView(
                          initialUrlRequest: URLRequest(
                            url: WebUri(
                              bottomNavItems[0]['url'],
                            ), // Initial URL (Home)
                          ),
                          initialSettings: InAppWebViewSettings(
                            allowsBackForwardNavigationGestures: true,
                            javaScriptEnabled: true, // Enable JS support
                            useHybridComposition: true, // Optimize for Android
                            cacheEnabled:
                                true, // Enable caching for persistent sessions
                            databaseEnabled: true, // Enable web database
                            domStorageEnabled: true, // Enable DOM storage
                            clearCache: false, // Do not clear cache on startup
                          ),
                          onWebViewCreated: (controller) {
                            webViewController = controller;
                          },
                          onLoadStart: (controller, url) {
                            setState(() {
                              isLoading =
                                  true; // Show loading indicator when a page starts loading
                              errorOccurred = false; // Reset error state
                              lastUrl = url.toString(); // Store the current URL
                            });
                          },
                          onLoadStop: (controller, url) async {
                            setState(() {
                              isLoading =
                                  false; // Hide loading indicator when the page finishes loading
                            });
                          },
                          onLoadError: (controller, url, code, message) {
                            setState(() {
                              isLoading = false;
                              errorOccurred = true; // Show error screen
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
                          shouldOverrideUrlLoading: (
                            controller,
                            navigationAction,
                          ) async {
                            final url = navigationAction.request.url.toString();
                            // Check if the URL is a WhatsApp link
                            if (url.startsWith('https://wa.me/') ||
                                url.startsWith('whatsapp://')) {
                              try {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                                return NavigationActionPolicy
                                    .CANCEL; // Prevent InAppWebView from loading the URL
                              } catch (e) {
                                // Optionally show an error message if WhatsApp cannot be opened
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not open WhatsApp'),
                                  ),
                                );
                                return NavigationActionPolicy.CANCEL;
                              }
                            }
                            return NavigationActionPolicy
                                .ALLOW; // Allow other URLs to load in the WebView
                          },
                        ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items:
              bottomNavItems.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item['icon']),
                  label: item['title'],
                );
              }).toList(),
          currentIndex: _bottomNavIndex >= 0 ? _bottomNavIndex : 0,
          selectedItemColor: const Color.fromARGB(255, 52, 221, 109),
          unselectedItemColor: Colors.grey,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed, // Ensure all 3 items are visible
        ),
      ),
    );
  }
}
