import 'dart:convert';
import 'package:http/http.dart' as http;

class ClothingBin {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String photoUrl;
  final double distance;

  ClothingBin({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photoUrl,
    required this.distance,
  });

  //-----------------------------------------------------//
  //서버에서 받아온 json 데이터를 객체로 변환
  //fromJson으로 JSON Map을 ClothingBin 객체로 변환

  factory ClothingBin.fromJson(Map<String, dynamic> json) => ClothingBin(
    id: json['id'],
    name: json['name'],
    address: json['address'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    photoUrl: json['photoUrl'],
    distance: (json['distance'] as num).toDouble(),
  );
}

//비동기 함수로 REST API를 받아옴, fetchBins함수로 HTTP GET 요청을 보내고, 응답은 JSON으로 파싱 후 ClothingBin 리스트로 변환한다.

Future<List<ClothingBin>> fetchBins({
  required double lat,
  required double lng,
}) async {
  final url = Uri.parse(
    'http://<YOUR-BACKEND-URL>/api/clothing-bins?userLat=$lat&userLng=$lng',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final List list = json.decode(response.body);
    return list.map((e) => ClothingBin.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load data');
  }
}
