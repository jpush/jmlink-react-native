//
//  RCTJMLinkModule.h
//  RCTJMLinkModule
//
//  Created by mac on 2020/5/26.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTEventEmitter.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTEventEmitter.h"
#import "RCTRootView.h"
#import "RCTBridge.h"
#endif

#import "JMLinkService.h"

#import <React/RCTRootView.h>
#import <React/RCTBundleURLProvider.h>



@interface RCTJMLinkModule :  RCTEventEmitter<RCTBridgeModule>


/// 初始化SDK 插件
/// @param appKey 极光平台应用的appkey
/// @param channel 发布渠道，可为空
/// @param advertisingId 广告标识，可选
/// @param isProduction 是否生产环境，如果开发环境设置为NO
/// @param isDebug 设置是否打印 sdk 的 debug 级日志
+ (void)setupAppKey:(NSString *_Nonnull)appKey
            channel:(NSString *_Nullable)channel
      advertisingId:(NSString *_Nullable)advertisingId
       isProduction:(BOOL)isProduction
            isDebug:(BOOL)isDebug;

/// universal link 路由，在 iOS 系统方法 [application: continueUserActivity: restorationHandler:] 中执行
+ (BOOL)continueUserActivity:(NSUserActivity *_Nullable)userActivity ;

/// scheme  路由，在 iOS 系统方法 [application: handleOpenURL:] 和 [application: openURL: options:] 中执行
+ (BOOL)openURL:(NSURL *_Nullable)openUrl;


@end
