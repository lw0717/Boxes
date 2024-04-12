//
//  MBProgressHUD+LW.h
//
//  Created by lw0717 on 2017/3/17.
//  Copyright © 2017年 lw0717. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (LW)

+ (void)lw_showMessageThenHide:(NSString *)msg 
                        toView:(UIView *)view;

+ (void)lw_showMessageThenHide:(NSString *)msg 
                        toView:(UIView *)view
                        onHide:(void (^)(void))onHide;

+ (void)lw_showMessageThenHide:(NSString *)msg
                        toView:(UIView *)view
                       yOffset:(CGFloat)offset
                        onHide:(void (^)(void))onHide;

/**
 *  显示加载中，以及文本消息
 *
 *  @param msg  消息内容，如果为nil，则只显示loading图
 *  @param view 所在的superview
 *
 *  @return 返回当前hud，方便之后hide
 */
+ (MBProgressHUD*)lw_showLoading:(NSString *)msg 
                          toView:(UIView *)view;

+ (MBProgressHUD*)lw_showLoading:(NSString *)msg 
                          toView:(UIView *)view
          userInteractionEnabled:(BOOL)userInteractionEnabled;

+ (void)lw_closeLoadingView:(UIView *)toView;

@end
