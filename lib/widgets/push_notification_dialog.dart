import 'dart:async';

import 'package:driver_app_frontend/driver_info.dart';
import 'package:driver_app_frontend/models/RideRequestDetails.dart';
import 'package:driver_app_frontend/screens/trip_started_screen.dart';
import 'package:driver_app_frontend/widgets/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

import 'loading_dialog.dart';

//push notification dialog appears when driver receives new ride request, and it will show the details of the ride request to the driver, and the driver can choose to accept or cancel the ride request
class PushNotificationDialog extends StatefulWidget {
  RideRequestDetails? rideRequestDetails;

  PushNotificationDialog({super.key, this.rideRequestDetails});

  @override
  State<PushNotificationDialog> createState() => _PushNotificationDialogState();
}

class _PushNotificationDialogState extends State<PushNotificationDialog> {
  String rideRequestStatus = "";
  //4.this function is used to count down the time for the driver to accept the
  //ride request, if the driver does not accept the ride request
  //within the time limit, the ride request will be cancelled automatically,
  // and the driver will not be able to accept the ride request anymore
  countDownForPushNotification() async {
    const perSecond = Duration(seconds: 1);

    var countDownTimer = Timer.periodic(perSecond, (timer) async {
      rideRequestTimeout = rideRequestTimeout - 1;

      if (rideRequestStatus == "accepted") {
        timer.cancel();
        rideRequestTimeout = 60;
      }

      if (rideRequestTimeout == 0) {
        Navigator.pop(context);
        timer.cancel();
        rideRequestTimeout = 60;
        playerAudio.stop();
      }
    });
  }
  
  fetchRideStatus(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(),
    );
print("dew0-> ");
    DatabaseReference rideStatusRef = FirebaseDatabase.instance
        .ref()
        .child("allDrivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus");

    await rideStatusRef.once().then((snapData) {
      Navigator.pop(context);
      Navigator.pop(context);

      String myRideStatusValue = "";
          print("dew1-> snapData.snapshot.value: ${snapData.snapshot.value}");
      if (snapData.snapshot.value != null) {
        myRideStatusValue = snapData.snapshot.value.toString();
      } else {
        displaySnackBar("Ride Request Not Found.", context);
      }
          print("dew2-> myRideStatusValue: $myRideStatusValue ");
      if (myRideStatusValue == widget.rideRequestDetails!.rideID) {
          rideStatusRef.set("accepted");
           print("dew3-> accepted ride request with rideID: ${widget.rideRequestDetails!.rideID}");
         driverPositionInitialStreamSubscription?.pause();
          //driverPositionInitialStreamSubscription!.pause();
          //remove driver location from geofire when driver accepts the ride request, so that the driver will not receive new ride requests when the driver is on trip
          Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
          //navigate to trip started screen when driver accepts the ride request, and pass the ride request details to the trip started screen
          print("dew3-> Navigating to TripStartedScreen with rideRequestDetails: ${widget.rideRequestDetails}");
          Navigator.push(context,MaterialPageRoute(builder: (c) => TripStartedScreen(tripInfo: widget.rideRequestDetails)));
      } else if (myRideStatusValue == "cancelled") {
        displaySnackBar("OOPS, Ride Request has been Cancelled.", context);
      } else if (myRideStatusValue == "timeout") {
        displaySnackBar("OOPS, Ride Request Timed Out.", context);
      } else {
        displaySnackBar("Ride Request Deleted. Not Found.", context);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    countDownForPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      child: Container(
        margin: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 27.0),

            Image.asset("assets/images/userapplogo.png", width: 220),

            SizedBox(height: 16.0),

            Text(
              "RIDE REQUEST",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            SizedBox(height: 20.0),

            Divider(height: 1, color: Colors.white, thickness: 1),

            SizedBox(height: 10.0),
            //we will show the pickup and destination address of the
            // ride request to the driver in the push notification
            // dialog, so that the driver can decide whether to
            //accept or cancel the ride request based on the pickup
            //and destination address
            Padding(
              padding: const EdgeInsets.all(17.0),
              child: Column(
                children: [
                  //pickup address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/userLocMarker.png",
                        height: 42,
                        width: 42,
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Text(
                          widget.rideRequestDetails!.pickupAddress.toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 17),
                  //destination address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/destinationmark.png",
                        height: 42,
                        width: 42,
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Text(
                          widget.rideRequestDetails!.destinationAddress
                              .toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Divider(height: 1, color: Colors.white, thickness: 1),

            SizedBox(height: 8),
            //we will show the cancel and accept button to the driver in the push notification dialog, so that the driver can choose to accept or cancel the ride request
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //CANCELBUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        //3.stop audio when cancel button is pressed
                        playerAudio.stop();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  //ACCEPT BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        //3.stop audio when accept button is pressed
                        playerAudio.stop();

                        setState(() {
                          rideRequestStatus = "accepted";
                        });

                      fetchRideStatus(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                      ),
                      child: const Text(
                        "ACCEPT",
                        style: TextStyle(color: Colors.white),
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
  }
}
