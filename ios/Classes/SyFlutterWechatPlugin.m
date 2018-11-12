#import "SyFlutterWechatPlugin.h"

@interface SyFlutterWechatPlugin()

@property FlutterResult result;

@end

@implementation SyFlutterWechatPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"sy_flutter_wechat"
            binaryMessenger:[registrar messenger]];
  SyFlutterWechatPlugin* instance = [[SyFlutterWechatPlugin alloc] init];
    [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"register" isEqualToString:call.method]) {
      BOOL res = [WXApi registerApp:call.arguments[@"appId"]];
      result(@((bool)res));
  }else if ([@"shareText" isEqualToString:call.method]) {
      [self shareText:call result:result];
  }else if ([@"shareImage" isEqualToString:call.method]) {
      [self shareImage:call result:result];
  }else if ([@"shareWebPage" isEqualToString:call.method]) {
      [self shareWebPage:call result:result];
  }else if ([@"pay" isEqualToString:call.method]) {
      self.result = result;
      [self pay:call result:result];
  }else {
      result(FlutterMethodNotImplemented);
  }
}


- (void)shareText:(FlutterMethodCall*)call result:(FlutterResult)result{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.text = call.arguments[@"text"];
    req.bText = YES;
    req.scene = [self _convertShareType:call];
    BOOL res = [WXApi sendReq:req];
    result(@((bool)res));
}

- (void)shareImage:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *imageUrl = call.arguments[@"imageUrl"];
    NSData *imageData =[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];;
    UIImage *originImage = [UIImage imageWithData:imageData];
    
    WXImageObject *imageObj = [WXImageObject object];
    imageObj.imageData = imageData;
    
    WXMediaMessage *mediaMsg = [WXMediaMessage message];
    mediaMsg.mediaObject = imageObj;
    
    UIImage *thumbImage = [self compressImage:originImage toByte:32768];
    [mediaMsg setThumbImage:thumbImage];
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = mediaMsg;
    req.bText = NO;
    req.scene = [self _convertShareType:call];
    BOOL res = [WXApi sendReq:req];
    result(@((bool)res));
}

- (void)shareWebPage:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *imageUrl = call.arguments[@"imageUrl"];
    
    NSData *imageData =[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];;
    UIImage *originImage = [UIImage imageWithData:imageData];
    UIImage *thumbImage = [self compressImage:originImage toByte:32768];
    
    WXWebpageObject* webObj = [WXWebpageObject object];
    webObj.webpageUrl = call.arguments[@"webPageUrl"];

    WXMediaMessage *mediaMsg = [WXMediaMessage message];
    mediaMsg.title = call.arguments[@"title"];
    mediaMsg.description = call.arguments[@"description"];
    [mediaMsg setThumbImage:thumbImage];
    mediaMsg.mediaObject = webObj;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.message = mediaMsg;
    req.bText = NO;
    req.scene = [self _convertShareType:call];
    BOOL res = [WXApi sendReq:req];
    result(@((bool)res));
}

//支付
- (void)pay:(FlutterMethodCall*)call result:(FlutterResult)result{
    PayReq *req = [[PayReq alloc] init];
    req.partnerId = call.arguments[@"partnerid"];
    req.prepayId= call.arguments[@"prepayid"];
    req.package = call.arguments[@"package"];
    req.nonceStr= call.arguments[@"noncestr"];
    req.timeStamp= [call.arguments[@"timestamp"] unsignedIntValue];
    req.sign= call.arguments[@"sign"];
    [WXApi sendReq:req];
}



- (enum WXScene)_convertShareType:(FlutterMethodCall*)call{
    NSString *shareType = call.arguments[@"shareType"];
    if([shareType isEqualToString:@"session"]){
        return WXSceneSession;
    }else if([shareType isEqualToString:@"timeline"]){
        return WXSceneTimeline;
    }else if([shareType isEqualToString:@"favorite"]){
        return WXSceneFavorite;
    }
    return WXSceneSession;
}


//生成分享缩略图
//链接：https://www.jianshu.com/p/a45d99ffccf6
//toByte 缩略图要小于32KB
- (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}


- (void) onReq:(BaseReq *)req{
    NSLog(@"onReq....");
}

- (void) onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[PayResp class]]){
        self.result(@(resp.errCode));
        NSLog(@"支付结果：retcode = %d, retstr = %@",resp.errCode,resp.errStr);
    }
    NSLog(@"回调结果：retcode = %d, retstr = %@",resp.errCode,resp.errStr);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    if([url.host isEqualToString:@"pay"]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

@end
