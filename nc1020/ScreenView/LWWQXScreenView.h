//
//  LWWQXScreenView.h
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWKeyboardView.h"
#import "WQXLCDView.h"

@interface LWWQXScreenView : UIView <LWKeyboardViewDelegate>

@property (weak, nonatomic) id<LWKeyboardViewDelegate> keyboardViewDelegate;

- (instancetype)initWithFrame:(CGRect)bounds andKeyboardViewDelegate:(id<LWKeyboardViewDelegate>)delegate;
- (WQXLCDView *)lcdView;

- (void)initViews;

@end
