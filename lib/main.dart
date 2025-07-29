import 'dart:async';
import 'package:flutter/material.dart';

import 'BottomIcon0.dart';
import 'BottomIcon1.dart';
import 'BottomIcon2.dart';
import 'BottomIcon3.dart';

Color mainColor = Color(0xFF6029B7); //메인 컬러 추가
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: mainColor,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Drop It',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//--------------------스플레쉬 화면 --------------------

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    BottomIcon0(),
    BottomIcon1(),
    BottomIcon2(),
    BottomIcon3(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            print(index); //눌러
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism_outlined),
            label: "나눔",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: "즐겨찾기"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "마이페이지",
          ),
        ],
      ),
    );
  }
}
