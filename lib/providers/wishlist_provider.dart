import 'package:flutter/material.dart';
import '../models/package_model.dart';

class WishlistProvider with ChangeNotifier {
  final List<PackageModel> _wishlist = [];

  List<PackageModel> get wishlist => [..._wishlist];

  bool isFavorite(String packageId) {
    return _wishlist.any((p) => p.id == packageId);
  }

  void toggleFavorite(PackageModel package) {
    final index = _wishlist.indexWhere((p) => p.id == package.id);
    if (index >= 0) {
      _wishlist.removeAt(index);
    } else {
      _wishlist.add(package);
    }
    notifyListeners();
  }
}
