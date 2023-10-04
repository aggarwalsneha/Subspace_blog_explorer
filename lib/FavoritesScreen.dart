import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FavoriteProvider.dart';
import 'constants.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late SharedPreferences prefs;
  List favorites = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Favourites'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: favorites
                    .map((e) => Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              isThreeLine: true,
                              title: Container(
                                padding: EdgeInsets.all(10),
                                child: FadeInImage(
                                    placeholder: AssetImage('assets/place.png'),
                                    imageErrorBuilder: (context, obj, st) {
                                      return Container(
                                        child: Image(
                                            image:
                                                AssetImage('assets/place.png')),
                                      );
                                    },
                                    image: NetworkImage(
                                      e["image_url"],
                                    )),
                              ),
                              subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e["title"],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        softWrap: true,
                                      ),
                                    ),
                                    Consumer<FavoriteProvider>(builder:
                                        (BuildContext context,
                                            FavoriteProvider value,
                                            Widget? child) {
                                      return IconButton(
                                          onPressed: () {
                                            setState(() {
                                              if (favoriteProvider
                                                  .isFav(e["id"])) {
                                                favoriteProvider
                                                    .removeBlog(e["id"]);
                                                favoriteProvider.storeData(
                                                    e, false);
                                                getData();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                    'Removed from Favorites!',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey.shade900,
                                                  margin: EdgeInsets.all(10),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ));
                                              } else {
                                                favoriteProvider
                                                    .addBlog(e["id"]);
                                                favoriteProvider.storeData(
                                                    e, true);
                                                getData();
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text(
                                                    'Added to Favorites!',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey.shade900,
                                                  margin: EdgeInsets.all(10),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ));
                                              }
                                            });
                                          },
                                          icon: Icon(
                                            Icons.favorite,
                                            color: value.isFav(e["id"])
                                                ? Colors.red
                                                : Colors.grey,
                                          ));
                                    })
                                  ])),
                        ))
                    .toList()),
          ),
        ));
  }

  getData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites = jsonDecode(prefs.getString('favorites')!);
    });
    print(favorites);
  }
}
