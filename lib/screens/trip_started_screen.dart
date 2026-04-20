import 'dart:async';

import 'package:driver_app_frontend/helper/gmap_functions.dart';
import 'package:driver_app_frontend/models/RideRequestDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../driver_info.dart';
import '../helper/helper_functions.dart';
import '../mapStyleCustom.dart';
import '../map_info.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/trip_payment_dialog.dart';

class TripStartedScreen extends StatefulWidget {
  //tripInfo from push_notification_dialog is must be passed to the trip started screen, because we need the ride request details in the trip started screen to show the pickup and destination address, and also to draw the route on the map
  RideRequestDetails? tripInfo;

  TripStartedScreen({super.key, this.tripInfo});
  //const TripStartedScreen({super.key});

  @override
  State<TripStartedScreen> createState() => _TripStartedScreenState();
}

class _TripStartedScreenState extends State<TripStartedScreen> {
  //for showing the route on the map, we need to use google maps flutter plugin, and we need to use polyline points to draw the route on the map, and we also need to use geolocator to get the current location of the driver, and we also need to use google maps flutter plugin to show the current location of the driver on the map, and we also need to use google maps flutter plugin to show the pickup and destination location of the user on the map, and we also need to use google maps flutter plugin to show the route from the pickup location to the destination location on the map
  //for obtainUserLivePosition func
  final Completer<GoogleMapController> controllerGMapCompleter =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGMapInstance;
  double paddingFromBottomGMap = 0;
  //for obtainUserLivePosition func
  //remove it here and it used in home page also it remove from home page
  ///because we are going to define it as gloable variable in driver_info.dart file, because we need to use it in multiple screens, and we also need to update it in real time, so we will define it as global variable in driver_info.dart file and we will import it in the screens where we need to use it
  //Position? driverLivePosition;

  HelperFunctions helperFunctions = HelperFunctions();
  //for getDirectionDetailsAndDrawPolyline func
  //polyline points we need to use the polyline points plugin, and we need to use the polyline points plugin to decode the encoded polyline points that we will get from the google maps api, and we will use those decoded polyline points to draw the route on the map
  Set<Marker> markersSet = Set<Marker>();
  List<LatLng> latLngPolylineList = [];
  PolylinePoints pPoints = PolylinePoints();
  Set<Circle> cSet = Set<Circle>();
  Set<Polyline> pSet = Set<Polyline>();

  //section 17:
  //section 17 :create driver car marker icon from asset image, and we need to use that marker icon to show the driver location on the map, so we will create a function to create the driver car marker icon from the asset image, and we will call that function in the initState method, so that the driver car marker icon will be created when the trip started screen is initialized, and then we will use that driver car marker icon to show the driver location on the map in real time, and also to update the driver location on the map in real time, so that the user can see the driver location on the user app in real time
  BitmapDescriptor? driverCarMarkerIcon;
  //section 17 for getAndSetTripDetails func: we will use the below getAndSetTripDetails function to get the trip details from the firebase database, and we will use those trip details to show the pickup and destination address in the trip started screen, and also to draw the route on the map, so we need to call this getAndSetTripDetails function every time when the driver location changes, so that we can update the pickup and destination address in real time in the trip started screen, and also to update the route on the map in real time, so that the driver can see the updated pickup and destination address in real time in the trip started screen, and also to see the updated route on the map in real time
  bool directionDetailsRequested = false;
  Color btnColour = Colors.green;
  String durationString = "";
  String distanceString = "";
  String buttonTitleString = "";
  String rideStatus = "accepted";

  createDriverCarMarker() {
    if (driverCarMarkerIcon == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(
        context,
        size: Size(38, 38),
      );

      BitmapDescriptor.asset(configuration, "assets/images/tracking.png").then((
        iconMarker,
      ) {
        driverCarMarkerIcon = iconMarker;
      });
    }
  }

