import 'package:flutter/material.dart';
import 'Home/FavoriteManager.dart';

class BottomIcon2 extends StatelessWidget {
  const BottomIcon2({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = FavoriteManager.favorites;

    return Scaffold(
      appBar: AppBar(title: Text("즐겨찾기")),
      body: favorites.isEmpty
          ? Center(child: Text('저장된 즐겨찾기가 없습니다'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final marker = favorites[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: Icon(Icons.star, color: Colors.amber), // 즐겨찾기 아이콘
                    title: Text(marker.caption),
                    subtitle: Text(marker.address ?? ''),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {
                        FavoriteManager.remove(marker);
                        // 만약 stateful이면 setState 등으로 갱신 필요
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
