import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';

Position? driverLivePosition;

String nameOfDriver = "";
String phoneOfDriver = "";
String carType = "";
String carColor = "";
String carModel = "";
String carNumber = "";
//1.playerAudio is used to play the audio when new ride request is received
StreamSubscription<Position>? driverPositionInitialStreamSubscription;

final playerAudio = AudioPlayer();

int rideRequestTimeout = 60;
//section 17: we will use the above rideRequestTimeout variable to count down the time for the driver to accept the ride request, and if the driver does not accept the ride request within the time limit, the ride request will be cancelled automatically, and the driver will not be able to accept the ride request anymore, and we will reset the rideRequestTimeout variable to 60 seconds when the driver accepts or cancels the ride request, so that the next time when the driver receives a new ride request, the rideRequestTimeout variable will be reset to 60 seconds, and then we will use that variable to count down the time for the driver to accept the new ride request
StreamSubscription<Position>? driverPositionStreamSubscriptionForTripStarted;
