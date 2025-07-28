import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BottomIcon0 extends StatefulWidget {
  const BottomIcon0({super.key});

  @override
  State<BottomIcon0> createState() => _BottomIcon0State();
}

class _BottomIcon0State extends State<BottomIcon0> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          'https://microstone-clothing-bin.github.io/backend_marker_URL/',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. 지도 WebView가 배경으로
        WebViewWidget(controller: _controller),
        // 2. 바텀시트가 위에 덧씌워짐
        DraggableScrollableSheet(
          initialChildSize: 0.12, // ⬅️ 0.3 → 0.12: 바텀시트 기본 표시 영역을 아주 작게!
          minChildSize: 0.08, // 시트 최소 높이도 더 줄임
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // 훨씬 얇은 핸들
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  // 타이틀 Row의 세로 패딩도 최소화
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "주변 의류수거함",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                minimumSize: Size(10, 24),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: Text(
                                "거리순",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6B32C8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              label: Icon(
                                Icons.keyboard_arrow_down,
                                size: 14,
                                color: Color(0xFF6B32C8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 수평선은 컬러/간격만 남기기
                  const Divider(
                    height: 4,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                    indent: 10,
                    endIndent: 10,
                  ),
                  // 여기까지가 "위쪽" 부분: 아주 얇아짐
                  const SizedBox(height: 4),
                  // 이하 리스트 부분(기존과 동일)
                  ...List.generate(4, (i) {
                    final dummy = [
                      {"title": "30M", "desc": "경기도 의정부시 평화로202번길 11-9"},
                      {"title": "70M", "desc": "경기도 의정부시 평화로202번길 11-9"},
                      {"title": "120M", "desc": "경기도 의정부시 평화로202번길 11-9"},
                      {"title": "1.3KM", "desc": "경기도 의정부시 평화로202번길 11-9"},
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Material(
                        elevation: 1,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: Color(0xFF6B32C8),
                          ),
                          title: Text(
                            '${dummy[i]["title"]} (내 위치에서)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${dummy[i]["desc"]}'),
                          trailing: Icon(
                            Icons.bookmark_border,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
