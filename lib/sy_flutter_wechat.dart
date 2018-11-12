import 'dart:async';

import 'package:flutter/services.dart';

//分享或收藏的目标场景
enum SyShareType {
  session, //分享给朋友
  timeline, //分享到朋友圈
  favorite //添加到微信收藏
}

//支付结果
enum SyPayResult { success, fail, cancel }

class SyFlutterWechat {
  static const MethodChannel _channel =
      const MethodChannel('sy_flutter_wechat');

  //注册微信app id
  static Future<bool> register(String appId) async {
    return await _channel
        .invokeMethod('register', <String, dynamic>{'appId': appId});
  }

  static Future<bool> shareText(String text, {SyShareType shareType}) async {
    return await _channel.invokeMethod('shareText', <String, dynamic>{
      'text': text,
      'shareType': _shareTypeToStr(shareType)
    });
  }

  static Future<bool> shareImage(String imageUrl,
      {SyShareType shareType}) async {
    return await _channel.invokeMethod('shareImage', <String, dynamic>{
      'imageUrl': imageUrl,
      'shareType': _shareTypeToStr(shareType)
    });
  }

  static Future<bool> shareWebPage(
      String title, String description, String imageUrl, String webPageUrl,
      {SyShareType shareType}) async {
    return await _channel.invokeMethod('shareWebPage', <String, dynamic>{
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'webPageUrl': webPageUrl,
      'shareType': _shareTypeToStr(shareType)
    });
  }

  //支付
  static Future<SyPayResult> pay(SyPayInfo payInfo) async {
    int payResult = await _channel.invokeMethod('pay', <String, dynamic>{
      'appid': payInfo.appid,
      'partnerid': payInfo.partnerid,
      'prepayid': payInfo.prepayid,
      'package': payInfo.package,
      'noncestr': payInfo.noncestr,
      'timestamp': payInfo.timestamp,
      'sign': payInfo.sign,
    });
    return _convertPayResult(payResult);
  }

  static String _shareTypeToStr(SyShareType shareType) {
    switch (shareType) {
      case SyShareType.session:
        return 'session';
      case SyShareType.timeline:
        return 'timeline';
      case SyShareType.favorite:
        return 'favorite';
      default:
        return 'session';
    }
  }

  static SyPayResult _convertPayResult(int payResult) {
    switch (payResult) {
      case 0:
        return SyPayResult.success;
      case -1:
        return SyPayResult.fail;
      case -2:
        return SyPayResult.cancel;
      default:
        return null;
    }
  }
}

//支付参数
//参考微信文档 https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=9_12&index=2
class SyPayInfo {
  String appid;
  String partnerid;
  String prepayid;
  String package;
  String noncestr;
  String timestamp;
  String sign;

  SyPayInfo(
      {this.appid,
      this.partnerid,
      this.prepayid,
      this.package,
      this.noncestr,
      this.timestamp,
      this.sign});

  factory SyPayInfo.fromJson(Map<String, dynamic> json) {
    return SyPayInfo(
      appid: json['appid'],
      partnerid: json['partnerid'],
      prepayid: json['prepayid'],
      package: json['package'],
      noncestr: json['noncestr'],
      timestamp: json['timestamp'],
      sign: json['sign'],
    );
  }
}
