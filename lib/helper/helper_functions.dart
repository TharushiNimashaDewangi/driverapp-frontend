import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:driver_app_frontend/widgets/snackbar.dart';
import 'package:driver_app_frontend/driver_info.dart';
import 'package:driver_app_frontend/models/direction_details.dart';

class HelperFunctions {
  retrieveDriverData(BuildContext context) async {
    String status = "";
    //fetch the driver data from firebase database using the current logged in user's uid
    DatabaseReference usersReference = FirebaseDatabase.instance
        .ref()
        .child("allDrivers")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersReference.once().then((onValue) {
      if (onValue.snapshot.value != null) {
        nameOfDriver = (onValue.snapshot.value as Map)["name"];
        phoneOfDriver = (onValue.snapshot.value as Map)["phone"];
        carType = (onValue.snapshot.value as Map)["carType"];
        carColor = (onValue.snapshot.value as Map)["carColor"];
        carModel = (onValue.snapshot.value as Map)["carModel"];
        carNumber = (onValue.snapshot.value as Map)["carNumber"];

        status = "success";
      } else {
        displaySnackBar("your record not found.", context);
        FirebaseAuth.instance.signOut();

        status = "error";
      }
    });

    return status;
  }
 /* saveDriverData(BuildContext context) async {


  }*/
  fareAmountCalculation(DirectionDetails directionDetails, String carType) {
    double perKmCharges = 0.8;
    double perMinuteCharges = 0.5;
    double baseFareCharges = 2.5;

    double traveledDistanceFareAmount = (directionDetails.distanceValue! / 1000) * perKmCharges;
    double durationSpendFareAmount = (directionDetails.durationValue! / 60) * perMinuteCharges;
    
    if(carType == "CarX") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges);
      return totalFareAmount.toStringAsFixed(1);
    } else if(carType == "CarXL") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges) * 2;
      return totalFareAmount.toStringAsFixed(1);
    } else if(carType == "CarSUV") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges) * 3;
      return totalFareAmount.toStringAsFixed(1);
    } else if(carType == "SportsCar") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges) * 5;
      return totalFareAmount.toStringAsFixed(1);
    }
  }


}
