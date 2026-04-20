import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart'; //to fetch geofire for storing driver live location in firebase database and to update it in real time
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../map_info.dart'; //to fetch google map api key and defaultLocation
import 'package:driver_app_frontend/mapStyleCustom.dart'; //to fetch push notification system
import '../../pushNotificationSystem/push_notification_system.dart'; //to fetch push notification system
import '../../driver_info.dart';
import '../../helper/helper_functions.dart'; //to fetch helper functions for fetching driver data and fare amount calculation

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> controllerGMapCompleter =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGMapInstance;
  double paddingFromBottomGMap = 0;
  // remove this in here and trip start screen also because we are
  //going to define it as gloable variable in driver_info.dart file, because we need to use it in multiple screens, and we also need to update it in real time, so we will define it as global variable in driver_info.dart file and we will import it in the screens where we need to use it
  //Position? driverLivePosition;

  //for geofire we need to add geofire_flutter: in pubspec.yaml file
  bool driverActive = false;
  Color colorToDisplay = Colors.black;
  String titleToDisplay = "Ready to Drive?";

  DatabaseReference? newRideStatusReference;
  HelperFunctions helperFunctions = HelperFunctions();

  //for obtaining user live location we need to add geolocator:
  // in pubspec.yaml file
  obtainUserLivePosition() async {
    //for google map we import vgoogle_maps_flutter: geolocator:
    //to pubspec.yaml file

    //for andriod
    //also we need to add google map api key in android/app/src/main/AndroidManifest.xml file
    // <meta-data
    /*      android:name="com.google.android.geo.API_KEY"
          android:value="AIzaSyAgWrYBZUmqR4EyMQ71AVtxM4hONO4el_I"/>*/

    //also we need to add permission for location in android/app/src/main/AndroidManifest.xml file
    /*<uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>*/

    //for ios we need to add permission for location in ios/Runner/appdelegate.swift file
    //import GoogleMaps
    //and below import we need to add GMSServices.provideAPIKey("AIzaSyAgWrYBZUmqR4EyMQ71AVtxM4hONO4el_I") in didFinishLaunchingWithOptions method
    //also we need to add permission for location in ios/Runner/Info.plist file
    /** <key>NSLocationWhenInUseUsageDescription</key>
	<string>This app needs access to location information while in use.</string>
	
	<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	<string>This app needs access to location information at all times.</string> */

    //check if location service is enabled or not
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location services are disabled.");
      return;
    }
    //for permission we need to add permission for location in android/app/src/main/AndroidManifest.xml
    //file for andriod and in ios/Runner/appdelegate.swift file and ios/Runner/Info.plist file for ios
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      print("❌ Permission denied again.");
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      print(
        "🚫 Permission permanently denied. Ask user to enable it from Settings.",
      );
      await Geolocator.openAppSettings();
      return;
    }
    //if permission is granted then we can obtain user live location
    Position userCurrentPosition = await Geolocator.getCurrentPosition();
    driverLivePosition = userCurrentPosition;
    //for moving camera to user live location we need to add google_maps_flutter:
    //in pubspec.yaml file
    LatLng latLngUserPosition = LatLng(
      driverLivePosition!.latitude,
      driverLivePosition!.longitude,
    );
    //camera position is used to move camera to user live location with
    //some zoom level
    CameraPosition cp = CameraPosition(target: latLngUserPosition, zoom: 16);
    //to move camera to user live location we need to add google_maps_flutter:
    // in pubspec.yaml file
    controllerGMapInstance!.animateCamera(CameraUpdate.newCameraPosition(cp));
    //to fetch driver data from firebase database and to save it in global variable we need to add helper function in helper_functions.dart file and we need to call that function here
    helperFunctions.retrieveDriverData(context);
  }

  //real time location update is important for driver app because we need to update driver live location in firebase database in real time so that user can see driver live location on google map when user request for a ride and also we need to update driver live location in firebase database in real time when driver is active and accepting rides
  readyToDriver() async {
    //geofire is used to store driver live location in
    //firebase database and to update it in real time
    Geofire.initialize("liveDrivers");
    //for geofire we need to add geofire_flutter: in pubspec.yaml file
    //setLocation method is used to store driver live location in
    //firebase database and to update it in real time
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      driverLivePosition!.latitude,
      driverLivePosition!.longitude,
    );
    //newRideStatusReference is used to update new ride status in
    //firebase database when driver is active and accepting rides
    newRideStatusReference = FirebaseDatabase.instance
        .ref()
        .child("allDrivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus");
    await newRideStatusReference!.set("waiting");
    //onValue is used to listen for changes in new ride status in
    //firebase database when driver is active and accepting rides
    newRideStatusReference!.onValue.listen((eventRide) {});
  }

  makeLocationUpdates() {
    // driverPositionInitialStreamSubscription = Geolocator.getPositionStream().listen((Position posDriver) async {
    Geolocator.getPositionStream().listen((Position posDriver) async {
      driverLivePosition = posDriver;

      if (driverActive == true) {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          driverLivePosition!.latitude,
          driverLivePosition!.longitude,
        );
      }

      LatLng driverPositionLatLng = LatLng(
        posDriver.latitude,
        posDriver.longitude,
      );
      controllerGMapInstance!.animateCamera(
        CameraUpdate.newLatLng(driverPositionLatLng),
      );
    });
  }

  stopAcceptingRides() {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    newRideStatusReference!.onDisconnect();
    newRideStatusReference!.remove();
    newRideStatusReference = null;
  }

  startPushNotificationSystem() {
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    //to save FCM token of the device in firebase database and to subscribe to topic for receiving notification
    //need to add codes in main.dart file to initialize firebase and to request notification permission from the user
    //need ti add info.plist file for ios and android manifest file for andriod for notification permission
    //for andriod we need to add permission for notification in android/app/src/main/AndroidManifest.xml file
    //<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    //for ios we need to add permission for notification in ios/Runner/Info.plist file
    /*<key>NSUserNotificationUsageDescription</key>
  <string>This app needs access to user notifications.</string>*/
    pushNotificationSystem.saveFCMToken();
    //to listen for new notification when app is in foreground, background and terminated
    pushNotificationSystem.listenForNewNotification(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    startPushNotificationSystem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 27, bottom: paddingFromBottomGMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: defaultLocation,
            style: mapStyleCustom,
            onMapCreated: (GoogleMapController mapControllerGoogle) {
              controllerGMapInstance = mapControllerGoogle;
              controllerGMapCompleter.complete(controllerGMapInstance);

              setState(() {
                paddingFromBottomGMap = 302;
              });

              obtainUserLivePosition();
            },
          ),

          Container(height: 136, width: double.infinity, color: Colors.black87),

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isDismissible:
                          false, //to prevent closing bottom sheet when user taps outside of it
                      builder: (BuildContext context) {
                        return Container(
                          height: 245,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                                spreadRadius: 0.75,
                                offset: Offset(0.8, 0.8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 4),

                                Text(
                                  (!driverActive)
                                      ? "Ready to Drive?"
                                      : "Stop Accepting Rides",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 18),

                                Text(
                                  (!driverActive)
                                      ? "Once online, you’ll be visible to users and able to receive trip requests."
                                      : "Once offline, you will stop appearing to users and won't receive additional trip requests.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),

                                SizedBox(height: 14),

                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            side: const BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: const Text(
                                            "CANCEL",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            //Navigator.pop(context);
                                            if (!driverActive) {
                                              await readyToDriver();
                                              await makeLocationUpdates();
                                              Navigator.pop(context);
                                              setState(() {
                                                colorToDisplay = Colors.black;
                                                titleToDisplay =
                                                    "Stop Accepting Rides";
                                                driverActive =
                                                    true; //it is true
                                              });
                                            } else {
                                              await stopAcceptingRides();
                                              Navigator.pop(context);
                                              setState(() {
                                                colorToDisplay = Colors.black;
                                                titleToDisplay =
                                                    "Ready to Drive?";
                                                driverActive = false;
                                              }); //end of setState
                                            } //end of else
                                          }, //end of onPressed
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                (titleToDisplay ==
                                                    "Ready to Drive?")
                                                ? Colors.black
                                                : Colors.black87,
                                            side: const BorderSide(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: const Text(
                                            "CONFIRM",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorToDisplay,
                    side: const BorderSide(
                      color: Colors.grey, // Grey border
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    titleToDisplay,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
