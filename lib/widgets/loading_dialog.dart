import 'package:flutter/material.dart';


class LoadingDialog extends StatelessWidget {

  LoadingDialog({super.key,});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.transparent,
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green),),
    );
  }
}
