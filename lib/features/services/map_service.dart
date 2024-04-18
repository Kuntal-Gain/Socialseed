import 'dart:convert';

import 'package:socialseed/data/models/map_model.dart';
import 'package:http/http.dart' as http;

class MapService {
  Future<List<Feature>> getData(String query) async {
    final url = 'https://photon.komoot.io/api/?q=$query&limit=5';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      return (data["features"] as List)
          .map((e) => Feature.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load data from API');
    }
  }
}
