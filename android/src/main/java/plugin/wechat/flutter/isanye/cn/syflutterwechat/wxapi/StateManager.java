package plugin.wechat.flutter.isanye.cn.syflutterwechat.wxapi;

import com.tencent.mm.opensdk.openapi.IWXAPI;

//保存wxapi供微信支付回调时使用
public class StateManager {

    private static IWXAPI wxapi = null;

    public static void setApi(IWXAPI wxapi){
        StateManager.wxapi = wxapi;
    }

    public static IWXAPI getAPi(){
        return StateManager.wxapi;
    }
}
