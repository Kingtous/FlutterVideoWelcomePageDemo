import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '视频引导页Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '视频引导页Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  VideoPlayerController _playerController;
  VideoPlayer _player;

  int cSecond = 0;
  int titleIndex = -1;

  // 结束按钮
  bool _showEnd = false;

  void resume() {
    print("next");
    setState(() {
      _playerController.play();
    });
  }

  void end() {
    _playerController.removeListener(listen);
    setState(() {
      _playerController.pause();
    });
    print("end");
    exit(0);
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }

  void listen(){
    titleIndex = secArr.indexOf(_playerController.value.position.inSeconds);
    if ( titleIndex != -1 &&
        _playerController.value.isPlaying &&
        cSecond != _playerController.value.position.inSeconds) {
      // 5秒暂停
      print("已暂停");
      setState(() {
        _playerController.pause();
      });
    }

    if (_playerController.value.duration ==
        _playerController.value.position &&
        !_playerController.value.isPlaying) {
      // 到尾部
      setState(() {
        _showEnd = true;
      });
    }

    cSecond = _playerController.value.position.inSeconds;
  }

  var secArr = [4, 38, 64, 90, 138];
  var srr = ["开启回忆","只能不知所措了吗？","真的无能为力了吗？","不再怀疑！","改变自己！"];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    _playerController = new VideoPlayerController.asset("video/video.flv")
      ..addListener(listen);
    _playerController.initialize().then((_) {
      setState(() {});
    });
    _player = new VideoPlayer(_playerController);
    setState(() {
      _playerController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          body: Container(
              child: Stack(
        children: <Widget>[
          _player,
          Container(
              alignment: Alignment.bottomCenter,
              child: _playerController.value.isPlaying
                  ? null
                  : CupertinoButton(
                      child: Text(
                        titleIndex>=0?
                        srr[titleIndex]:"next",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: resume,
                      color: Colors.transparent,
                    )),
          Container(
              alignment: Alignment.bottomCenter,
              child: !_showEnd
                  ? null
                  : CupertinoButton(
                child: Text(
                  "此时有你有我",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: end,
                color: Colors.blueGrey,
              )),
          Container(
            padding: EdgeInsets.all(24.0),
            alignment: Alignment.topLeft,
            child: GestureDetector(
              child: Text(
                "跳过",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
               end();
              },
            ),
          )
        ],
      ))), onWillPop: () {
        end();
        return Future.value(true);
    },
    );
  }
}
