import 'package:driver_app_frontend/driver_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:driver_app_frontend/models/RideRequestDetails.dart';
import 'package:driver_app_frontend/widgets/loading_dialog.dart';
import 'package:driver_app_frontend/widgets/push_notification_dialog.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:just_audio/just_audio.dart';

class PushNotificationSystem {
  //we implement receiving part of push notification system in this file.
  // We will implement sending part in the backend (firebase functions) later on
  //dependency need to added: firebase_messaging: ^14.0.3
  // we will save the FCM token of the device in the database,
  //so that we can send notification to this device later on
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  

  Future<String?> saveFCMToken() async {
    String? recognitionTokenForDevice = await messaging.getToken();

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .ref()
        .child("allDrivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("fcmToken");

    tokenRef.set(recognitionTokenForDevice);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }

  // we will listen for new notification in this function,
  //and we will handle the notification when it is received
  listenForNewNotification(BuildContext context) async {
    //retrieve the message which caused the app to open
    //from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        String rideID = message.data["rideID"];
        //section16-lecture 122: we will fetch the ride request data from the database using the rideID, and then we will navigate to the ride request details screen to show the details of the ride request to the driver
        fetchRideRequestData(rideID, context);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        String rideID = message.data["rideID"];
        fetchRideRequestData(rideID, context);
        
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        String rideID = message.data["rideID"];
        fetchRideRequestData(rideID, context);
      }
    });
  }

  // we will request notification permission from the user in this function
  Future<void> requestNotificationPermission() async {
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('User denied iOS notification permissions');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        print('iOS notification permission granted');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('iOS provisional notification permission granted');
      }
    } else if (Platform.isAndroid) {
      // Android 13+ requires runtime permission
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  // we will fetch the ride request data from the database using the rideID, and then we will navigate to the ride request details screen to show the details of the ride request to the driver
  fetchRideRequestData(rideID, context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(),
    );

    DatabaseReference rideRequestsRef = FirebaseDatabase.instance
        .ref()
        .child("rideRequests")
        .child(rideID);
    rideRequestsRef.once().then((snap) async {
      Navigator.pop(context);
//2.play audio when new ride request is received
      await playerAudio.setAudioSource(
        AudioSource.asset("assets/audio/alert_sound.mp3"),
      );
      await playerAudio.play();

      RideRequestDetails rideDetails = RideRequestDetails();

      rideDetails.rideID = rideID;

      rideDetails.userName = (snap.snapshot.value! as Map)["userName"];
      rideDetails.userPhone = (snap.snapshot.value! as Map)["userPhone"];

      rideDetails.pickupAddress = (snap.snapshot.value! as Map)["pickUpAddress"];
      rideDetails.destinationAddress = (snap.snapshot.value! as Map)["dropOffAddress"];

      double pickUpLat = double.parse((snap.snapshot.value! as Map)["pickUpLatLng"]["latitude"],);
      double pickUpLng = double.parse( (snap.snapshot.value! as Map)["pickUpLatLng"]["longitude"],);
      rideDetails.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

      double destinationLat = double.parse((snap.snapshot.value! as Map)["dropOffLatLng"]["latitude"], );
      double destinationLng = double.parse( (snap.snapshot.value! as Map)["dropOffLatLng"]["longitude"],  );
      rideDetails.destinationLatLng = LatLng(destinationLat, destinationLng);
      //section16-lecture 122: we will navigate to the ride
      //request details screen to show the details of
      //the ride request to the driver
      print("dewpush-> rideDetails: ${rideDetails.toString()}");
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            PushNotificationDialog(rideRequestDetails: rideDetails),
      );
    });
  }
}
