class PredictedPlaces {
  String? mainText;
  String? secondaryText;
  String? placeID;

  PredictedPlaces({
    this.mainText,
    this.secondaryText,
    this.placeID,
  });

  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    mainText = jsonData["structured_formatting"]["main_text"];
    secondaryText = jsonData["structured_formatting"]["secondary_text"];
    placeID = jsonData["place_id"];
  }
}