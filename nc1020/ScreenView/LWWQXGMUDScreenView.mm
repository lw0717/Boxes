//
//  LWWQXGMUDScreenView.m
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "LWWQXGMUDScreenView.h"
#import "LWWQXArchiveManager.h"
#import "LWGMUDKeyboardView.h"
#import "LWAutolayout.h"

#define isDirectionKeyCode(code) ((code==0x1A||code==0x1B||code==0x3F||code==0x1F))

@interface LWWQXGMUDScreenView ()

@property (nonatomic, assign) LWScreenStyle style;

@property (nonatomic, strong) LWWQXLCDView *lcdView;
@property (nonatomic, strong) LWGMUDKeyboardView *keyboardView;

@end

@implementation LWWQXGMUDScreenView

- (void)setupViewWithStyle:(LWScreenStyle)style {

    self.backgroundColor = [UIColor lcdBackgroundColor];

    self.lcdView = [[LWWQXLCDView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.lcdView];

    self.keyboardView = [[LWGMUDKeyboardView alloc] initWithFrame:CGRectZero];
    self.keyboardView.delegate = self;
    [self addSubview:self.keyboardView];

    [self.lcdView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    [self.keyboardView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.top.left.right.bottom.equalTo(self);
    }];
}

- (void)setStyle:(LWScreenStyle)style {
    _style = style;
    if (style == LWScreenStylePortrait) {
        [self.lcdView lw_removeAllConstraints];
        [self.lcdView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
            make.left.right.equalTo(self);
            make.centerY.equalTo(self);
            make.height.equalTo(self.lcdView.lw_width).multipliedBy(0.5);
        }];
    } else {
        [self.lcdView lw_removeAllConstraints];
        [self.lcdView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
            make.top.left.right.bottom.equalTo(self);
        }];
    }
}

// Makes speed up for direction buttons.
- (void)keyboardView:(LWKeyboardView *)view didKeydown:(NSInteger)keyCode {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(keyboardView:didKeydown:)]) {
        if (isDirectionKeyCode(keyCode)) {
            [self.delegate keyboardView:view didKeydown:0x30];
        }
        [self.delegate keyboardView:view didKeydown:keyCode];
    }
}

// Resets speed for direction buttons.
- (void)keyboardView:(LWKeyboardView *)view didKeyup:(NSInteger)keyCode {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(keyboardView:didKeyup:)]) {
        if (isDirectionKeyCode(keyCode)) {
            [self.delegate keyboardView:view didKeyup:0x30];
        }
        [self.delegate keyboardView:view didKeyup:keyCode];
    }
}

@end
