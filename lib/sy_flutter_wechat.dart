import 'dart:async';

import 'package:flutter/services.dart';

/// share scene
enum SyShareType {
  session,

  /// share to friend
  timeline,

  /// share to timeline
  favorite

  /// collect
}

/// pay result
enum SyPayResult {
  /// success
  success,

  /// fail
  fail,

  /// cancel
  cancel,
}

/// wechat class
class SyFlutterWechat {
  static const MethodChannel _channel =
      const MethodChannel('sy_flutter_wechat');

  /// register app id
  static Future<bool> register(String appId) async {
    return await _channel
        .invokeMethod('register', <String, dynamic>{'appId': appId});
  }

  /// shareText
  static Future<bool> shareText(String text, {SyShareType shareType}) async {
    return await _channel.invokeMethod('shareText', <String, dynamic>{
      'text': text,
      'shareType': _shareTypeToStr(shareType)
    });
  }

  /// shareImage
  static Future<bool> shareImage(String imageUrl,
      {SyShareType shareType}) async {
    return await _channel.invokeMethod('shareImage', <String, dynamic>{
      'imageUrl': imageUrl,
      'shareType': _shareTypeToStr(shareType)
    });
  }

  /// shareWebPage
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

  /// pay
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

/// pay args
///
/// 参考微信文档 https://pay.weixin.qq.com/wiki/doc/api/app/app.php?chapter=9_12&index=2
class SyPayInfo {
  /// appid
  String appid;

  /// partnerid
  String partnerid;

  /// prepayid
  String prepayid;

  /// package
  String package;

  /// noncestr
  String noncestr;

  /// timestamp
  String timestamp;

  /// sign
  String sign;

  SyPayInfo({
    this.appid,
    this.partnerid,
    this.prepayid,
    this.package,
    this.noncestr,
    this.timestamp,
    this.sign,
  });

  /// from json
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
