import 'package:flutter/material.dart';

displaySnackBar(String text, BuildContext context){

  var sB = SnackBar(content: Text(text));

  ScaffoldMessenger.of(context).showSnackBar(sB);

}