//
//  LWWQXGMUDScreenView.m
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "LWWQXGMUDScreenView.h"
#import "WQXArchiveManager.h"
#import "LWGMUDKeyboardView.h"
#import "LWAutolayout.h"

#define isDirectionKeyCode(code) ((code==0x1A||code==0x1B||code==0x3F||code==0x1F))

@interface LWWQXGMUDScreenView ()

@property (nonatomic, strong) WQXLCDView *lcdView;
@property (nonatomic, strong) LWGMUDKeyboardView *keyboardView;

@end

@implementation LWWQXGMUDScreenView

- (void)initViews {

    self.backgroundColor = [UIColor lcdBackgroundColor];

    _lcdView = [[WQXLCDView alloc] initWithFrame:CGRectZero];

    _keyboardView = [[LWGMUDKeyboardView alloc] initWithFrame:CGRectZero];
    _keyboardView.delegate = self;
    
    [self addSubview:_lcdView];
    [self addSubview:_keyboardView];

    [self.lcdView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    [self.keyboardView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.top.left.right.bottom.equalTo(self);
    }];
}

// Makes speed up for direction buttons.
- (void)keyboardView:(LWKeyboardView *)view didKeydown:(NSInteger)keyCode {
    if (self.keyboardViewDelegate != Nil && [self.keyboardViewDelegate respondsToSelector:@selector(keyboardView:didKeydown:)]) {
        if (isDirectionKeyCode(keyCode)) {
            [self.keyboardViewDelegate keyboardView:view didKeydown:0x30];
        }
        [self.keyboardViewDelegate keyboardView:view didKeydown:keyCode];
    }
}

// Resets speed for direction buttons.
- (void)keyboardView:(LWKeyboardView *)view didKeyup:(NSInteger)keyCode {
    if (self.keyboardViewDelegate != Nil && [self.keyboardViewDelegate respondsToSelector:@selector(keyboardView:didKeyup:)]) {
        if (isDirectionKeyCode(keyCode)) {
            [self.keyboardViewDelegate keyboardView:view didKeyup:0x30];
        }
        [self.keyboardViewDelegate keyboardView:view didKeyup:keyCode];
    }
}

@end
