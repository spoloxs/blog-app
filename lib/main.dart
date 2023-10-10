import 'package:blog_app/bloc/wishlist_bloc.dart';
import 'package:blog_app/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'blogdetails_screen.dart';
import 'bloglist_screen.dart';
import 'routes.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WishlistBloc(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const BlogListScreen(),
    const WishlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      theme: ThemeData.dark(),
      routes: {
        Routes.blogList: (context) => const BlogListScreen(),
        Routes.blogDetails: (context) {
          // Extract arguments from the route settings
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return BlogDetailsScreen(
            imageFile: args['imageFile'],
            title: args['title'] as String,
            details: args['details'] as String?,
          );
        },
        Routes.blogWishlist: (context) => WishlistScreen()
      },
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: _currentIndex == 0
              ? const Text('Explore Blogs')
              : const Text('Favorite Blogs'),
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore Page',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
          ],
        ),
      ),
    );
  }
}
