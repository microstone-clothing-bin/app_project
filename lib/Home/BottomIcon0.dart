import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'MarkerDetailPage.dart';
import 'package:http/http.dart' as http;
import 'marker_info.dart';

Future<List<marker_info>> fetchClothingBins() async {
  final response = await http.get(
    Uri.parse('https://marker-url.onrender.com/api/clothing-bins'),
  );
  if (response.statusCode == 200) {
    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => marker_info.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load clothing bins');
  }
}

// 메인 위젯
class BottomIcon0 extends StatefulWidget {
  const BottomIcon0({super.key});

  @override
  State<BottomIcon0> createState() => _BottomIcon0State();
}

class _BottomIcon0State extends State<BottomIcon0> {
  final TextEditingController _searchController = TextEditingController();

  List<marker_info> clothingBins = [];
  Set<NClusterableMarker> clusterMarkers = {};
  bool isLoading = true;
  String? errorMessage;
  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadClothingBins();
  }

  Future<void> _loadClothingBins() async {
    try {
      final bins = await fetchClothingBins();
      setState(() {
        clothingBins = bins;
        clusterMarkers = bins.map((bin) {
          return NClusterableMarker(
            id: bin.id,
            position: NLatLng(bin.lat, bin.lng),
            caption: NOverlayCaption(text: bin.caption),
          )..setOnTapListener((overlay) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarkerDetailPage(binInfo: bin),
              ),
            );
          });
        }).toSet();
        isLoading = false;
      });
      if (_mapController != null) {
        await _mapController!.clearOverlays();
        await _mapController!.addOverlayAll(clusterMarkers);
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _addMarkers() async {
    if (_mapController == null) return;
    await _mapController!.clearOverlays();
    await _mapController!.addOverlayAll(clusterMarkers);
  }

  @override
  Widget build(BuildContext context) {
    final center = NLatLng(
      37.5666,
      126.979,
    ); // 서울시청 기준 좌표, 일단은 여기로 하고 나중에 위치정보 권한 받아서 구현 할 예정

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(target: center, zoom: 14),
            ),
            clusterOptions: NaverMapClusteringOptions(
              mergeStrategy: NClusterMergeStrategy(),
              clusterMarkerBuilder: (info, marker) {
                marker.setCaption(NOverlayCaption(text: '${info.size}개'));
              },
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              await _addMarkers();
            },
          ),

          // 검색창 UI
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '장소 또는 주소 검색',
                  prefixIcon: Icon(Icons.search, color: Colors.purple),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.purple, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.deepPurple,
                      width: 2.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                ),
                onSubmitted: (value) {
                  print('입력된 검색어: $value');
                  // TODO: 검색 기능 구현
                },
              ),
            ),
          ),

          // 바텀 시트 - 리스트 뷰
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.08,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [Text("바텀시트")],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
