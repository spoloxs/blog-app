import 'package:blog_app/bloc/wishlist_bloc.dart';
import 'package:blog_app/model/wishlist_model.dart';
import 'package:blog_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
  final String adminSecret =
      '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';

  List<dynamic> blogList = [];
  bool isOffline = false;
  bool isConnected = true;

  final CacheManager _cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    fetchBlogs();
    Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isOffline = true;
          isConnected = false;
        });
      } else {
        setState(() {
          isOffline = false;
          isConnected = true;
        });
        fetchBlogs();
      }
      if (isConnected) {
        _showConnectedMessage();
      }
    });
  }

  @override
  void dispose() {
    _cacheManager.dispose();
    super.dispose();
  }

  Future<void> fetchBlogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cachedBlogs')) {
      final cachedData = prefs.getString('cachedBlogs');
      final cachedBlogList = json.decode(cachedData!)['blogs'];

      setState(() {
        blogList = cachedBlogList;
      });
    }

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          blogList = responseData['blogs'];
        });

        await prefs.setString('cachedBlogs', json.encode(responseData));

        await cacheImages(responseData['blogs']);

        if (isConnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connected to the internet.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('Request failed with status code: ${response.statusCode}');
        print('Response data: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to cache images locally
  Future<void> cacheImages(List<dynamic> blogs) async {
    for (final blog in blogs) {
      final imageUrl = blog['image_url'];
      final file = await _cacheManager.getSingleFile(imageUrl);
      if (file != null) {
        print('Image cached: $imageUrl');
      } else {
        print('Failed to cache image: $imageUrl');
      }
    }
  }

  void _showConnectedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You are connected to the internet.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistBloc>(builder: (context, myBloc, _) {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isOffline
            ? Container(
                height: 40,
                color: Colors.black87,
                child: const Center(
                  child: Text(
                    'You are offline.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            : null,
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 20,
                    ),
                    itemCount: blogList.length,
                    itemBuilder: (context, index) {
                      final blog = blogList[index];
                      final imageUrl = blog['image_url'];
                      bool isFavorite = myBloc
                          .getWishList()
                          .any((item) => item.id == blog['id']);

                      return FutureBuilder(
                        future: isOffline
                            ? _cacheManager.getSingleFile(imageUrl)
                            : null,
                        builder: (context, snapshot) {
                          final imageWidget = isOffline
                              ? snapshot.data != null
                                  ? Image.file(snapshot.data!)
                                  : null // Use the cached image
                              : Image.network(
                                  imageUrl); // Use the network image

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Set the border radius
                              color: Colors.white10,
                            ),
                            child: InkWell(
                              onTap: () {
                                // Use Navigator.pushNamed without specifying a custom PageRouteBuilder
                                Navigator.pushNamed(
                                  context,
                                  Routes.blogDetails,
                                  arguments: {
                                    'imageFile': imageWidget,
                                    'title': blog['title'],
                                    'details': '',
                                  },
                                );
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Text(
                                  blog[
                                      'title'], // Use the actual title from the blog data
                                  textAlign: TextAlign.right,
                                ),
                                leading: isOffline
                                    ? snapshot.data != null
                                        ? Image.file(snapshot.data!)
                                        : null // Use the cached image
                                    : Image.network(imageUrl),
                                trailing: IconButton(
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;

                                      if (isFavorite) {
                                        // Add the blog to the wishlist
                                        myBloc.addToWishlist(
                                          WishlistItem(
                                            id: blog['id'],
                                            title: blog['title'],
                                            image: imageUrl,
                                            details: blog['details'],
                                          ),
                                        );
                                      } else {
                                        // Remove the blog from the wishlist
                                        myBloc.removeFromWishlist(blog['id']);
                                      }
                                    });
                                  },
                                ), // Use the network image
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )),
            ),
          ],
        ),
      );
    });
  }
}
