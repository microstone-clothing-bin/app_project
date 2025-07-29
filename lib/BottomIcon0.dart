// bottom_icon_0.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'clothing_bin.dart';

// 메인 컬러
Color mainColor = Color(0xFF6029B7);
Color locationColor = Color.fromARGB(255, 242, 100, 100);

class BottomIcon0 extends StatefulWidget {
  const BottomIcon0({super.key});
  @override
  State<BottomIcon0> createState() => _BottomIcon0State();
}

class _BottomIcon0State extends State<BottomIcon0> {
  late final WebViewController _controller;
  List<ClothingBin> bins = [];
  bool loading = true;

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
    loadBins();
  }

  Future<void> loadBins() async {
    final results = await fetchBins(lat: 37.50, lng: 127.12);
    setState(() {
      bins = results;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: TextField(
          decoration: InputDecoration(
            hintText: '의류수거함 검색',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: mainColor),
          ),
          onSubmitted: (value) {
            // 검색 기능 구현
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.08,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(height: 20),
                              Icon(
                                Icons.location_on_outlined,
                                color: locationColor,
                              ),
                              Text(
                                "현재 위치",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: Text(
                                  "거리순",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: mainColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                label: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: mainColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 4,
                      thickness: 1,
                      color: Color(0xFFEEEEEE),
                      indent: 10,
                      endIndent: 10,
                    ),
                    const SizedBox(height: 4),
                    if (loading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (bins.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('의류수거함 정보 없음')),
                      )
                    else
                      ...bins.map(
                        (bin) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Material(
                            elevation: 1,
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  bin.photoUrl,
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, e, s) =>
                                      Icon(Icons.image_not_supported),
                                ),
                              ),
                              title: Text(
                                bin.distance < 1000
                                    ? "${bin.distance.toStringAsFixed(0)}M (내 위치에서)"
                                    : "${(bin.distance / 1000).toStringAsFixed(1)}KM (내 위치에서)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(bin.address),
                              trailing: Icon(
                                Icons.bookmark_border,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                // 상세 화면 등 필요시 구현
                              },
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
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
