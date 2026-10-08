//
//  AppDelegate.m
//  nc1020
//
//  Created by eric on 15/8/20.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

// 应用启动完成（仅处理全局初始化，不涉及UI）
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 全局配置：注册推送、初始化第三方SDK等（不创建window）
    return YES;
}

// 系统请求创建新场景时调用（如用户开启多窗口）
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSession options:(UISceneConnectionOptions *)options {
    // 返回 Info.plist 中配置的场景配置（匹配名称）
    return [UISceneConfiguration configurationWithName:@"Boxes Configuration" sessionRole:connectingSession.role];
}

// 场景会话断开时调用（如用户关闭窗口）
- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // 清理场景相关资源（如释放场景专属数据）
}

@end
