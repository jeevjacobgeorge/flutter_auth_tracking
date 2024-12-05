// import 'dart:async';
// import 'dart:isolate';
// import 'package:flutter/material.dart';
// import 'package:background_locator/background_locator.dart';
// import 'package:background_locator/location_dto.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';

// class LocationCallbackHandler {
//   static const String _isolateName = "LocatorIsolate";
//   static final ReceivePort port = ReceivePort();

//   // Initialize the platform state
//   static Future<void> initPlatformState() async {
//     // Register the port for receiving location updates
//     IsolateNameServer.registerPortWithName(port.sendPort, _isolateName);
//     port.listen((dynamic data) {
//       LocationDto locationDto = data as LocationDto;
//       _saveLocationToDatabase(locationDto);
//     });
//     await BackgroundLocator.initialize();
//   }

//   // Callback for receiving location updates in the background
//   static void callback(LocationDto locationDto) {
//     final SendPort send = IsolateNameServer.lookupPortByName(_isolateName);
//     send?.send(locationDto);
//   }

//   // Notification callback (optional)
//   static void notificationCallback() {
//     print('User clicked on the notification');
//   }

//   // Save the location to Firebase
//   static void _saveLocationToDatabase(LocationDto locationDto) {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     FirebaseDatabase database = FirebaseDatabase.instance;

//     User? user = auth.currentUser;
//     if (user == null) {
//       print("User is not logged in.");
//       return;
//     }

//     DatabaseReference ref = database.ref('users/${user.uid}/location');
//     ref.set({
//       'latitude': locationDto.latitude,
//       'longitude': locationDto.longitude,
//       'timestamp': ServerValue.timestamp,
//     });

//     print("Location saved: Lat: ${locationDto.latitude}, Long: ${locationDto.longitude}");
//   }

//   // Start the location service
//   static Future<void> startLocationService() async {
//     // Request location permission before starting the service
//     bool isPermissionGranted = await _requestLocationPermission();
//     if (!isPermissionGranted) {
//       print("Location permission denied");
//       return;
//     }

//     // Register the background location update service
//     await BackgroundLocator.registerLocationUpdate(
//       callback,
//       initCallback: initPlatformState,
//       disposeCallback: _disposeCallback,
//       autoStop: false,
//       iosSettings: IOSSettings(
//         accuracy: LocationAccuracy.NAVIGATION,
//         distanceFilter: 10, // Meters
//       ),
//       androidSettings: AndroidSettings(
//         accuracy: LocationAccuracy.NAVIGATION,
//         interval: 5, // Seconds
//         distanceFilter: 10, // Meters
//         androidNotificationSettings: AndroidNotificationSettings(
//           notificationChannelName: 'Location tracking',
//           notificationTitle: 'Start Location Tracking',
//           notificationMsg: 'Track location in background',
//           notificationBigMsg: 'Background location is active to keep the app updated.',
//           notificationIconColor: Colors.grey,
//           notificationTapCallback: notificationCallback,
//         ),
//       ),
//     );
//   }

//   // Request permission to access the device location
//   static Future<bool> _requestLocationPermission() async {
//     PermissionStatus permission = await Permission.location.status;
//     if (!permission.isGranted) {
//       permission = await Permission.location.request();
//     }
//     return permission.isGranted;
//   }

//   // Dispose callback (optional cleanup)
//   static void _disposeCallback() {
//     print("Location service disposed.");
//   }

//   // Stop the location tracking service
//   static Future<void> stopLocationTracking() async {
//     IsolateNameServer.removePortNameMapping(_isolateName);
//     await BackgroundLocator.unRegisterLocationUpdate();
//   }
// }
