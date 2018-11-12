package plugin.wechat.flutter.isanye.cn.syflutterwechat;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXTextObject;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URL;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import plugin.wechat.flutter.isanye.cn.syflutterwechat.wxapi.StateManager;

/** SyFlutterWechatPlugin */
public class SyFlutterWechatPlugin implements MethodCallHandler {

  private static final String TAG = "SyFlutterWechatPlugin>>";
  public static final String filterName = "wxCallback";
  private IWXAPI wxApi;
  private Registrar registrar;
  private static Result result;
  private static final int THUMB_SIZE = 150;


  //微信支付回调
  private static BroadcastReceiver wxpayCallbackReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      Integer errCode = intent.getIntExtra("errCode",-3);
      Log.e(TAG,errCode.toString());
      result.success(errCode);
    }
  };

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "sy_flutter_wechat");
    final SyFlutterWechatPlugin plugin = new SyFlutterWechatPlugin(registrar);
    channel.setMethodCallHandler(plugin);
    registrar.context().registerReceiver(wxpayCallbackReceiver,new IntentFilter(filterName));
  }

  private SyFlutterWechatPlugin(Registrar registrar){
    this.registrar = registrar;
  }


  @Override
  public void onMethodCall(MethodCall call, Result result) {
    SyFlutterWechatPlugin.result = result;
    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "register":
        this.registerToWX(call,result);
        break;
      case "shareText":
        this.shareText(call,result);
        break;
      case "shareImage":
        this.shareImage(call,result);
        break;
      case "shareWebPage":
        this.shareWebPage(call,result);
        break;
      case "pay":
        this.pay(call);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  //注册微信app id
  private void registerToWX(MethodCall call, Result result){
    String appId = call.argument("appId");
    wxApi = WXAPIFactory.createWXAPI(registrar.context(),appId);
    boolean res =wxApi.registerApp(appId);
    StateManager.setApi(wxApi);
    result.success(res);
  }

  private void shareText(MethodCall call, Result result){
    String text = call.argument("text");
    String shareType = call.argument("shareType");

    WXTextObject textObj = new WXTextObject();
    textObj.text = text;

    WXMediaMessage msg = new WXMediaMessage();
    msg.mediaObject = textObj;
    msg.description = text;

    SendMessageToWX.Req req = new SendMessageToWX.Req();
    req.scene = _convertShareType(shareType);
    req.message = msg;
    //req.transaction = buildTransaction("");
    boolean res = wxApi.sendReq(req);
    //result.success(res);
  }

  private void shareImage(final MethodCall call, final Result result){
    final String imageUrl = call.argument("imageUrl");
    final String shareType = call.argument("shareType");
    new Thread(new Runnable() {
        WXMediaMessage msg = new WXMediaMessage();
        @Override
        public void run() {
          try {
            Bitmap bmp = BitmapFactory.decodeStream(new URL(imageUrl).openStream());
            WXImageObject imageObject = new WXImageObject(bmp);
            Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);

            msg.mediaObject = imageObject;
            bmp.recycle();
            msg.thumbData = SyFlutterWechatPlugin.bmpToByteArray(thumbBmp, true);
          }catch (IOException e){
            e.printStackTrace();
          }

          SendMessageToWX.Req req = new SendMessageToWX.Req();
          req.scene = _convertShareType(shareType);
          req.message = msg;
          boolean res = wxApi.sendReq(req);
          result.success(res);
        }
      }
    ).start();
  }

  private void shareWebPage(final MethodCall call, final Result result){
    final String title = call.argument("title");
    final String description = call.argument("description");
    final String imageUrl = call.argument("imageUrl");
    final String webPageUrl = call.argument("webPageUrl");
    final String shareType = call.argument("shareType");
    new Thread(new Runnable() {
      WXWebpageObject webPage = new WXWebpageObject();

      @Override
      public void run() {
        webPage.webpageUrl = webPageUrl;
        WXMediaMessage msg = new WXMediaMessage(webPage);
        msg.title = title;
        msg.description = description;
        try {
          Bitmap bmp = BitmapFactory.decodeStream(new URL(imageUrl).openStream());
          Bitmap thumbBmp = Bitmap.createScaledBitmap(bmp, THUMB_SIZE, THUMB_SIZE, true);
          bmp.recycle();
          msg.thumbData = SyFlutterWechatPlugin.bmpToByteArray(thumbBmp, true);
        }catch (IOException e){
          e.printStackTrace();
        }

        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.scene = _convertShareType(shareType);
        req.message = msg;
        boolean res = wxApi.sendReq(req);
        result.success(res);
      }
    }
    ).start();
  }

  //调起微信支付
  private void pay(MethodCall call){
    PayReq req = new PayReq();
    req.appId = call.argument("appid");
    req.partnerId = call.argument("partnerid");
    req.prepayId= call.argument("prepayid");
    req.packageValue = call.argument("package");
    req.nonceStr= call.argument("noncestr");
    req.timeStamp= call.argument("timestamp");
    req.sign= call.argument("sign");
    wxApi.sendReq(req);
  }


  private static int _convertShareType(String shareType){
    switch (shareType){
      case "session":
        return SendMessageToWX.Req.WXSceneSession;
      case "timeline":
        return SendMessageToWX.Req.WXSceneTimeline;
      case "favorite":
        return SendMessageToWX.Req.WXSceneFavorite;
      default:
        return SendMessageToWX.Req.WXSceneSession;
    }
  }

  private static byte[] bmpToByteArray(final Bitmap bmp, final boolean needRecycle) {
    ByteArrayOutputStream output = new ByteArrayOutputStream();
    bmp.compress(Bitmap.CompressFormat.PNG, 100, output);
    if (needRecycle) {
      bmp.recycle();
    }

    byte[] result = output.toByteArray();
    try {
      output.close();
    } catch (Exception e) {
      e.printStackTrace();
    }

    return result;
  }

}
