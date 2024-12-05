import 'package:flutter/material.dart';
import 'package:auth_firebase/services/location_tracking_service.dart'; // Import your service
import 'package:auth_firebase/auth/auth_service.dart'; // Import AuthService for logout functionality
import 'package:auth_firebase/auth/login_screen.dart'; // Import login screen for navigation

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationTrackingService locationService = LocationTrackingService();
  final AuthService authService = AuthService(); // Instance of AuthService
  bool isTracking = false; // Track whether location is being tracked

  // Method to start tracking
  Future<void> _startTracking() async {
    await locationService.startBackgroundTracking();
    setState(() {
      isTracking = true; // Set state to indicate that tracking is active
    });
  }

  // Method to stop tracking
  Future<void> _stopTracking() async {
    await locationService.stopBackgroundTracking();
    setState(() {
      isTracking = false; // Set state to indicate that tracking is inactive
    });
  }

  // Method to handle logout
  Future<void> _logout(BuildContext context) async {
    await authService.signout(); // Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to Login Screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Tracking"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Trigger logout on button press
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome User",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            // Visual Cue - Display whether tracking is active or inactive
            isTracking
                ? Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.green, // Green icon when tracking is active
                      ),
                      const Text(
                        "Tracking Active",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 50,
                        color: Colors.red, // Red icon when tracking is inactive
                      ),
                      const Text(
                        "Tracking Inactive",
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                    ],
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTracking,
              child: const Text("Start Tracking"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopTracking,
              child: const Text("Stop Tracking"),
            ),
          ],
        ),
      ),
    );
  }
}
