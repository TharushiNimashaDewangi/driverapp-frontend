import 'package:flutter/cupertino.dart';

import '../models/address.dart';

class ManageInfo extends ChangeNotifier {
  Address? pickUp;
  Address? destinationDropOff;

  void updatePickUpAddress(Address pickUpAddress) {
    pickUp = pickUpAddress;
    notifyListeners();
  }

  void updateDestinationDropOffAddress(Address dropOffAddress) {
    destinationDropOff = dropOffAddress;
    notifyListeners();
  }
}