# JMLink-React-Native

## ChangeLog

### v 1.2.0

极光魔链RN  1.2.4

### v 1.0.0

极光魔链RN第一版

## 1. 安装

```
npm install jmlink-react-native --save
```

* 注意：如果项目里没有jcore-react-native，需要安装

  ```
  npm install jcore-react-native --save
  ```

## 2. 配置

### 2.1 Android

* build.gradle

  ```
  android {
        defaultConfig {
            applicationId "yourApplicationId"           //在此替换你的应用包名
            ...
            manifestPlaceholders = [
                    JPUSH_APPKEY: "yourAppKey",         //在此替换你的APPKey
                    JPUSH_CHANNEL: "yourChannel",       //在此替换你的channel
                    JMLINK_SCHEME: "yourScheme"  // 在此替换你的scheme
            ]
        }
    }
  ```

  ```
  dependencies {
        ...
        implementation project(':jmlink-react-native') // 添加 jverification 依赖
        implementation project(':jcore-react-native')         // 添加 jcore 依赖
    }
  ```

* setting.gradle

  ```
  include ':jmlink-react-native'
  project(':jmlink-react-native').projectDir = new File(rootProject.projectDir, '../node_modules/jmlink-react-native/android')
  include ':jcore-react-native'
  project(':jcore-react-native').projectDir = new File(rootProject.projectDir, '../node_modules/jcore-react-native/android')
  ```

### 2.2 iOS

### 2.2.1 pod

```
pod install
```

* 注意：如果项目里使用pod安装过，请先执行命令

  ```
  pod deintegrate
  ```

### 2.2.2 手动方式

* Libraries

  ```
  Add Files to "your project name"
  node_modules/jcore-react-native/ios/RCTJCoreModule.xcodeproj
  node_modules/jmlink-react-native/ios/RCTJMLinkModule.xcodeproj
  ```

* Build Settings

  ```
  All --- Search Paths --- Header Search Paths --- +
  $(SRCROOT)/../node_modules/jcore-react-native/ios/RCTJCoreModule/
  $(SRCROOT)/../node_modules/jmlink-react-native/ios/RCTJMLinkModule/
  ```

* Build Phases

  ```
  libz.tbd
  libc++.1.tbd
  libresolv.tbd
  libsqlite3.tbd
  libRCTJCoreModule.a
  libRCTJMLinkModule.a
  ```

* info.plist

  ```
  View controller-based status bar appearance : YES
  ```
### 2.2.3 配置

+ 配置App的URL Scheme

> iOS系统中App之间是相互隔离的，通过URL Scheme，App之间可以相互调用，并且可以传递参数。
> 选中`Target->Info->URL Types`，配置URL Scheme（比如：jmlink）
>
> 在Safari中输入`URL Scheme://`（比如：`jmlink://`）如果可以唤起App，说明该URL Scheme配置成功。

+ 配置Universal link

> Universal link是iOS9的一个新特性，通过Universal link，App可以无需打开Safari，直接从微信等应用中跳转到App，真正的实现一键直达。如果使用URL Scheme的话，需要先打开Safari，用户体验变得很差，如果App未安装，还会出现以下错误对话框

Xcode 里的具体配置请查看 [mLink的设置](https://docs.jiguang.cn/jmlink/client/iOS/ios_guide/)

+ 初始化代码

	在 iOS 项目的 AppDelegate.m 文件内的 [application: didFinishLaunchingWithOptions:] 方法里必须调用如下代码完成初始化

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {  
  	[RCTJMLinkModule setupAppKey:@"极光官网分配的appKey"
                       channel:@"channel"
                 advertisingId:nil
                  isProduction:NO
                       isDebug:YES]; 
  }
```

## 3. 引用

参考：[App.js](https://github.com/jpush/jmlink-react-native/tree/master/example/App.js)

## 4. API

详见：[index.js](https://github.com/jpush/jmlink-react-native/tree/master/plugin/index.js)

## 5.  其他

* 集成前务必将example工程跑通
* 上报问题还麻烦先将init参数中params的debug字段设置成true，拿到debug日志  

 

