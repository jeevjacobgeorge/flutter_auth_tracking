import 'package:background_location/background_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationTrackingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Method to check and request location permission
  Future<bool> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;
    if (!permission.isGranted) {
      permission = await Permission.location.request();
    }
    return permission.isGranted;
  }

  // Method to start background location tracking
  Future<void> startBackgroundTracking() async {
    bool isPermissionGranted = await _requestLocationPermission();
    if (!isPermissionGranted) {
      print("Location permission denied");
      return;
    }

    // Set Android-specific notification (only for Android)
    await BackgroundLocation.setAndroidNotification(
      title: "Location Tracking",
      message: "We are tracking your location in the background.",
      icon: "@mipmap/ic_launcher",  // Set a proper icon from your assets
    );

    // Set the interval (in milliseconds) between location updates (Android only)
    await BackgroundLocation.setAndroidConfiguration(20000);  // 20000 ms = 20 second

    // Start the background location service
    await BackgroundLocation.startLocationService();

    // Listen to location updates
    BackgroundLocation.getLocationUpdates((location) {
      print("Location update: Lat: ${location.latitude}, Long: ${location.longitude}");

      // Update the location in Firebase
      _updateLocationToFirebase(location);
    });
  }

  // Method to stop background location tracking
  Future<void> stopBackgroundTracking() async {
    await BackgroundLocation.stopLocationService();
  }

  // Method to update location to Firebase
  Future<void> _updateLocationToFirebase(Location location) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("User is not logged in.");
      return;
    }

    // Save the location to Firebase Realtime Database
    DatabaseReference ref = _database.ref('users/${user.uid}/location');
    

    await ref.set({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': ServerValue.timestamp,
    });

    print("Location saved: Lat: ${location.latitude}, Long: ${location.longitude} ");
  }
}
