import 'package:blog_app/bloc/wishlist_bloc.dart';
import 'package:blog_app/model/wishlist_model.dart';
import 'package:blog_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  WishlistScreenState createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  bool isOffline = false;
  bool isConnected = true;

  final CacheManager _cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
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
                    itemCount: myBloc.getWishList().length,
                    itemBuilder: (context, index) {
                      List<WishlistItem> blogList = myBloc.getWishList();
                      final blog = blogList[index];
                      final imageUrl = blog.image;
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
                                    'title': blog.title,
                                    'details': blog.details,
                                  },
                                );
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Text(
                                  blog.title, // Use the actual title from the blog data
                                  textAlign: TextAlign.right,
                                ),
                                leading: isOffline
                                    ? snapshot.data != null
                                        ? Image.file(snapshot.data!)
                                        : null // Use the cached image
                                    : Image.network(imageUrl),
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
