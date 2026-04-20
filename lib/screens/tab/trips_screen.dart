import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import'package:driver_app_frontend/screens/completed_trips_history.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String totalCompletedTripsOfDriver = "";

  fetchCurrentDriverTotalNumberOfTripsCompleted() async {
    DatabaseReference rideRequestsRef = FirebaseDatabase.instance.ref().child(
      "rideRequests",
    );

    await rideRequestsRef.once().then((dataSnap) async {
      if (dataSnap.snapshot.value != null) {
        Map<dynamic, dynamic> allRideRequestsData =
            dataSnap.snapshot.value as Map;

        List<String> totalCompletedTripsByCurrentDriver = [];

        allRideRequestsData.forEach((key, value) {
          if (value["status"] != null) {
            if (value["status"] == "ended") {
              if (value["driverID"] == FirebaseAuth.instance.currentUser!.uid) {
                totalCompletedTripsByCurrentDriver.add(key);
              }
            }
          }
        });

        setState(() {
          totalCompletedTripsOfDriver = totalCompletedTripsByCurrentDriver
              .length
              .toString();
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchCurrentDriverTotalNumberOfTripsCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
  //total trips container
          Center(
            child: Container(
              color: Colors.orange,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Image.asset("assets/images/totaltrips.png", width: 120),

                    const SizedBox(height: 10),
//total trips text
                    Text(
                      ("Total Trips:").toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 3,
                        fontSize: 18,
                      ),
                    ),
//total trips count text
                    Text(
                      totalCompletedTripsOfDriver,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
//view trips history button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => CompletedTripsHistory()),
              );
            },

//view trips history container
            child: Center(
              child: Container(
                color: Colors.blueGrey,
                width: 300,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/tripscompleted.png",
                        width: 150,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        ("View Trips History").toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 3,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
