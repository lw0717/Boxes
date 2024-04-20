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
#define isDirectionKeyCode(code) ((code==0x1A||code==0x1B||code==0x3F||code==0x1F))

@interface LWWQXGMUDScreenView ()

@property (nonatomic, strong) WQXLCDView *lcdView;
@property (nonatomic, strong) LWGMUDKeyboardView *keyboardView;

@end

@implementation LWWQXGMUDScreenView

- (void)initViews {

    self.backgroundColor = [UIColor lcdBackgroundColor];

    CGFloat lcdWidth = self.bounds.size.width;
    CGFloat lcdHeight = lcdWidth/2;
    CGFloat lcdX = self.bounds.size.width / 2 - lcdWidth / 2;
    CGFloat lcdY = self.bounds.size.height / 2 - lcdHeight / 2;

    _lcdView = [[WQXLCDView alloc] initWithFrame:CGRectMake(lcdX, lcdY, lcdWidth, lcdHeight)];
    
    CGFloat keyboardViewWidth = self.bounds.size.width;
    CGFloat keyboardViewHeight = self.bounds.size.height / 2;
    CGFloat keyboardViewX = 0.0f;
    CGFloat keyboardViewY = self.bounds.size.height - keyboardViewHeight;

    _keyboardView = [[LWGMUDKeyboardView alloc] initWithFrame:CGRectMake(keyboardViewX, keyboardViewY, keyboardViewWidth, keyboardViewHeight)];
    _keyboardView.delegate = self;
    
    [self addSubview:_lcdView];
    [self addSubview:_keyboardView];
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
