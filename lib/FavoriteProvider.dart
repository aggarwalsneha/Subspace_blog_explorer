import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  List favorites = [];
  List get getFavorites => favorites;
  List favoriteData = [];
  late SharedPreferences prefs;

  FavoriteProvider() {
    initialize();
  }

  addBlog(item) async {
    favorites.add(item);
    notifyListeners();
  }

  removeBlog(item) {
    favorites.remove(item);
    notifyListeners();
  }

  isFav(item) {
    favoriteData = jsonDecode(prefs.getString('favorites')!);
    return favoriteData.map((e) => e["id"]).contains(item);
  }

  storeData(item, bool add) async {
    if (add) {
      favoriteData.add(item);
    } else {
      favoriteData.removeWhere((element) => element["id"] == item["id"]);
    }
    prefs.setString('favorites', jsonEncode(favoriteData));
    notifyListeners();
  }

  initialize() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('favorites') == null) {
      favoriteData = [];
    } else {
      favoriteData = jsonDecode(prefs.getString('favorites')!);
    }
  }
}
