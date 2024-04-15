//
//  WQXScreenLayout.m
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "WQXScreenLayout.h"
#import "LWToolbox.h"

@implementation WQXScreenLayout

- (id)initWithBounds:(CGRect)bounds andKeyboardViewDelegate:(id<LWKeyboardViewDelegate>)delegate {
    if ([super init]) {
        self.bounds = bounds;
        self.keyboardViewDelegate = delegate;
        NSLog(@"lw0717: Layout Bounds: %f, %f, %f, %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
        [self initViews];
        return self;
    } else {
        return Nil;
    }
}

- (void)keyboardView:(LWKeyboardView *)view didKeydown:(NSInteger)keyCode {
    if (self.keyboardViewDelegate != Nil && [self.keyboardViewDelegate respondsToSelector:@selector(keyboardView:didKeydown:)]) {
        [self.keyboardViewDelegate keyboardView:view didKeydown:keyCode];
    }
}
- (void)keyboardView:(LWKeyboardView *)view didKeyup:(NSInteger)keyCode {
    if (self.keyboardViewDelegate != Nil && [self.keyboardViewDelegate respondsToSelector:@selector(keyboardView:didKeyup:)]) {
        [self.keyboardViewDelegate keyboardView:view didKeyup:keyCode];
    }
}

- (WQXLCDView *)lcdView {
    mustOverride();
}

- (void) initViews {
    mustOverride();
}

- (void) attachToView:(UIView *)view {
    mustOverride();
}

- (void) detachFromView:(UIView *)view {
    mustOverride();
}

@end
