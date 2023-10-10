import 'dart:convert';
import 'package:blog_app/model/wishlist_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistBloc extends ChangeNotifier {
  final List<WishlistItem> _wishlist = <WishlistItem>[];

  // Initialize the bloc and load data from local storage
  WishlistBloc() {
    loadWishlist();
  }

  List<WishlistItem> get wishlist => _wishlist;

  getWishList() => _wishlist;

  // Add an item to the wishlist
  void addToWishlist(WishlistItem item) {
    _wishlist.add(item);
    saveWishlist();
  }

  // Remove an item from the wishlist
  void removeFromWishlist(String itemId) {
    _wishlist.removeWhere((item) => item.id == itemId);
    saveWishlist();
  }

  // Load wishlist data from local storage
  Future<void> loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('wishlist');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _wishlist.clear();
      for (final item in jsonList) {
        final wishlistItem = WishlistItem(
            id: item['id'],
            title: item['title'],
            image: item['image'],
            details: item['details']);
        _wishlist.add(wishlistItem);
      }
    }
  }

  // Save wishlist data to local storage
  Future<void> saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_wishlist
        .map((item) => {
              'id': item.id,
              'title': item.title,
              'image': item.image,
              'details': item.details
            })
        .toList());
    await prefs.setString('wishlist', jsonString);
    notifyListeners();
  }

  // // Refresh wishlist when the app is opened or the user gets online
  // void refreshWishlist(List<Map<String, dynamic>> blogs) {
  //   for (final blog in blogs) {
  //     final String blogId = blog['id'];

  //     // Find the corresponding wishlist item by matching IDs
  //     WishlistItem? existingItem = _wishlist.firstWhere(
  //       (item) => item.id == blogId,
  //     );

  //     if (existingItem != null) {
  //       // Update the values in the wishlist item with values from the blog
  //       existingItem.title = blog['title'];
  //       existingItem.image = blog['image'];
  //       existingItem.details = blog['details'];
  //     }
  //   }

  //   // Save the updated wishlist to local storage
  //   saveWishlist();
  // }
}
