import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:driver_app_frontend/widgets/custom_text_field.dart';
import 'package:driver_app_frontend/widgets/loading_dialog.dart';
import 'package:driver_app_frontend/widgets/snackbar.dart';
import 'package:driver_app_frontend/widgets/form_validator.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController carNumberController = TextEditingController();
  String? selectedCarType;

  signupFormValidation() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final model = carModelController.text.trim();
    final color = carColorController.text.trim();
    final number = carNumberController.text.trim();

    if (name.isEmpty ||
        phone.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        model.isEmpty ||
        color.isEmpty ||
        number.isEmpty ||
        selectedCarType == null) {
      displaySnackBar("All fields are required.", context);
    } else if (!FormValidator.isValidName(name)) {
      displaySnackBar("Name must be at least 4 characters.", context);
    } else if (!FormValidator.isValidPhone(phone)) {
      displaySnackBar("Phone number must be at least 7 digits.", context);
    } else if (!FormValidator.isValidEmail(email)) {
      displaySnackBar("Invalid email format.", context);
    } else if (!FormValidator.isValidPassword(password)) {
      displaySnackBar("Password must be at least 6 characters.", context);
    } else {
      signUpDriverNow();
    }
  }

  signUpDriverNow() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoadingDialog(),
    );

    try {
      final User? fbUser =
          (await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  )
                  .catchError((onErrorOccurred) {
                    displaySnackBar(onErrorOccurred.toString(), context);
                    Navigator.pop(context);
                    return onErrorOccurred;
                  }))
              .user;

      Map driverInfo = {
        "email": emailController.text.trim(),
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "id": fbUser!.uid,
        "carColor": carColorController.text.trim(),
        "carModel": carModelController.text.trim(),
        "carNumber": carNumberController.text.trim(),
        "carType": selectedCarType,
      };
      //try this
      //String response = await helperFunctions.saveDriverData(context, driverInfo);
    //6.save the driver data to firebase database
      FirebaseDatabase.instance
          .ref()
          .child("allDrivers")
          .child(fbUser.uid)
          .set(driverInfo);

      displaySnackBar(
        "Your Account Created Successfully. Please Login Now.",
        context,
      );

      FirebaseAuth.instance.signOut();

      Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
    } on FirebaseAuthException catch (exp) {
      displaySnackBar(exp.toString(), context);
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(height: 122),
              // Logo
              Image.asset(
                "assets/images/logo.webp",
                width: MediaQuery.of(context).size.width * .65,
              ),

              SizedBox(height: 10),
              // Title - Create New Account\nas a Driver
              Text(
                "Create New Account\nas a Driver",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              // SignUp Form
              Padding(
                padding: const EdgeInsets.only(left: 22, right: 22, top: 22),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: nameController,
                      label: "User Name",
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: 22),
                    //User Phone
                    CustomTextField(
                      controller: phoneController,
                      label: "User Phone",
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: 22),
                    //User Email
                    CustomTextField(
                      controller: emailController,
                      label: "User Email",
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: 22),
                    //User Password
                    CustomTextField(
                      controller: passwordController,
                      label: "User Password",
                      isPassword: true,
                    ),

                    SizedBox(height: 32),
                    //Car Model
                    CustomTextField(
                      controller: carModelController,
                      label: "Car Model",
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: 32),
                    //Car Color
                    CustomTextField(
                      controller: carColorController,
                      label: "Car Color",
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: 32),
                    // Car Number
                    CustomTextField(
                      controller: carNumberController,
                      label: "Car Number",
                      keyboardType: TextInputType.text,
                    ),

                    SizedBox(height: 32),
                    // Car Type Dropdown pls use userapp ui car types
                    //same as spelling in user app
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.grey[800],
                      value: selectedCarType,
                      style: const TextStyle(color: Colors.white70),
                      decoration: const InputDecoration(
                        labelText: "Car Type",
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: ["SportsCar", "CarSUV", "CarXL", "CarX"].map((
                        carType,
                      ) {
                        return DropdownMenuItem(
                          value: carType,
                          child: Text(carType),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCarType = value;
                        });
                      },
                    ),

                    SizedBox(height: 32),
                    // SignUp Button
                    ElevatedButton(
                      onPressed: signupFormValidation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "SignUp",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'MontserratBold',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2),
              // Already have an Account? Login here
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => LoginScreen()),
                  );
                },
                child: const Text(
                  "Already have an Account? Login here",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
