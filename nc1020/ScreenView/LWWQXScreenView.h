//
//  LWWQXScreenView.h
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWKeyboardView.h"
#import "LWWQXLCDView.h"

typedef NS_ENUM(NSUInteger, LWScreenStyle) {
    // 竖屏模式
    LWScreenStylePortrait,
    // 横屏模式
    LWScreenStyleLandscape,
};

@interface LWWQXScreenView : UIView <LWKeyboardViewDelegate>

@property (weak, nonatomic) id<LWKeyboardViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<LWKeyboardViewDelegate>)delegate;
- (instancetype)initWithFrame:(CGRect)frame style:(LWScreenStyle)style delegate:(id<LWKeyboardViewDelegate>)delegate;

- (LWWQXLCDView *)lcdView;

- (void)setupViewWithStyle:(LWScreenStyle)style;

- (void)setStyle:(LWScreenStyle)style;

@end
