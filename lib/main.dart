import 'dart:convert';
import 'package:blog_explorer/FavoriteProvider.dart';
import 'package:blog_explorer/FavoritesScreen.dart';
import 'package:blog_explorer/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_explorer/DetailedScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

void main() async {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => FavoriteProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;
  List blogData = [];
  late SharedPreferences prefs;
  final dio = Dio();

  @override
  void initState() {
    fetchBlogs();
    getInstance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Blogs and Articles'),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: isLoading
            ? Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Container(
                padding: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: blogData
                        .map((e) => Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                  onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              DetailedScreen(detail: e),
                                        ),
                                      ),
                                  contentPadding: EdgeInsets.all(10),
                                  isThreeLine: true,
                                  title: Container(
                                    padding: EdgeInsets.all(10),
                                    child: FadeInImage(
                                        placeholder:
                                            AssetImage('assets/place.png'),
                                        imageErrorBuilder: (context, obj, st) {
                                          return Container(
                                            child: Image(
                                                image: AssetImage(
                                                    'assets/place.png')),
                                          );
                                        },
                                        image: NetworkImage(e["image_url"],
                                            headers: {
                                              'x-hasura-admin-secret':
                                                  ADMIN_SECRET_KEY
                                            })),
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
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                        'Removed from Favorites!',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                      ),
                                                      backgroundColor:
                                                          Colors.grey.shade900,
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ));
                                                  } else {
                                                    favoriteProvider
                                                        .addBlog(e["id"]);
                                                    favoriteProvider.storeData(
                                                        e, true);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: Text(
                                                        'Added to Favorites!',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16),
                                                      ),
                                                      backgroundColor:
                                                          Colors.grey.shade900,
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      behavior: SnackBarBehavior
                                                          .floating,
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
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Go to Favorites',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoriteScreen(),
            ),
          );
        },
        child: Icon(Icons.open_in_new),
      ),
    );
  }

  void fetchBlogs() async {
    final String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
    final String adminSecret = ADMIN_SECRET_KEY;

    try {
      final response = await dio.get(url,
          options: Options(headers: {'x-hasura-admin-secret': adminSecret}));

      if (response.statusCode == 200) {
        List d = response.data['blogs'];
        setState(() {
          blogData = d;
          isLoading = false;
        });
      } else {
        print('Request failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Your request cannot be processed at the moment',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.grey.shade900,
        margin: EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        isLoading = false;
      });
    }
  }

  getInstance() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString('favorites') == null) {
      prefs.setString('favorites', jsonEncode([]));
    }
  }
}
