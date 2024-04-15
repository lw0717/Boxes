//
//  WQXScreenLayout.h
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LWKeyboardView.h"
#import "WQXLCDView.h"

@interface WQXScreenLayout : NSObject<LWKeyboardViewDelegate>

@property(weak, nonatomic) id<LWKeyboardViewDelegate> keyboardViewDelegate;
@property(nonatomic) CGRect bounds;

- (id)initWithBounds:(CGRect)bounds andKeyboardViewDelegate:(id<LWKeyboardViewDelegate>)delegate;
- (WQXLCDView *)lcdView;
- (void) attachToView:(UIView *)view;
- (void) detachFromView:(UIView *)view;

- (void)initViews;

@end
