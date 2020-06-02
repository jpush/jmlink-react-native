import {
    DeviceEventEmitter,
    NativeModules,
    Platform,
} from 'react-native';

const JMLinkModule = NativeModules.JMLinkModule;

const listeners = {};
const ParamEvent = 'ParamEvent';  //获取参数事件

export default class JMLink {
    /**
     * SDK初始化
     * @param params = {'debug':bool,'clipEnabled':bool,'appkey':String,'channel':String,'advertisingId':String,'isProduction':boolean}
     * debug: bool  设置调试模式，默认关闭状态
     * clipEnabled: bool 是否开启剪切板，false关闭，true开启   默认开启，无果没有特殊原因不推荐关闭
     * appkey：极光系统应用唯一标识，必填                                                             (仅ios)
     * channel:应用发布渠道，可选                                                                   (仅ios)
     * advertisingId:广告标识符，可选                                                               (仅ios)
     * isProduction:是否生产环境。如果为开发状态，设置为false；如果为生产状态，应改为true。默认为false,可选   (仅ios)
     */
    static init(params) {
        if (Platform.OS == 'android') {
            JMLinkModule.init(params);
        } else {
            JMLinkModule.setupWithConfig(params);
        }
    }

     /*
     * 获取参数事件监听
     * @param callback = result => {"params":{"key":"value",},"dynpParams":{"key","value"}}
     * */
    static register(callback) {
        if (listeners[callback]) {
            listeners[callback].remove();
            listeners[callback] = null;
        }
        listener = DeviceEventEmitter.addListener(
            ParamEvent, result => {
                callback(result);
            });
        
        if (Platform.OS == 'android') {
            JMLinkModule.getParams()
        } else {
            JMLinkModule.registerEvent();
        }  
    }

    //移除事件
    static unregister(callback) {
        if (!listeners[callback]) {
            return;
        }
        listeners[callback].remove();
        listeners[callback] = null;
    }

    static log(tag, msg) {
        if (Platform.OS == 'android') {
            JMLinkModule.logE(tag,msg);
        } else {
            JMLinkModule.ioslog(msg);
        } 
    }

}
