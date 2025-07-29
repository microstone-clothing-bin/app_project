import 'package:flutter/material.dart';

class BottomIcon1 extends StatelessWidget {
  const BottomIcon1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("4,325개"), Spacer(), Text("거리순"), Text("최신순")],
          ),
        ],
      ),
    );
  }
}
