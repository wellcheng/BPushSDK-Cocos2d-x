//
//  BPushService.cpp
//  HelloWorldDemo
//
//  Created by WellCheng on 15/10/10.
//
//

/**
 *  为 Cocos2d-x 提供 push 服务，将 Push 的部分 API 封装为 C++ 可以调用的接口
 *  
 *  对于系统回调到 OC 的内容转发给 C++ 类
 */

#include "ccConfig.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#include "BPushService.h"
#import "BPush.h"
#import "BPushJsonHelp.h"
#import "BPushErrorHandle.h"

USING_NS_CC;

BPushService::BPushService(){}
BPushService::~BPushService(){}

void BPushService::bindChannelWithCallback(cocos2d::Application *target, DispatchCallFunc selector){
    [BPush bindChannelWithCompleteHandler:^(id result, NSError *error){
        // 将绑定结果转换为 JSON 字符串，然后返回
        cocos2d::Value jsonValue = BPushJsonHelper::parseJson2Value([[BPushErrorHandle errorHandleWithResult:result
                                                                                                       error:error]
                                                                     UTF8String]);
        (target->*selector)(jsonValue);
    }];
}

void unbindChannelWithCallback(cocos2d::Application *target, DispatchCallFunc selector) {
    [BPush unbindChannelWithCompleteHandler:^(id result, NSError *error){
        cocos2d::Value jsonValue = BPushJsonHelper::parseJson2Value([[BPushErrorHandle errorHandleWithResult:result
                                                                                                       error:error]
                                                                     UTF8String]);
        (target->*selector)(jsonValue);
    }];
}

void setTagsJSONWithCallback(cocos2d::Application *target, DispatchCallFunc selector, const std::string &jsonString) {
    NSString *tagsString = [NSString stringWithCString:jsonString.c_str() encoding:NSUTF8StringEncoding];
    [BPush setTags:[tagsString JSONValue] withCompleteHandler:^(id result, NSError *error){
        cocos2d::Value jsonValue = BPushJsonHelper::parseJson2Value([[BPushErrorHandle errorHandleWithResult:result
                                                                                                       error:error]
                                                                     UTF8String]);
        (target->*selector)(jsonValue);
    }];
}

void delTagsJSONWithCallback(cocos2d::Application *target, DispatchCallFunc selector, const std::string &jsonString) {
    NSString *tagsString = [NSString stringWithCString:jsonString.c_str() encoding:NSUTF8StringEncoding];
    [BPush delTags:[tagsString JSONValue] withCompleteHandler:^(id result, NSError *error){
        cocos2d::Value jsonValue = BPushJsonHelper::parseJson2Value([[BPushErrorHandle errorHandleWithResult:result
                                                                                                       error:error]
                                                                     UTF8String]);
        (target->*selector)(jsonValue);
    }];
}

void listTagsJSONWithCallback(cocos2d::Application *target, DispatchCallFunc selector) {
    [BPush listTagsWithCompleteHandler:^(id result, NSError *error){
        cocos2d::Value jsonValue = BPushJsonHelper::parseJson2Value([[BPushErrorHandle errorHandleWithResult:result
                                                                                                       error:error]
                                                                     UTF8String]);
        (target->*selector)(jsonValue);
    }];
}

void getChannelidWithCallback(cocos2d::Application *target, DispatchCallFunc selector) {
    cocos2d::Value jsonValue = BPushJsonHelper::parseJson2Value([[BPushErrorHandle errorHandleWithString:[BPush getChannelId]]
                                                                 UTF8String]);
    (target->*selector)(jsonValue);
}

void getAppidWithCallback(cocos2d::Application *target, DispatchCallFunc selector) {
    cocos2d::Value jsonValue = BPushJsonHelper::parseJson2Value([[BPushErrorHandle errorHandleWithString:[BPush getAppId]]
                                                                 UTF8String]);
    (target->*selector)(jsonValue);
}



#endif

