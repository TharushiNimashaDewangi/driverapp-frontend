import 'dart:convert';
import 'package:driver_app_frontend/map_info.dart';

import '../driver_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../manageInfo/manage_info.dart';
import '../models/address.dart';
import '../models/direction_details.dart';

class GMapFunctions {
  static requestAPI(String url) async {
    http.Response apiResponse = await http.get(Uri.parse(url));

    try {
      if (apiResponse.statusCode == 200) {
        String responseData = apiResponse.body;
        var decodedData = jsonDecode(responseData);
        return decodedData;
      } else {
        return "error";
      }
    } catch (msg) {
      print(msg);
      return "error";
    }
  }

  static Future<String> getHumanReadableAddressFromGeoGraphicCoOrdinates(
    Position positionUser,
    BuildContext context,
  ) async {
    String urlGeoCodingApi =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${positionUser.latitude},${positionUser.longitude}&key=$gMapKey";

    var responseData = await requestAPI(urlGeoCodingApi);

    if (responseData != "error") {
      Address address = Address();
      address.userAddressInReadableFormat =
          responseData["results"][0]["formatted_address"];
      address.placeID = responseData["results"][0]["place_id"];
      address.placeName = responseData["results"][0]["formatted_address"];
      address.latPosition = positionUser.latitude;
      address.lngPosition = positionUser.longitude;

      Provider.of<ManageInfo>(
        context,
        listen: false,
      ).updatePickUpAddress(address);
    } else {
      print("try Again. Error Occurred.");
    }

    return responseData["results"][0]["formatted_address"];
  }

  static Future<DirectionDetails?> fetchDirectionDetailsFromAPI(
    LatLng pickup,
    LatLng destination,
  ) async {
    //5.get the direction details for the trip from pickup location to drop off destination location-fetchDirectionDetailsFromAPI
    String directionDetailsAPIUrl =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${pickup.latitude},${pickup.longitude}&key=$gMapKey";

    var directionDetailsAPIResponseData = await requestAPI(
      directionDetailsAPIUrl,
    );

    if (directionDetailsAPIResponseData == "error") {
      return null;
    }

    DirectionDetails details = DirectionDetails();
    details.distance =
        directionDetailsAPIResponseData["routes"][0]["legs"][0]["distance"]["text"];
    details.distanceValue =
        directionDetailsAPIResponseData["routes"][0]["legs"][0]["distance"]["value"];

    details.duration =
        directionDetailsAPIResponseData["routes"][0]["legs"][0]["duration"]["text"];
    details.durationValue =
        directionDetailsAPIResponseData["routes"][0]["legs"][0]["duration"]["value"];

    details.encodedPointsForDrawingRoutes =
        directionDetailsAPIResponseData["routes"][0]["overview_polyline"]["points"];

    return details;
  }
}