  //from home_screen.dart we are passing the ride request details to the trip started screen, so that we can show the pickup and destination address in the trip started screen, and also to draw the route on the map, so we need to obtain the pickup and destination location from the ride request details, and then we need to use those locations to draw the route on the map, and also to show the pickup and destination location on the map
  //every second driver move we need to update the driver location on the map, and also we need to update the driver location in the firebase database, so that the user can see the driver location on the user app in real time, so we need to use geolocator plugin to listen to the driver location changes in real time, and we also need to use google maps flutter plugin to update the driver location on the map in real time, and we also need to use firebase database to update the driver location in real time, so that the user can see the driver location on the user app in real time
  /*obtainUserLivePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location services are disabled.");
      return;
    }
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

    Position userCurrentPosition = await Geolocator.getCurrentPosition();
    driverLivePosition = userCurrentPosition;

    LatLng latLngUserPosition = LatLng(
      driverLivePosition!.latitude,
      driverLivePosition!.longitude,
    );

    CameraPosition cp = CameraPosition(target: latLngUserPosition, zoom: 16);

    controllerGMapInstance!.animateCamera(CameraUpdate.newCameraPosition(cp));

    helperFunctions.retrieveDriverData(context);
  }*/

  //secction 17:instead of using the above obtainUserLivePosition func, we will use the below obtainUserLivePosition func, because we need to listen to the driver location changes in real time, and we also need to update the driver location on the map in real time, so we will use the below obtainUserLivePosition func, and we will use the geolocator plugin to listen to the driver location changes in real time, and we will use the google maps flutter plugin to update the driver location on the map in real time
  startObtainingDriverLocationUpdates() {
    LatLng lastPositionLatLngOfDriver = LatLng(0, 0);
    //get the current location of the driver and update the driver location on the map in real time, and also update the driver location in the firebase database in real time, so that the user can see the driver location on the user app in real time
    driverPositionStreamSubscriptionForTripStarted =
        Geolocator.getPositionStream().listen((Position driverCurrentPosition) {
          driverLivePosition = driverCurrentPosition;

          LatLng currentPositionLatLngOfDriver = LatLng(
            driverCurrentPosition.latitude,
            driverCurrentPosition.longitude,
          );

          Marker driverCarMarker = Marker(
            markerId: const MarkerId("driverCarMarkerID"),
            position: currentPositionLatLngOfDriver,
            icon: driverCarMarkerIcon!,
            infoWindow: InfoWindow(title: "My Position"),
          );

          setState(() {
            CameraPosition cp = CameraPosition(
              target: currentPositionLatLngOfDriver,
              zoom: 16,
            );
            controllerGMapInstance!.animateCamera(
              CameraUpdate.newCameraPosition(cp),
            );
            //update the driver location on the map in real time, so that the user can see the driver location on the user app in real time, and also to show the driver location on the map in real time, so that the driver can see the driver location on the map in real time
            markersSet.removeWhere(
              (element) => element.markerId.value == "driverCarMarkerID",
            );
            markersSet.add(driverCarMarker);
          });
          //need to update live location every second in firebase database, so that the user can see the driver location on the user app in real time, so we need to use the below code to update the driver location in firebase database in real time, and also to update the driver location on the map in real time, so that the user can see the driver location on the user app in real time
          lastPositionLatLngOfDriver = currentPositionLatLngOfDriver;

          //Ride Details Information - UPDATE
          getAndSetTripDetails();

          Map driverLiveLocationLatLngMap = {
            "latitude": driverLivePosition!.latitude,
            "longitude": driverLivePosition!.longitude,
          };
          FirebaseDatabase.instance
              .ref()
              .child("rideRequests")
              .child(widget.tripInfo!.rideID!)
              .child("driverLocation")
              .set(driverLiveLocationLatLngMap);
        });
  }

  storeDriverInfoToRideRequest() async {
    Map<String, dynamic> driverInfoMap = {
      "carDetails": carColor + " - " + carModel + " - " + carNumber,
      "carType": carType,

      "status": "accepted",

      "driverID": FirebaseAuth.instance.currentUser!.uid,
      "driverName": nameOfDriver,
      "driverPhone": phoneOfDriver,
    };

    await FirebaseDatabase.instance
        .ref()
        .child("rideRequests")
        .child(widget.tripInfo!.rideID!)
        .update(driverInfoMap);
  }

