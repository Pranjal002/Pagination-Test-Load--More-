import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _baseurl = 'https://jsonplaceholder.typicode.com/posts';
  int _page = 0;
  final int _limit = 20;
  bool _hasNextpage = true;
  bool _isFirstLoadRunning = false;
  bool _isloadingmore = false;
  List _posts = [];
  void _loadMore() async {
    if (_hasNextpage == true &&
        _isFirstLoadRunning == false &&
        _isloadingmore == false) {
      setState(() {
        _isloadingmore = true;
      });
      _page += 1;
      try {
        final res =
            await http.get(Uri.parse("$_baseurl?_page=$_page&_limit=$_limit"));
        final List fetchposts = json.decode(res.body);
        if (fetchposts.isNotEmpty) {
          setState(() {
            _posts.addAll(fetchposts);
          });
        } else {
          setState(() {
            _hasNextpage = false;
          });
        }
      } catch (err) {
        if (kDebugMode) {
          print("Something is wrong");
        }
      }
      setState(() {
        _isFirstLoadRunning = false;
      });

      setState(() {
        _isloadingmore = false;
      });
    }
  }

  void _firstload() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final res =
          await http.get(Uri.parse("$_baseurl?_page=$_page&_limit=$_limit"));
      setState(() {
        _posts = jsonDecode(res.body);
      });
    } catch (err) {
      if (kDebugMode) {
        print("Something is wrong");
      }
    }
    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  late ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _firstload();
    _controller = ScrollController()..addListener(_loadMore);
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: _isFirstLoadRunning
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: _posts.length,
                          controller: _controller,
                          itemBuilder: (_, index) => Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                child: ListTile(
                                  title: Text(_posts[index]['title']),
                                  subtitle: Text(_posts[index]['body']),
                                ),
                              ))
                  ),
                  if (_isloadingmore ==true)
                    const Padding(padding: EdgeInsets.only(top: 10, bottom: 40),child: Center(child: CircularProgressIndicator( ),),)
                ],
              ));
  }
}
