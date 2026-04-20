import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';


class TripPaymentDialog extends StatefulWidget {
  String totalFareAmount;
  TripPaymentDialog({super.key, required this.totalFareAmount});

  @override
  State<TripPaymentDialog> createState() => _TripPaymentDialogState();
}

class _TripPaymentDialogState extends State<TripPaymentDialog> {
//this not worked properly on terminators device, so we will store the total fare amount to the driver's earnings in the database when the driver clicks on the "Confirm Collection" button in this trip payment dialog, and then we will restart the app to reset all the variables and streams for the next trip, and then the driver can receive new ride requests for the next trip
//calling for restarting the app after confirming collection of payment from the user for the trip, so that all the variables and streams will be reset for the next trip, and then the driver can receive new ride requests for the next trip 
  storeFareAmountToDriverEarnings(totalFareAmount) async {
    DatabaseReference earningsRef = FirebaseDatabase.instance.ref()
        .child("allDrivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings");
//if the driver already has some earnings in the database, then we will add the current trip fare amount to the existing earnings, and then store the updated earnings back to the database, but if the driver does not have any earnings in the database, then we will set the current trip fare amount as the driver's earnings in the database
    await earningsRef.once().then((dataSnap) {
      if(dataSnap.snapshot.value != null) {
        double oldEarnings = double.parse(dataSnap.snapshot.value.toString());
        double currentTripFareAmount = double.parse(totalFareAmount);

        double driverTotalEarnings = oldEarnings + currentTripFareAmount;

        earningsRef.set(driverTotalEarnings);
      } else {
        earningsRef.set(totalFareAmount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      backgroundColor: Colors.white70,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(height: 21,),
//collect payment text
            Text(
              "COLLECT PAYMENT",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 21,),

            Divider(
              height: 1.5,
              color: Colors.grey,
              thickness: 1.0,
            ),

            SizedBox(height: 16,),
//total fare amount to be paid by the user for the trip, which is passed from the trip started screen when the driver clicks on the "Complete Trip" button, and then we will show that total fare amount in this trip payment dialog to the driver, so that the driver can confirm that they have collected the correct amount of money from the user for the trip, and then when the driver clicks on the "Confirm Collection" button, we will store that total fare amount to the driver's earnings in the database, and then we will restart the app to reset all the variables and streams for the next trip
            Text(
              "\$ " + widget.totalFareAmount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16,),
//explanation text -> This is the trip amount 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "This is the trip amount ( \$ ${widget.totalFareAmount} ) which the user has to pay.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),

            SizedBox(height: 31,),
//restart app after confirming collection of payment from the user for the trip, so that all the variables and streams will be reset for the next trip, and then the driver can receive new ride requests for the next trip
            ElevatedButton(
              onPressed: () async {
                await storeFareAmountToDriverEarnings(widget.totalFareAmount);

                Navigator.pop(context);
                Navigator.pop(context);

                Restart.restartApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                side: const BorderSide(
                  color: Colors.grey, // Grey border
                  width: 1.0,         // Border thickness
                ),
              ),
              child: const Text(
                "CONFIRM COLLECTION",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16
                ),
              ),
            ),

            SizedBox(height: 41,)

          ],
        ),
      ),
    );
  }
}
