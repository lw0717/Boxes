//
//  LWWQXScreenView.m
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "LWWQXScreenView.h"

#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]
#define methodNotImplemented() mustOverride()

@implementation LWWQXScreenView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<LWKeyboardViewDelegate>)delegate {
    return [self initWithFrame:frame style:LWScreenStyleLandscape delegate:delegate];
}

- (instancetype)initWithFrame:(CGRect)frame style:(LWScreenStyle)style delegate:(id<LWKeyboardViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        [self setupViewWithStyle:style];
        self.style = style;
    }
    return self;
}

- (void)keyboardView:(LWKeyboardView *)view didKeydown:(NSInteger)keyCode {
    if (self.delegate != Nil && [self.delegate respondsToSelector:@selector(keyboardView:didKeydown:)]) {
        [self.delegate keyboardView:view didKeydown:keyCode];
    }
}
- (void)keyboardView:(LWKeyboardView *)view didKeyup:(NSInteger)keyCode {
    if (self.delegate != Nil && [self.delegate respondsToSelector:@selector(keyboardView:didKeyup:)]) {
        [self.delegate keyboardView:view didKeyup:keyCode];
    }
}

- (LWWQXLCDView *)lcdView {
    mustOverride();
}

- (void)setupViewWithStyle:(LWScreenStyle)style {
    mustOverride();
}

- (void)setStyle:(LWScreenStyle)style {
    mustOverride();
}

@end

