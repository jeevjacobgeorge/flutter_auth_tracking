import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
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

  // Method to get current location and save it to Firebase
  Future<void> trackUserLocation() async {
    // Check if location permission is granted
    bool isPermissionGranted = await _requestLocationPermission();
    if (!isPermissionGranted) {
      print("Location permission denied");
      return;
    }

    // Get current location using the latest API (no `desiredAccuracy` here)
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,  // Adjust accuracy level
        distanceFilter: 10,  // Minimum distance (in meters) to trigger a new location update
      ),
    );

    // Get current user ID (UID)
    User? user = _auth.currentUser;
    if (user == null) {
      print("User is not logged in.");
      return;
    }

    // Save location to Firebase Realtime Database
    DatabaseReference ref = _database.ref('users/${user.uid}/location');
    await ref.set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': ServerValue.timestamp,
    });

    print("Location saved: Lat: ${position.latitude}, Long: ${position.longitude}");
  }
}
