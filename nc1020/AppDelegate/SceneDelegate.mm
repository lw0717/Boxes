//
//  SceneDelegate.mm
//  Boxes
//
//  Created by lw0717 on 2026/10/8.
//  Copyright © 2026 lw0717. All rights reserved.
//

#import "SceneDelegate.h"
#import "LWWQXArchiveManagerViewController.h"

@implementation SceneDelegate

#pragma mark - UISceneSession Lifecycle

// 场景初始化（创建窗口）
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // 确保场景是窗口场景（排除其他类型场景）
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        // 创建窗口并绑定到当前场景
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        self.window.frame = windowScene.coordinateSpace.bounds;
        // 设置根视图控制器
        LWWQXArchiveManagerViewController *vc = [[LWWQXArchiveManagerViewController alloc] init];
        UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:vc];
        rootViewController.navigationBar.tintColor = [UIColor blackColor];
        // 设置根视图控制器
        [self.window setBackgroundColor:[UIColor whiteColor]];
        [self.window setRootViewController:rootViewController];
        // 显示窗口
        [self.window makeKeyAndVisible];
    }
}

// 场景即将进入后台（如用户按 Home 键，或窗口被最小化）
- (void)sceneWillEnterForeground:(UIScene *)scene {
    // 前台恢复：刷新 UI 状态、重新加载网络数据
}

// 场景已进入后台（如窗口完全被隐藏）
- (void)sceneDidEnterBackground:(UIScene *)scene {
    // 后台处理：保存持久化数据、释放场景专属内存（如大图缓存）
}

// 场景即将断开会话（如用户关闭窗口，或系统回收资源）
- (void)sceneDidDisconnect:(UIScene *)scene {
    // 清理操作：释放场景专属资源（如注销监听、关闭网络连接）
    // 注意：此时窗口已不可见，无需处理 UI
}

@end
