import 'dart:convert';

import 'package:blog_explorer/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FavoriteProvider.dart';

class DetailedScreen extends StatefulWidget {
  final Map detail;
  DetailedScreen({required this.detail, Key? key}) : super(key: key);

  @override
  State<DetailedScreen> createState() => _DetailedScreenState(this.detail);
}

class _DetailedScreenState extends State<DetailedScreen> {
  Map detail;
  _DetailedScreenState(this.detail);
  late SharedPreferences prefs;
  List favorites = [];

  @override
  void initState() {
    getInstance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog View'),
        actions: [
          Consumer<FavoriteProvider>(builder:
              (BuildContext context, FavoriteProvider value, Widget? child) {
            return IconButton(
                onPressed: () {
                  setState(() {
                    if (favoriteProvider.isFav(detail["id"])) {
                      favoriteProvider.removeBlog(detail["id"]);
                      favoriteProvider.storeData(detail, false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Removed from Favorites!',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        backgroundColor: Colors.grey.shade900,
                        margin: EdgeInsets.all(10),
                        behavior: SnackBarBehavior.floating,
                      ));
                    } else {
                      favoriteProvider.addBlog(detail["id"]);
                      favoriteProvider.storeData(detail, true);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Added to Favorites!',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        backgroundColor: Colors.grey.shade900,
                        margin: EdgeInsets.all(10),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  });
                },
                icon: Icon(
                  Icons.favorite,
                  color: value.isFav(detail["id"]) ? Colors.red : Colors.grey,
                ));
          })
        ],
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: FadeInImage(
                  placeholder: AssetImage('assets/place.png'),
                  imageErrorBuilder: (context, obj, st) {
                    return Container(
                      child: Image(image: AssetImage('place.png')),
                    );
                  },
                  image: NetworkImage(detail["image_url"],
                      headers: {'x-hasura-admin-secret': ADMIN_SECRET_KEY})),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              detail["title"],
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  getInstance() async {
    prefs = await SharedPreferences.getInstance();
  }
}
