import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestDetails {
  String? rideID;
  String? userName;
  String? userPhone;
  LatLng? pickUpLatLng;
  LatLng? destinationLatLng;
  String? pickupAddress;
  String? destinationAddress;

  RideRequestDetails({
    this.rideID,
    this.userName,
    this.userPhone,
    this.pickUpLatLng,
    this.destinationLatLng,
    this.pickupAddress,
    this.destinationAddress,
  });
}