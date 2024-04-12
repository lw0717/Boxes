//
//  MBProgressHUD+lw.m
//
//  Created by lw0717 on 2017/3/17.
//  Copyright © 2017年 Baijia Cloud. All rights reserved.
//

#import "MBProgressHUD+lw.h"

@implementation MBProgressHUD (lw)

+ (void)lw_showMessageThenHide:(NSString *)msg 
                        toView:(UIView *)view {
    [self lw_showMessageThenHide:msg toView:view onHide:nil];
}

+ (void)lw_showMessageThenHide:(NSString *)msg 
                        toView:(UIView *)view
                        onHide:(void (^)(void))onHide {
    [self lw_showMessageThenHide:msg toView:view yOffset:0 onHide:onHide];
}

+ (void)lw_showMessageThenHide:(NSString *)msg
                        toView:(UIView *)view  
                       yOffset:(CGFloat)offset
                        onHide:(void (^)(void))onHide {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (view == nil) {
        NSAssert(0, @" no view");
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud){
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    if (hud == nil) {
        NSAssert(0, @"hud is nil");
    }
    hud.detailsLabel.font = [UIFont systemFontOfSize:16];
    hud.detailsLabel.text = msg;

    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    [hud setUserInteractionEnabled:false];

    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.backgroundView.color = [UIColor clearColor];
    hud.offset = CGPointMake(hud.offset.x, offset);
    // 2秒之后再消失
    int hideInterval = 2;
    [hud hideAnimated:YES afterDelay:hideInterval];

    if (onHide){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(hideInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            onHide();
        });
    }
}

+ (MBProgressHUD*)lw_showLoading:(NSString*)msg 
                          toView:(UIView *)view
          userInteractionEnabled:(BOOL)userInteractionEnabled
                         yOffset:(CGFloat)offset{
    if (view == nil)
        return nil;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }

    if (hud == nil) {
        return hud;
    }

    hud.offset = CGPointMake(hud.offset.x, offset);
    hud.detailsLabel.text = msg;
    hud.detailsLabel.font = [UIFont systemFontOfSize:16];

    // 再设置模式
    hud.mode = MBProgressHUDModeIndeterminate;
    [hud setUserInteractionEnabled:userInteractionEnabled];

    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;

    return hud;
}

+ (MBProgressHUD*)lw_showLoading:(NSString *)msg 
                          toView:(UIView *)view
          userInteractionEnabled:(BOOL)userInteractionEnabled {
    return [MBProgressHUD lw_showLoading:msg toView:view userInteractionEnabled:userInteractionEnabled yOffset:0];
}

+ (MBProgressHUD*)lw_showLoading:(NSString*)msg 
                          toView:(UIView *)view {
    return [MBProgressHUD lw_showLoading:msg toView:view userInteractionEnabled:false];
}


+ (void)lw_closeLoadingView:(UIView *)toView {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:toView];
    if (hud) {
        [hud hideAnimated:YES];
    }
}

@end
