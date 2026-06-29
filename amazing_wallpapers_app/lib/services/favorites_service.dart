import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {

  static const String key = "favorite_wallpapers";

  static Future<void> saveFavorites(
      List<Map<String, dynamic>> favorites) async {

    final prefs = await SharedPreferences.getInstance();

    List<String> jsonList =
        favorites.map((e) => jsonEncode(e)).toList();

    await prefs.setStringList(key, jsonList);
  }

  static Future<List<Map<String, dynamic>>> loadFavorites() async {

    final prefs = await SharedPreferences.getInstance();

    List<String>? jsonList =
        prefs.getStringList(key);

    if (jsonList == null) {
      return [];
    }

    return jsonList
        .map((e) =>
            Map<String, dynamic>.from(jsonDecode(e)))
        .toList();
  }
}