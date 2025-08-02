import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'marker_info.dart'; // MarkerInfo 위젯 정의 필요

class BottomIcon0 extends StatefulWidget {
  const BottomIcon0({super.key});
  @override
  State<BottomIcon0> createState() => _BottomIcon0State();
}

class _BottomIcon0State extends State<BottomIcon0> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final center = NLatLng(37.5666, 126.979);

    return Scaffold(
      body: Stack(
        children: [
          // 네이버 지도
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(target: center, zoom: 14),
            ),
            onMapReady: (controller) {
              final marker = NMarker(
                id: "city_hall",
                position: center,
                caption: NOverlayCaption(text: "서울시청"),
              );
              controller.addOverlay(marker);

              marker.setOnTapListener((overlay) {
                print("눌림");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => marker_info()),
                );
              });
            },
          ),

          //----------------검색창-----------------
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
                },
              ),
            ),
          ),

          //----------------바텀시트-----------------
          DraggableScrollableSheet(
            initialChildSize: 0.1, // 시작 높이 (10%)
            minChildSize: 0.08, // 최소 높이 (8%)
            maxChildSize: 0.8, // 최대 높이 (80%)
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
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.my_location, color: Colors.red),
                        SizedBox(width: 10),
                        Text(
                          "현재 위치",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // 예시 리스트 아이템들
                    ListTile(
                      leading: Icon(Icons.place, color: Colors.purple),
                      title: Text('의류수거함 1'),
                      subtitle: Text('서울특별시 중구 ...'),
                      onTap: () {
                        print('의류수거함 1 클릭됨');
                        // 상세 페이지나 지도 이동 등 가능
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.place, color: Colors.purple),
                      title: Text('의류수거함 2'),
                      subtitle: Text('서울특별시 강남구 ...'),
                      onTap: () {
                        print('의류수거함 2 클릭됨');
                      },
                    ),

                    // 더 많은 리스트 아이템 추가 가능
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
