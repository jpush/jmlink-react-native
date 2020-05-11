//
//  RCTJMLinkModule.m
//  RCTJMLinkModule
//
//  Created by mac on 2020/5/26.
//  Copyright © 2020 mac. All rights reserved.
//

#import "RCTJMLinkModule.h"

#define JMLog(fmt,...) NSLog((@"| JMLink ｜ iOS | - " fmt),##__VA_ARGS__)

//事件
#define JMLINK_EVENT    @"ParamEvent"

@interface RCTJMLinkModule ()

@property(assign, nonatomic) BOOL isSetup;
@property(assign, nonatomic) NSURL * _Nullable openUrl;
@property(strong, nonatomic) NSUserActivity * _Nullable userActivity;


@property(assign, nonatomic) BOOL isRegisterEvent;
@property(strong, nonatomic) NSDictionary * _Nullable eventParam;
@end

@implementation RCTJMLinkModule
RCT_EXPORT_MODULE(JMLinkModule);


+ (instancetype)sharedInstance {
    static RCTJMLinkModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.isSetup = NO;
        self.openUrl = nil;
        self.userActivity = nil;
        self.isRegisterEvent = NO;
        self.eventParam = nil;
    }
    return self;
}

//事件处理
- (NSArray<NSString *> *)supportedEvents
{
    return @[JMLINK_EVENT];
}


+ (void)setupAppKey:(NSString *)appKey channel:(NSString *)channel advertisingId:(NSString *)advertisingId isProduction:(BOOL)isProduction isDebug:(BOOL)isDebug {
    JMLog(@"setupAppKey:%@",appKey);
    JMLinkConfig *config = [[JMLinkConfig alloc] init];
    config.appKey = appKey;
    if (channel) {
        config.channel = channel;
    }
    if (advertisingId) {
        config.advertisingId = advertisingId;
    }
    config.isProduction = isProduction?:NO;
    
    [[RCTJMLinkModule sharedInstance] setupsdk:config isDebug:isDebug];
}

RCT_EXPORT_METHOD(ioslog:(NSString *)str){
    JMLog(@"ioslog: %@",str);
}
// 初始化方法
RCT_EXPORT_METHOD(setupWithConfig:(NSDictionary *)params)
{
    JMLog(@"setupWithConfig: %@",params);
    JMLinkConfig *config = [[JMLinkConfig alloc] init];
    if (params[@"appKey"]) {
        config.appKey = params[@"appKey"];
    }
    if (params[@"channel"]) {
        config.channel = params[@"channel"];
    }
    if (params[@"advertisingId"]) {
        config.advertisingId = params[@"advertisingId"];
    }
    if (params[@"isProduction"]) {
        config.isProduction = [params[@"isProduction"] boolValue];
    }
    BOOL isDebug = NO;
    if (params[@"debug"]) {
        isDebug = [params[@"debug"] boolValue];
    }
    BOOL clipEnabled = YES;
    if (params[@"clipEnabled"]) {
        clipEnabled = [params[@"clipEnabled"] boolValue];
    }
    [JMLinkService pasteBoardEnable:clipEnabled];
    [self setupsdk:config isDebug:isDebug];
}

- (void)setupsdk:(JMLinkConfig *)config isDebug:(BOOL)isDebug {
    
    [JMLinkService setDebug:isDebug?:NO];
    
    [JMLinkService setupWithConfig:config];
    
    [RCTJMLinkModule sharedInstance].isSetup = YES;
    [self registerHandler];
    
    [self timer];
}

// RN 层注册监听
RCT_EXPORT_METHOD(registerEvent){
    JMLog(@"registerEvent");
    [RCTJMLinkModule sharedInstance].isRegisterEvent = YES;
    if ([RCTJMLinkModule sharedInstance].eventParam) {
        [self sendEvent:[RCTJMLinkModule sharedInstance].eventParam];
    }
}

- (void)registerHandler {
    JMLog(@"registerHandler");
    [JMLinkService registerMLinkDefaultHandler:^(NSURL * _Nonnull url, NSDictionary * _Nullable params) {
        NSLog(@"default handler, url = %@, param= %@",url.absoluteString,params);
        dispatch_async(dispatch_get_main_queue(), ^{
            [JMLinkService getMLinkParam:nil handler:^(NSDictionary * _Nullable dynpParams) {
                NSLog(@"get mlink param, param=%@",dynpParams);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self sendEvent:params dynpParams:dynpParams];
                });
            }];
        });
    }];
}


// {"params":{"key":"value",},"dynpParams":{"key","value"}}
- (void)sendEvent:(NSDictionary *)param dynpParams:(NSDictionary *)dynpParams {
    JMLog(@"sendEvent:dynpParams:");
    NSDictionary *dic = @{@"params":param?:@{},@"dynpParams":dynpParams?:@{}};
    if ([RCTJMLinkModule sharedInstance].isRegisterEvent) {
        [self sendEvent:dic];
    }else{
        [RCTJMLinkModule sharedInstance].eventParam = dic;
    }
}
- (void)sendEvent:(NSDictionary *)eventParam {
    JMLog(@"sendEvent: %@",eventParam);
    if (eventParam) {
        [self.bridge enqueueJSCall:@"RCTDeviceEventEmitter" method:@"emit" args:@[JMLINK_EVENT, eventParam] completion:NULL];
        [RCTJMLinkModule sharedInstance].eventParam = nil;
    }
}

- (void)timer {
    if([RCTJMLinkModule sharedInstance].isSetup) {
        if ([RCTJMLinkModule sharedInstance].openUrl) {
            [JMLinkService routeMLink:[RCTJMLinkModule sharedInstance].openUrl];
            [RCTJMLinkModule sharedInstance].openUrl = nil;
        }
        if ([RCTJMLinkModule sharedInstance].userActivity) {
            [JMLinkService continueUserActivity:[RCTJMLinkModule sharedInstance].userActivity];
            [RCTJMLinkModule sharedInstance].userActivity = nil;
        }
    }
}

+ (BOOL)openURL:(NSURL *_Nullable)url {
    JMLog(@"openURL: %@",url);
    if (url) {
        if ([RCTJMLinkModule sharedInstance].isSetup) {
            [JMLinkService routeMLink:url];
        }else{
            [RCTJMLinkModule sharedInstance].openUrl = url;
        }
    }
    return YES;
}

+ (BOOL)continueUserActivity:(NSUserActivity *)userActivity {
    JMLog(@"continueUserActivity:%@",userActivity.webpageURL);
    if (userActivity) {
        if ([RCTJMLinkModule sharedInstance].isSetup) {
            [JMLinkService continueUserActivity:userActivity];
        }else{
            [RCTJMLinkModule sharedInstance].userActivity = userActivity;
        }
    }
    return YES;
}
@end
