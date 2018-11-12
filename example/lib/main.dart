import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sy_flutter_wechat/sy_flutter_wechat.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _register();
  }

  _register() async {
    bool result = await SyFlutterWechat.register('wxf9909bde17439ac2');
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new ListView(
          padding: EdgeInsets.all(8.0),
          children: <Widget>[
            RaisedButton(
              child: Text('分享文字'),
              onPressed: () async {
                bool res = await SyFlutterWechat.shareText('hello world',
                    shareType: SyShareType.session);
                print('分享文字：' + res.toString());
              },
            ),
            RaisedButton(
              child: Text('分享图片'),
              onPressed: () async {
                bool res = await SyFlutterWechat.shareImage(
                    'https://avatars0.githubusercontent.com/u/10024776',
                    shareType: SyShareType.timeline);
                print('分享图片：' + res.toString());
              },
            ),
            RaisedButton(
              child: Text('分享网页'),
              onPressed: () async {
                bool res = await SyFlutterWechat.shareWebPage(
                    '标题',
                    '描述',
                    'https://avatars0.githubusercontent.com/u/10024776',
                    'http://www.example.com',
                    shareType: SyShareType.session);
                print('分享网页：' + res.toString());
              },
            ),
            RaisedButton(
              child: Text('支付'),
              onPressed: () async {
                String payInfo =
                    '{"appid":"wxf9909bde17439ac2","partnerid":"1518469211","prepayid":"wx120649521695951d501636f91748325073","package":"Sign=WXPay","noncestr":"1541976592","timestamp":"1541976592","sign":"E760C99A1A981B9A7D8F17B08EF60FCC"}';
                SyPayResult payResult = await SyFlutterWechat.pay(
                    SyPayInfo.fromJson(json.decode(payInfo)));
                print(payResult);
              },
            ),
          ],
        ),
      ),
    );
  }
}
