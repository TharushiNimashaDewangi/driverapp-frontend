import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String totalEarnings = "0.0";

  fetchTotalEarningsOfDriver() async {
    DatabaseReference driverEarningsRef = FirebaseDatabase.instance.ref().child(
      "allDrivers",
    );

    await driverEarningsRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
          if ((snap.snapshot.value as Map)["earnings"] != null) {
            setState(() {
              totalEarnings = ((snap.snapshot.value as Map)["earnings"])
                  .toString();
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    fetchTotalEarningsOfDriver();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              color: Colors.green,
              width: 300,
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Image.asset("assets/images/totalearnings.png", width: 120),

                    SizedBox(height: 10),

                    Text(
                      "Total Earnings:",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 3,
                        fontSize: 18,
                      ),
                    ),

                    Text(
                      "\$ " + totalEarnings,
                      style: TextStyle(
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
        ],
      ),
    );
  }
}
