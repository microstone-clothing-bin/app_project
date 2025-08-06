class marker_info {
  final String id;
  final String name; // roadAddress 를 name 으로 매핑
  final String address; // landLotAddress 를 address 로 매핑
  final double lat; // latitude -> lat
  final double lng; // longitude -> lng

  marker_info({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory marker_info.fromJson(Map<String, dynamic> json) {
    return marker_info(
      id: json['id']?.toString() ?? '',
      name: json['roadAddress'] ?? '',
      address: json['landLotAddress'] ?? '',
      lat: json['latitude'] != null
          ? (json['latitude'] is double
                ? json['latitude'] as double
                : double.tryParse(json['latitude'].toString()) ?? 0.0)
          : 0.0,
      lng: json['longitude'] != null
          ? (json['longitude'] is double
                ? json['longitude'] as double
                : double.tryParse(json['longitude'].toString()) ?? 0.0)
          : 0.0,
    );
  }
  String get caption => name; // 마커 캡션으로 name을 사용
}
