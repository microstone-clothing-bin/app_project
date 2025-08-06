import 'marker_info.dart';
import 'package:flutter/material.dart';

// 마커 정보 페이지
class MarkerDetailPage extends StatelessWidget {
  final marker_info binInfo;

  const MarkerDetailPage({super.key, required this.binInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(binInfo.name)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                '이름: ${binInfo.name}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
