import 'marker_info.dart';
import 'package:flutter/material.dart';

// 마커 정보 페이지
class MarkerDetailPage extends StatefulWidget {
  final marker_info binInfo;

  const MarkerDetailPage({super.key, required this.binInfo});

  @override
  State<MarkerDetailPage> createState() => _MarkerDetailPageState();
}

class _MarkerDetailPageState extends State<MarkerDetailPage> {
  bool isWriteMode = false; // false = 리뷰 보기, true = 리뷰 쓰기

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 안드로이드 상단 여백 고려
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 상단 정보
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: Text("나중에 리뷰 서버 만들어지면 사진 추가"),
                  ),
                  Text(widget.binInfo.address),
                  Text(widget.binInfo.name),
                ],
              ),

              SizedBox(height: 8),

              // 거리 + 즐겨찾기
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text("내 위치에서 30M"), Text("나중에 즐겨찾기 아이콘")],
              ),

              Divider(thickness: 1, color: Colors.grey),
              SizedBox(height: 10),

              // 토글 버튼
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isWriteMode = false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isWriteMode ? Colors.grey[200] : Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "리뷰 보기",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isWriteMode = true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isWriteMode ? Colors.white : Colors.grey[200],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "리뷰 쓰기",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // 리뷰 보기/쓰기 화면
              isWriteMode
                  ? ReviewWriteView(binInfo: widget.binInfo)
                  : ReviewListView(binInfo: widget.binInfo),
            ],
          ),
        ),
      ),
    );
  }
}

// 리뷰 보기
class ReviewListView extends StatelessWidget {
  final marker_info binInfo;

  const ReviewListView({super.key, required this.binInfo});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // SingleChildScrollView 안에서 높이 제한 제거
      physics: NeverScrollableScrollPhysics(), // 외부 스크롤뷰와 충돌 방지
      padding: const EdgeInsets.all(8),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text("리뷰 #${index + 1}"),
            subtitle: const Text("이곳은 리뷰 내용이 들어갈 자리입니다."),
          ),
        );
      },
    );
  }
}

// 리뷰 쓰기
class ReviewWriteView extends StatelessWidget {
  final marker_info binInfo;

  const ReviewWriteView({super.key, required this.binInfo});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        // 한 화면에 들어가는 길이라 스크롤뷰 불필요
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey),
              SizedBox(width: 6),
              Text("유저 이름", style: TextStyle(fontSize: 15)),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "여기에 리뷰 내용을 입력하세요",
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
            ),
            maxLines: 5,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("리뷰가 등록되었습니다")));
                  controller.clear();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4),
                  ),
                ),
                child: Text("등록"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("리뷰가 등록되었습니다")));
                  controller.clear();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(4),
                  ),
                ),
                child: Text("등록"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
