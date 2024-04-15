//
//  LWKeyboardView.h
//  nc1020
//
//  Created by rainyx on 15/8/22.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWKeyboardView;

@protocol LWKeyboardViewDelegate <NSObject>

@required
- (void)keyboardView:(LWKeyboardView *)view didKeydown:(NSInteger)keyCode;
- (void)keyboardView:(LWKeyboardView *)view didKeyup:(NSInteger)keyCode;

@end

@interface LWKeyboardView : UIView

@property(nonatomic, weak) id<LWKeyboardViewDelegate> delegate;

- (void)didButtonTouchDown:(UIButton *)sender;
- (void)didButtonTouchUp:(UIButton *)sender;

@end