  getDirectionDetailsAndDrawPolyline(
    sourcePositionLatLng,
    destinationPositionLatLng,
  ) async {
    //to show the loading dialog while fetching the direction details from the google maps api, because it may take some time to fetch the direction details from the google maps api, and we don't want to show a blank screen to the driver while fetching the direction details from the google maps api
    print("deww");
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(),
    );
    //fetching the direction details from the google maps api, and we will pass the source and destination location to the google maps api, and we will get the direction details from the google maps api, and we will use those direction details to draw the route on the map, and also to show the pickup and destination location on the map
    var directionDetailsInfo = await GMapFunctions.fetchDirectionDetailsFromAPI(
      sourcePositionLatLng,
      destinationPositionLatLng,
    );
    print("dewww444: $directionDetailsInfo");
    //disapear the loading dialog
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> pointsLatLng = polylinePoints.decodePolyline(
      directionDetailsInfo!.encodedPointsForDrawingRoutes!,
    );

    latLngPolylineList.clear();

    if (pointsLatLng.isNotEmpty) {
      pointsLatLng.forEach((PointLatLng pointLatLng) {
        latLngPolylineList.add(
          LatLng(pointLatLng.latitude, pointLatLng.longitude),
        );
      });
    }

    pSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("routeID"),
        color: Colors.white,
        points: latLngPolylineList,
        jointType: JointType.round,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      pSet.add(polyline);
    });
    //to adjust the camera bounds to show the complete route on the map, we need to use the LatLngBounds class from the google maps flutter plugin, and we need to pass the source and destination location to the LatLngBounds class, and then we need to use the animateCamera method of the google maps flutter plugin to adjust the camera bounds to show the complete route on the map
    LatLngBounds latLngBoundsIns;
    if (sourcePositionLatLng.latitude > destinationPositionLatLng.latitude &&
        sourcePositionLatLng.longitude > destinationPositionLatLng.longitude) {
      latLngBoundsIns = LatLngBounds(
        southwest: destinationPositionLatLng,
        northeast: sourcePositionLatLng,
      );
    } else if (sourcePositionLatLng.longitude >
        destinationPositionLatLng.longitude) {
      latLngBoundsIns = LatLngBounds(
        southwest: LatLng(
          sourcePositionLatLng.latitude,
          destinationPositionLatLng.longitude,
        ),
        northeast: LatLng(
          destinationPositionLatLng.latitude,
          sourcePositionLatLng.longitude,
        ),
      );
    } else if (sourcePositionLatLng.latitude >
        destinationPositionLatLng.latitude) {
      latLngBoundsIns = LatLngBounds(
        southwest: LatLng(
          destinationPositionLatLng.latitude,
          sourcePositionLatLng.longitude,
        ),
        northeast: LatLng(
          sourcePositionLatLng.latitude,
          destinationPositionLatLng.longitude,
        ),
      );
    } else {
      latLngBoundsIns = LatLngBounds(
        southwest: sourcePositionLatLng,
        northeast: destinationPositionLatLng,
      );
    }
    //animate the camera to adjust the bounds to show the complete route on the map with some padding, so that the driver can see the complete route on the map, and also to show the pickup and destination location on the map with some padding, so that the driver can see the pickup and destination location on the map clearly
    controllerGMapInstance!.animateCamera(
      CameraUpdate.newLatLngBounds(latLngBoundsIns, 72),
    );

    Marker sourceMarker = Marker(
      markerId: const MarkerId('sourceID'),
      position: sourcePositionLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationID'),
      position: destinationPositionLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      markersSet.add(sourceMarker);
      markersSet.add(destinationMarker);
    });

    Circle sourceCircle = Circle(
      circleId: const CircleId('sourceCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: sourcePositionLatLng,
      fillColor: Colors.white,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('destinationCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: destinationPositionLatLng,
      fillColor: Colors.white,
    );

    setState(() {
      cSet.add(sourceCircle);
      cSet.add(destinationCircle);
    });
  }

  //section17: we will use the below getAndSetTripDetails function to get the trip details from the firebase database, and we will use those trip details to show the pickup and destination address in the trip started screen, and also to draw the route on the map, so we need to call this getAndSetTripDetails function every time when the driver location changes, so that we can update the pickup and destination address in real time in the trip started screen, and also to update the route on the map in real time, so that the driver can see the updated pickup and destination address in real time in the trip started screen, and also to see the updated route on the map in real time
  //calling from startObtainingDriverLocationUpdates func, so that we can update the pickup and destination address in real time in the trip started screen, and also to update the route on the map in real time, so that the driver can see the updated pickup and destination address in real time in the trip started screen, and also to see the updated route on the map in real time
  getAndSetTripDetails() async {
    if (!directionDetailsRequested) {
      directionDetailsRequested = true;

      if (driverLivePosition == null) {
        return;
      }

      var driverCurrentPositionLatLng = LatLng(
        driverLivePosition!.latitude,
        driverLivePosition!.longitude,
      );

      LatLng destinationPositionLatLng;

      if (rideStatus == "accepted") {
        //for the pickup
        destinationPositionLatLng = widget.tripInfo!.pickUpLatLng!;
      } else {
        //for the destination
        destinationPositionLatLng = widget.tripInfo!.destinationLatLng!;
      }

      var directionDetails = await GMapFunctions.fetchDirectionDetailsFromAPI(
        driverCurrentPositionLatLng,
        destinationPositionLatLng,
      );
      print(
        "dewww555: $directionDetails.duration.toString(), $directionDetails.distance.toString() ",
      );
      if (directionDetails != null) {
        directionDetailsRequested = false;

        setState(() {
          durationString = directionDetails.duration!;
          distanceString = directionDetails.distance!;
        });
      }
    }
  }

//section 17 for trip end func: we will use the below tripEnd function to end the trip when the driver clicks on the end trip button, and when the driver clicks on the end trip button, we will update the ride request status to "ended" in the firebase database, and then we will cancel the driver location stream subscription, so that we will stop listening to the driver location changes in real time, and then we will show the trip payment dialog to the driver, so that the driver can see the total fare amount for the trip, and also to make the payment for the trip, so we need to fetch the total fare amount from the firebase database, and then we need to pass that total fare amount to the trip payment dialog, so that we can show the total fare amount in the trip payment dialog, and also to make the payment for the trip in the trip payment dialog
  tripEnd() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(),
    );

    DatabaseEvent databaseEvent = await FirebaseDatabase.instance
        .ref()
        .child("rideRequests")
        .child(widget.tripInfo!.rideID!)
        .child("fareAmount")
        .once();

    var totalFareAmount = databaseEvent.snapshot.value;
