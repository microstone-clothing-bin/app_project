import 'marker_info.dart';

class FavoriteManager {
  static final List<marker_info> _favorites = [];

  static List<marker_info> get favorites => _favorites;

  static void add(marker_info marker) {
    if (!_favorites.any((m) => m.id == marker.id)) {
      _favorites.add(marker);
    }
  }

  static void remove(marker_info marker) {
    _favorites.removeWhere((m) => m.id == marker.id);
  }

  static bool isFavorite(marker_info marker) {
    return _favorites.any((m) => m.id == marker.id);
  }
}
