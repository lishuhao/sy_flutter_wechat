package plugin.wechat.flutter.isanye.cn.syflutterwechat.wxapi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;

import plugin.wechat.flutter.isanye.cn.syflutterwechat.SyFlutterWechatPlugin;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler{
    private static final String TAG = "WXPayEntryActivity";
    //微信支付
    private IWXAPI iwxapi;

    @Override
    protected void onCreate( Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        iwxapi = StateManager.getAPi();
        iwxapi.handleIntent(getIntent(), this);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        iwxapi.handleIntent(intent, this);
    }

    @Override
    public void onReq(BaseReq baseReq) {
        Log.e(TAG,"req");
    }

    @Override
    public void onResp(BaseResp baseResp) {
        Log.e(TAG,"微信支付回调");

        //微信支付
        if(baseResp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX){
            Log.e(TAG,"errCode:"+String.valueOf(baseResp.errCode));
            Intent i = new Intent(SyFlutterWechatPlugin.filterName);
            i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            i.putExtra("errCode", baseResp.errCode);
            this.sendBroadcast(i);
        }
        finish();
        Log.e(TAG,baseResp.errStr);
    }
}
