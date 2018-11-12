# sy_flutter_wechat

微信SDK flutter插件，支持Android和iOS

- [x] 微信支付
- [x] 分享文字
- [x] 分享图片
- [x] 分享链接
- [ ] 分享音乐
- [ ] 分享视频
- [ ] 分享小程序

分享图片及链接暂时仅支持 **网络图片** ，
iOS分享网络图片如果不是 **HTTPS** 的话可能会失败，因为iOS ATS问题

### 使用方法

#### Android
无需配置

#### iOS
1. 参考 [微信文档](https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=8_5) 项目设置APPID
1. 修改 Background Modes，勾选以下两项，否则可能会收不到微信回调
![](https://raw.githubusercontent.com/lishuhao/assets/master/sy_flutter_wechat/background_mode.jpg)

### 示例代码

```dart
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
```

####
其它Flutter plugin

- [支付宝](https://github.com/lishuhao/sy_flutter_alipay)
- [Flutter组件库](https://github.com/lishuhao/sy_flutter_widgets)
- [高德定位](https://github.com/lishuhao/sy_flutter_amap)
- [七牛云存储SDK](https://github.com/lishuhao/sy_flutter_qiniu_storage)