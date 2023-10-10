import 'package:flutter/material.dart';

class BlogDetailsScreen extends StatelessWidget {
  final Image imageFile;
  final String title;
  final String? details;

  BlogDetailsScreen({
    required this.imageFile,
    required this.title,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Display the image at the top
            imageFile,

            // Display the title in big and bold
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),

            // Display the details (if available)
            if (details != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  details!,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
