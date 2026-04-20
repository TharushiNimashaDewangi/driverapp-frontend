import 'package:driver_app_frontend/screens/dashboard.dart';
import 'package:driver_app_frontend/screens/tab/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helper/helper_functions.dart'; // Add the correct path to your HelperFunctions file
import '../widgets/custom_text_field.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/snackbar.dart';
import '../widgets/form_validator.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  HelperFunctions helperFunctions = HelperFunctions();

  loginFormValidation() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      displaySnackBar("All fields are required.", context);
    } else if (!FormValidator.isValidEmail(email)) {
      displaySnackBar("Email format is invalid.", context);
    } else if (!FormValidator.isValidPassword(password)) {
      displaySnackBar("Password must be at least 6 characters.", context);
    } else {
      loginUser();
    }
  }

  loginUser() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => LoadingDialog(),
    );

    try {
      final User? fbUser =
          (await FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  )
                  .catchError((onErrorOccurred) {
                    displaySnackBar(onErrorOccurred.toString(), context);
                    Navigator.pop(context);
                    return onErrorOccurred;
                  }))
              .user;

      String response = await helperFunctions.retrieveDriverData(context);

      if (response == "error") {
        displaySnackBar("Try again with correct email and password.", context);
        Navigator.pop(context);
      } else {
        displaySnackBar(
          "You are Logged-in Successfully. Hurrah, you can receive Trip Requests now.",
          context,
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => Dashboard()),
        );
      }
    } on FirebaseAuthException catch (exp) {
      displaySnackBar(exp.toString(), context);
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Image.asset(
            "assets/images/logo.webp",
            width: MediaQuery.of(context).size.width * 0.7,
          ),

          SizedBox(height: 12),

          Text(
            "Login as a Driver",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontFamily: "MontserratBold",
              color: Colors.white70,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
            child: Column(
              children: [
                CustomTextField(
                  controller: emailController,
                  label: "Driver Email",
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 24),

                CustomTextField(
                  controller: passwordController,
                  label: "Driver Password",
                  isPassword: true,
                ),

                SizedBox(height: 30),

                ElevatedButton(
                  onPressed: loginFormValidation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "MontserratBold",
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => SignUpScreen()),
              );
            },
            child: Text("Don't have an Account? SignUp here"),
          ),
        ],
      ),
    );
  }
}
