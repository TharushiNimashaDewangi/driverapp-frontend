import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver_app_frontend/driver_info.dart';
import 'package:driver_app_frontend/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController carController = TextEditingController();


  setValuesToTextControllers() {
    print("deww profile screen -> nameOfDriver: " + nameOfDriver);
    print("deww profile screen -> carType: " + carType);
    print("deww profile screen -> carNumber: " + carNumber);
    print("deww profile screen -> carModel: " + carModel);
    setState(() {
      nameController.text = nameOfDriver;
      carController.text = "${carType} | ${carNumber} - ${carModel}";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setValuesToTextControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
//driver avatar image
              Container(
                width: 181,
                height: 181,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white70,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: AssetImage("assets/images/driver_avatar.webp"),
                  ),
                ),
              ),

              SizedBox(height: 26),
//driver name text field
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 8),
                child: TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 10),
//driver car details text field
              Padding(
                padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 4),
                child: TextField(
                  controller: carController,
                  textAlign: TextAlign.center,
                  enabled: false,
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.drive_eta_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 26),
//logout button
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Rectangular shape
                    side: const BorderSide(
                      color: Colors.grey, // Grey border
                      width: 1.0,
                    ),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