print("DEwwwww -> end trip");
    await FirebaseDatabase.instance
        .ref()
        .child("rideRequests")
        .child(widget.tripInfo!.rideID!)
        .child("status")
        .set("ended");

    driverPositionStreamSubscriptionForTripStarted!.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          TripPaymentDialog(totalFareAmount: totalFareAmount.toString()),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    storeDriverInfoToRideRequest();
    //get the current location of the driver and update the driver location on the map in real time, and also update the driver location in the firebase database in real time, so that the user can see the driver location on the user app in real time
  }
 
  //section 17 for getAndSetTripDetails func: we will use the below getAndSetTripDetails function to get the trip details from the firebase database, and we will use those trip details to show the pickup and destination address in the trip started screen, and also to draw the route on the map, so we need to call this getAndSetTripDetails function every time when the driver location changes, so that we can update the pickup and destination address in real time in the trip started screen, and also to update the route on the map in real time, so that the driver can see the updated pickup and destination address in real time in the trip started screen, and also to see the updated route on the map in real time
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    buttonTitleString = "ARRIVED";
  }

  @override
  Widget build(BuildContext context) {
    createDriverCarMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 27, bottom: paddingFromBottomGMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            polylines: pSet,
            circles: cSet,
            markers: markersSet,
            initialCameraPosition: defaultLocation,
            style: mapStyleCustom,
            onMapCreated: (GoogleMapController mapControllerGoogle) async {
              controllerGMapInstance = mapControllerGoogle;
              controllerGMapCompleter.complete(controllerGMapInstance);

              setState(() {
                //padding from bottom to the google map, because we need to show the container with trip details and end trip button at the bottom of the screen, so we need to add some padding to the google map from the bottom, so that the google map will not be hidden behind the container with trip details and end trip button, and also to show the complete route on the map clearly, so that the driver can see the complete route on the map clearly, and also to show the pickup and destination location on the map clearly, so that the driver can see the pickup and destination location on the map clearly
                paddingFromBottomGMap = 450;
              });
              //to fetch driver data from firebase database
              //and to save it in global variable we need
              //to add helper function in helper_functions.dart
              //file and we need to call that function here
              //--- IGNORE ---
              //get the current location of the driver

              var currentPositionLatLngOfDriver = LatLng(
                driverLivePosition!.latitude,
                driverLivePosition!.longitude,
              );
              //get the pickup location of the user from the ride
              //request details that we have passed from the
              // push notification dialog to the trip started
              // screen

              var pickUpPositionLatLngOfUser = widget.tripInfo!.pickUpLatLng;

              await getDirectionDetailsAndDrawPolyline(
                currentPositionLatLngOfDriver,
                pickUpPositionLatLngOfUser,
              );

              startObtainingDriverLocationUpdates();
              // obtainUserLivePosition();
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 401,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(17),
                  topLeft: Radius.circular(17),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 13,
                    spreadRadius: 0.55,
                    offset: Offset(0.65, 0.65),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //duration info
                    Center(
                      child: Text(
                        "Duration = " + durationString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    Divider(height: 1, thickness: 1, color: Colors.white70),

                    SizedBox(height: 12),
                    //distance info
                    Center(
                      child: Text(
                        "Distance = " + distanceString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    Divider(height: 1, thickness: 1, color: Colors.white70),

                    SizedBox(height: 12),
                    //user name and phone info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.phone_android_outlined,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),

                        SizedBox(width: 12),
                        //user name
                        Text(
                          widget.tripInfo!.userName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Divider(height: 1, thickness: 1, color: Colors.white70),

                    SizedBox(height: 12),

                    SizedBox(height: 8),

                    ///pickup address info
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/userLocMarker.png",
                          height: 44,
                          width: 44,
                        ),

                        SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            widget.tripInfo!.pickupAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    //destination address info
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/destinationmark.png",
                          height: 44,
                          width: 44,
                        ),

                        SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            widget.tripInfo!.destinationAddress.toString(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    Divider(height: 1, thickness: 1, color: Colors.white70),

                    SizedBox(height: 15),
                    //start trip,End trip button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (rideStatus == "accepted") {
                            rideStatus = "arrived";

                            setState(() {
                              buttonTitleString = "START TRIP";
                              btnColour = Colors.blue;
                            });

                            FirebaseDatabase.instance
                                .ref()
                                .child("rideRequests")
                                .child(widget.tripInfo!.rideID!)
                                .child("status")
                                .set("arrived");

                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) =>
                                  LoadingDialog(),
                            );

                            await getDirectionDetailsAndDrawPolyline(
                              widget.tripInfo!.pickUpLatLng,
                              widget.tripInfo!.destinationLatLng,
                            );

                            Navigator.pop(context);
                          } else if (rideStatus == "arrived") {
                            setState(() {
                              buttonTitleString = "END TRIP";
                              btnColour = Colors.green;
                            });

                            rideStatus = "ontrip";

                            FirebaseDatabase.instance
                                .ref()
                                .child("rideRequests")
                                .child(widget.tripInfo!.rideID!)
                                .child("status")
                                .set("ontrip");
                          } else if (rideStatus == "ontrip") {
                            //Trip Finish so END TRIP NOW
                            tripEnd();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColour,
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(
                          buttonTitleString,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
