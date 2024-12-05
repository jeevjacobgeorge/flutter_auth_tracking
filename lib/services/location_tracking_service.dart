import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationTrackingService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Stream subscription for location updates
  late StreamSubscription<Position> _locationStreamSubscription;

  // Last saved position for comparing new location updates
  Position? _lastKnownPosition;

  // Method to check and request location permission
  Future<bool> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;
    if (!permission.isGranted) {
      permission = await Permission.location.request();
    }
    return permission.isGranted;
  }

  // Start tracking the user's location continuously or periodically
  Future<void> startTrackingUserLocation() async {
    // Check location permission
    bool isPermissionGranted = await _requestLocationPermission();
    if (!isPermissionGranted) {
      print("Location permission denied");
      return;
    }

    // Start listening to location updates
    _startLocationUpdates();

    // Set up a timer to force location updates every 5 minutes (300 seconds)
    Timer.periodic(const Duration(minutes: 5), (_) {
      _updateLocation();
    });
  }

  // Start the location update stream
  void _startLocationUpdates() {
    _locationStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10 meters threshold to trigger an update
      ),
    ).listen((Position position) {
      // Compare with the last known position and update if needed
      if (_lastKnownPosition == null || _hasLocationChanged(position)) {
        _saveLocationToDatabase(position);
        _lastKnownPosition = position;
      }
    });
  }

  // Check if the location has significantly changed
  bool _hasLocationChanged(Position newPosition) {
    // You can add any specific distance or accuracy threshold here
    double distance = Geolocator.distanceBetween(
      _lastKnownPosition!.latitude,
      _lastKnownPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    return distance > 10; // Trigger update if the user moves more than 10 meters
  }

  // Method to force location update at regular intervals (e.g., every 5 minutes)
  Future<void> _updateLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    _saveLocationToDatabase(position);
    _lastKnownPosition = position;
  }

  // Save location to Firebase Realtime Database
  Future<void> _saveLocationToDatabase(Position position) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("User is not logged in.");
      return;
    }

    DatabaseReference ref = _database.ref('users/${user.uid}/location');
    await ref.set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': ServerValue.timestamp,
    });

    print("Location saved: Lat: ${position.latitude}, Long: ${position.longitude}");
  }

  // Stop tracking the location (e.g., when the user logs out or stops the service)
  void stopTrackingUserLocation() {
    _locationStreamSubscription.cancel();
  }
}
