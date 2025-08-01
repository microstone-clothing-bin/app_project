import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class BottomIcon0 extends StatefulWidget {
  const BottomIcon0({super.key});
  @override
  State<BottomIcon0> createState() => _BottomIcon0State();
}

class _BottomIcon0State extends State<BottomIcon0> {
  @override
  Widget build(BuildContext context) {
    final center = NLatLng(37.5666, 126.979); // 서울시청 위치(예시)

    return Scaffold(
      appBar: AppBar(title: const Text("네이버 지도 예제")),
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(target: center, zoom: 14),
        ),
        onMapReady: (controller) {
          // 1. 마커 생성 (onTap 파라미터 없이)
          final marker = NMarker(
            id: "city_hall",
            position: center,
            caption: NOverlayCaption(text: "서울시청"),
          );
          controller.addOverlay(marker);

          // 2. 마커 클릭 이벤트 리스너 별도로 등록
          marker.setOnTapListener((overlay) {
            print("눌림"); // 마커를 클릭하면 터미널에 '눌림' 출력
          });
        },
      ),
    );
  }
}
