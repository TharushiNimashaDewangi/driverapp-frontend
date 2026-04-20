import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CompletedTripsHistory extends StatefulWidget {
  const CompletedTripsHistory({super.key});

  @override
  State<CompletedTripsHistory> createState() => _CompletedTripsHistoryState();
}

class _CompletedTripsHistoryState extends State<CompletedTripsHistory> {
  final rideRequests = FirebaseDatabase.instance.ref().child("rideRequests");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Completed Trips",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        //back button
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
//stream builder to fetch and display the completed trips history of the driver from the database in real-time, so that whenever a trip is completed by the driver, it will be automatically added to the completed trips history list without needing to refresh the screen
      body: StreamBuilder(
        stream: rideRequests.onValue,
        builder: (BuildContext context, dataSnapshot) {
          if (dataSnapshot.hasError) {
            return const Center(
              child: Text(
                "Error Occurred.",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!(dataSnapshot.hasData)) {
            return const Center(
              child: Text(
                "No record found.",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          Map tripsMap = dataSnapshot.data!.snapshot.value as Map;
          List allTripsList = [];
          tripsMap.forEach(
            (key, value) => allTripsList.add({"key": key, ...value}),
          );

          return ListView.builder(
            shrinkWrap: true,
            itemCount: allTripsList.length,
            itemBuilder: ((context, index) {
              if (allTripsList[index]["status"] != null &&
                  allTripsList[index]["status"] == "ended" &&
                  allTripsList[index]["driverID"] ==
                      FirebaseAuth.instance.currentUser!.uid) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.white30,
                    elevation: 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/userLocMarker.png',
                                height: 30,
                                width: 30,
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                child: Text(
                                  allTripsList[index]["pickUpAddress"]
                                      .toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 5),

                              Text(
                                "\$ ${allTripsList[index]["fareAmount"]}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 9),

                          Row(
                            children: [
                              Image.asset(
                                'assets/images/destinationmark.png',
                                height: 30,
                                width: 30,
                              ),

                              const SizedBox(width: 18),

                              Expanded(
                                child: Text(
                                  allTripsList[index]["dropOffAddress"]
                                      .toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}
