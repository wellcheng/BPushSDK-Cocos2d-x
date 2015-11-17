# BPushSDK-Cocos2d-x
百度云推送 Cocos2d-x 第三方 SDK

# 百度云推送 Cocos2d-x 集成文档（iOS）

百度云推送 iOS SDK ，在 Cocos2d-x 平台上的集成插件。

本文档介绍如何将百度云推送集成到 Cocos2d-x 平台上，使得 iOS 平台下的 App 能够使用推送服务。

## Cocos2d-x 版本要求

目前只支持到 Cocos2d-x 3.x 及以上版本。

## 集成百度云推送 Cocos2d-x iOS SDK

iOS 推送服务主要依赖于 Apple 自家的 APNs。开发者首先需要到 Apple 官网上为当前 App 注册推送证书，然后在客户端通过代码请求使用推送服务，用户允许后可获取一个叫 device token 的标识，用于标识这台设备。

然后就可以在服务端拿着 Apple 给你的推送证书与 APNs 建立 SSL 长连接进行消息推送，推送的消息内容称为 payload。

Payload 中包含了一条推送消息的所有信息，包括消息主体内容，这条消息要推送到的 deviceToken（设备）等。

### 制作 iOS 推送证书

有关证书制作的过程可以参考：[百度云推送 iOS 推送证书指导](http://push.baidu.com/doc/ios/api)

对于 iOS 推送的相关了解可参考：[百度云推送 iOS 推送简介](http://push.baidu.com/doc/ios/api)

### 在百度云推送官网注册 App

在使用百度云推送服务之前，还需要在官网上注册成为百度开发者并在云推送官网注册 App。注册 App 后即可进行管理该 App 的推送业务，在控制台可进行消息的推送，数据报表查看等一系列操作。

注册成功后，在控制台中上传刚才创建的开发证书和生产证书。

### 导入 SDK 到当前的工程中

将 `BaiduPush-Cocos2dx-SDK-iOS` 文件夹复制到你 Cocos2d-x 工程的 Class 文件夹下。

使用 Xcode 打开 Cocos2d-x 中 `proj.ios_mac` 项目，将刚才 Class 文件夹下的百度云推送 SDK 添加到项目中，如下图所示：

![将 SDK 添加到当前 iOS 项目中](http://7vzucb.com1.z0.glb.clouddn.com/blog.customImage/Cocos2d/cocos-1.png)

添加完成后如下图所示：

![添加 SDK 完成之后的工程视图](http://7vzucb.com1.z0.glb.clouddn.com/blog.customImage/Cocos2d/cocos-2.png)

### 添加必要的系统框架

SDK 运行还依赖一些系统库，需要添加到当前的 iOS 项目中。

鼠标选择当前的项目，在中间视图窗口中选择 mobile 类型的 target，然后在上面选择 General 栏目，往下滑动就能看到当前项目依赖的系统库，如图：

![当前 iOS 工程依赖的系统库](http://7vzucb.com1.z0.glb.clouddn.com/blog.customImage/Cocos2d/cocos-3.png)



检查 `Foundation.framework`、`CoreTelephony.framework`、`libz.dylib`、`SystemConfiguration.framework` 库是否已经被依赖。如果没有，点击下面的加号后搜索并依赖即可。

### 添加代码

#### 在 App 中请求使用推送功能

打开当前 iOS 工程，在左侧项目导航栏中找到 `iOS`文件夹并进入，选择 `AppController.mm` 文件。

在文件的应用程序初始化完成方法中添加下面的代码：

``` 
// 添加云推送 SDK 头文件
#import "BPush.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
...
app->run();

//-------------------- Push -----------------------------
if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
// 8.0
UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}else {
// ~> 7.1
UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
[[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
}

// 初始化 Push，需要注意区分 pushMode 参数，确定当前的推送环境
[BPush registerChannel:launchOptions apiKey:@"在百度云推送官网上注册得到的 apikey" pushMode:BPushModeDevelopment withFirstAction:nil withSecondAction:nil withCategory:nil isDebug:NO];

return YES;
}
```

上面的方法做了一件事情，就是向系统请求开启消息推送功能，然后系统会弹出 alert 菜单询问用户是否允许此 App 进行消息推送。当用户进行处理后，iOS 8 以及之后的系统会回调下面的方法，你需要将下面的方法添加到 `AppController.mm` 文件中。

``` 
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
// 此处可以根据 notificationSettings 参数判断应用当前所被允许的推送类型
// 应用程序注册推送功能，以获取当前 App 的 deviceToken 
[application registerForRemoteNotifications];
}
```

上面的方法调用后，系统将与 APNs 请求建立长连接，然后将当前 App 在该设备上的 deviceToken 回调给你。deviceToken 在 server 进行推送时，用来指定这条消息将要发送给哪台设备。

下面是获取 deviceToken 的回调方法：

``` 
// 当 deviceToken 获取成功时，系统会调用这条方法
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
NSLog(@"current device token:%@",deviceToken);
// 将 deviceToken 注册到百度云推送之后，就可以通过百度云推送进行消息推送
[BPush registerDeviceToken:deviceToken];
}

// 当 deviceToken 获取失败时，这条方法被调用, 可以查看失败的具体原因
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
NSLog(@"deviceToken 获取失败的原因：%@",error);
}
```



>  有一种特殊情况需要注意，有可能上面的两条方法都不会被调用，这是因为当前设备无法与 APNs 建立长连接，这时候你需要检查设备的网络状态。当 iOS 设备同时具备移动蜂窝网络和 WiFi 网络时，推送功能优先使用移动网络。

#### 将当前设备绑定到百度云推送

在使用百度云推送服务进行推送前，首先需要将设备绑定到其推送服务之后，才可以进行消息推送。

做绑定请求之前，首先得保证已经争取的获取到了 deviceToken 并且注册到百度云推送中。

>  关于绑定和解除绑定，百度云推送的 SDK 中对应存在两条 API，即 bind 和 unbind 操作。bind 操作的实质是与百度的云推送服务发起请求，使得当前设备允许被推送，反之，unbind 的实质为解除当前设备的绑定，之后这台设备将不能被推送消息，除非再次绑定。
>  
>  绑定操作和解绑操作可以在程序运行的任意时期被调用，前提是在初始化百度云推送服务时，使用了正确的 apikey 和 pushMode 参数。
>  
>  常见的场景就是当用户登录后，做绑定请求，用户注销登录后，如果仍继续发送该用户相关的消息就不太合适了，这时做一次解绑操作即可。

现在 iOS 相关的配置就都已经完成，推送的环境也配置成功了。可以切回到 Cocos2d-x 下了。

下面是绑定与解除绑定的示例，如同前面提到的，绑定和解绑操作你可以在任何地方调用。

``` 
// 在 AppDelegate.cpp 文件中，进行绑定操作

// 引入头文件
#include "BPushService.h"

bool AppDelegate::applicationDidFinishLaunching() {
...
director->runWithScene(scene);

// push do bind request
BPushService::bindChannelWithCallback(this, mpush_dispatch_selector(AppDelegate::didBind));
}

// 请求的结果将回调给 AppDelegate 的 didBind 函数，因此还需在该文件中实现
void AppDelegate::didBind(Value token){
// 当 bind 成功后，回调的结果中会返回 channelid，唯一的标识这台设备，拿着 channelid 即可通过百度云推送控制台或服务端 API 进行消息推送
CCLOG("%s", token.getDescription().c_str());
}
```

对解绑方法的调用与绑定相同。

>  对于有返回值的方法调用，都是通过回调函数来获取返回值。

#### 其他相关方法

BPushService 类还提供了其他跟推送相关的方法，可以通过 API 说明进行了解。

### 

## 通过百度云推送控制台给设备进行推送

使用百度云推送进行消息推送时，一种是使用官网提供的控制台，另一种是使用官方提供的 server 端 API。相关的信息都可以在官网的文档中了解到：[百度云推送管理控制台](http://push.baidu.com/doc/console/guide)

## Trouble shooting

这里主要对一些常见问题进行说明，也欢迎各位提  issue。

百度云推送官网上已经有了一些相关的 issue ，[百度云推送 issue](http://push.baidu.com/issue/list/hot)

