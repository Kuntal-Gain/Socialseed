// To parse this JSON data, do
//
//     final mapModel = mapModelFromJson(jsonString);

import 'dart:convert';

MapModel mapModelFromJson(String str) => MapModel.fromJson(json.decode(str));

String mapModelToJson(MapModel data) => json.encode(data.toJson());

class MapModel {
  List<Feature> features;
  String type;

  MapModel({
    required this.features,
    required this.type,
  });

  factory MapModel.fromJson(Map<String, dynamic> json) => MapModel(
        features: List<Feature>.from(
            json["features"].map((x) => Feature.fromJson(x))),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
        "type": type,
      };
}

class Feature {
  Geometry geometry;
  String type;
  Properties properties;

  Feature({
    required this.geometry,
    required this.type,
    required this.properties,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        geometry: Geometry.fromJson(json["geometry"]),
        type: json["type"],
        properties: Properties.fromJson(json["properties"]),
      );

  Map<String, dynamic> toJson() => {
        "geometry": geometry.toJson(),
        "type": type,
        "properties": properties.toJson(),
      };
}

class Geometry {
  List<double> coordinates;
  String type;

  Geometry({
    required this.coordinates,
    required this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        coordinates:
            List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
        "type": type,
      };
}

class Properties {
  String osmType;
  int osmId;
  List<double>? extent;
  String country;
  String osmKey;
  String countrycode;
  String osmValue;
  String name;
  String? county;
  String state;
  String type;
  String? city;
  String? postcode;
  String? street;
  String? district;

  Properties({
    required this.osmType,
    required this.osmId,
    this.extent,
    required this.country,
    required this.osmKey,
    required this.countrycode,
    required this.osmValue,
    required this.name,
    this.county,
    required this.state,
    required this.type,
    this.city,
    this.postcode,
    this.street,
    this.district,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        osmType: json["osm_type"],
        osmId: json["osm_id"],
        extent: json["extent"] == null
            ? []
            : List<double>.from(json["extent"]!.map((x) => x?.toDouble())),
        country: json["country"],
        osmKey: json["osm_key"],
        countrycode: json["countrycode"],
        osmValue: json["osm_value"],
        name: json["name"],
        county: json["county"],
        state: json["state"],
        type: json["type"],
        city: json["city"],
        postcode: json["postcode"],
        street: json["street"],
        district: json["district"],
      );

  Map<String, dynamic> toJson() => {
        "osm_type": osmType,
        "osm_id": osmId,
        "extent":
            extent == null ? [] : List<dynamic>.from(extent!.map((x) => x)),
        "country": country,
        "osm_key": osmKey,
        "countrycode": countrycode,
        "osm_value": osmValue,
        "name": name,
        "county": county,
        "state": state,
        "type": type,
        "city": city,
        "postcode": postcode,
        "street": street,
        "district": district,
      };
}
