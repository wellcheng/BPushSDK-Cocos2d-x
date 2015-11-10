

#include "ccConfig.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#import "cocos2d.h"

#define mpush_dispatch_selector(_SELECTOR) (DispatchCallFunc)(&_SELECTOR)
typedef void (cocos2d::Application::*DispatchCallFunc)(cocos2d::Value);


USING_NS_CC;

class CC_DLL BPushService {
private:
    BPushService();
    ~BPushService();
    
public:
    /**
     *  @brief 向 server 发送绑定请求，绑定成功后即可进行远程推送。
     *  @param target:  接收回调结果的对象
     *  @param selector:  接收回调结果的函数
     *
     *  @return 最终返回值类型为 cocos2d:Value 类型。
     */
    static void bindChannelWithCallback(cocos2d::Application *target, DispatchCallFunc selector);

    /**
     *  @brief 向 server 发送解除绑定的请求，解除绑定成功后，通知将不会被推送到该设备上。
     *  @param target:  接收回调结果的对象
     *  @param selector:  接收回调结果的函数
     *
     *  @return 最终返回值类型为 cocos2d:Value 类型。
     */
    static void unbindChannelWithCallback(cocos2d::Application *target, DispatchCallFunc selector);
    
    /**
     *  @brief 向 server 发送设置 tag 的请求，设置成功后该设备将绑定指定的 tag，且该设备将能收到对应 tag 的组播推送。
     *  @param target:  接收回调结果的对象
     *  @param selector:  接收回调结果的函数
     *  @param jsonString:  tag 数组的 json 字符串, 数组元素为字符串类型
     *
     *  @return 最终返回值类型为 cocos2d:Value 类型。
     */
    static void setTagsJSONWithCallback(cocos2d::Application *target, DispatchCallFunc selector, const std::string &jsonString);
    
    /**
     *  @brief 向 server 发送删除 tag 的请求，删除成功后该设备将不再收到来自相应 tag 的组播推送。
     *  @param target:  接收回调结果的对象
     *  @param selector:  接收回调结果的函数
     *  @param jsonString:  tag 数组的 json 字符串, 数组元素为字符串类型
     *
     *  @return 最终返回值类型为 cocos2d:Value 类型。
     */
    static void delTagsJSONWithCallback(cocos2d::Application *target, DispatchCallFunc selector, const std::string &jsonString);
    
    /**
     *  @brief 向 server 发送列出 tag 请求，请求成功时返回当前设备绑定的所有 tag
     *  @param target:  接收回调结果的对象
     *  @param selector:  接收回调结果的函数
     *
     *  @return 最终返回值类型为 cocos2d:Value 类型。
     */
    static void listTagsJSONWithCallback(cocos2d::Application *target, DispatchCallFunc selector);
    
    /**
     *  @brief 获取当前设备的 channelid，channelid 唯一标识一台设备。
     *  @param target:  接收回调结果的对象
     *  @param selector:  接收回调结果的函数
     *
     *  @return 最终返回值类型为 cocos2d:Value 类型。
     */
    static void getChannelidWithCallback(cocos2d::Application *target, DispatchCallFunc selector);
    
    /**
     *  @brief 获取当前应用在百度云推送服务上注册的 appid
     *  @param target:  接收回调结果的对象
     *  @param selector:  接收回调结果的函数
     *
     *  @return 最终返回值类型为 cocos2d:Value 类型。
     */
    static void getAppidWithCallback(cocos2d::Application *target, DispatchCallFunc selector);
};


#endif