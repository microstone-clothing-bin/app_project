import 'package:flutter/material.dart';

class marker_info extends StatefulWidget {
  const marker_info({super.key});

  @override
  State<marker_info> createState() => _marker_info();
}

class _marker_info extends State<marker_info> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("마커를 눌렀을때")));
  }
}
