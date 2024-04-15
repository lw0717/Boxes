//
//  WQXKeyItem.h
//  nc1020
//
//  Created by rainyx on 15/8/22.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIButton+LW.h"

typedef NS_ENUM(NSInteger, WQXCustomKeyCode) {
    kWQXCustomKeyCodeBegin = 0x1000,
    kWQXCustomKeyCodeSave,
    kWQXCustomKeyCodeLoad,
    kWQXCustomKeyCodeSeppdup,
    kWQXCustomKeyCodeSpeedReset,
    kWQXCustomKeyCodeSwitch
};

@interface LWKeyItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger keyCode;
@property (nonatomic, assign) LWKeyButtonStyle buttonStyle;

- (instancetype)initWithTitle:(NSString *)title andKeyCode:(NSInteger)keyCode andButtonStyle:(LWKeyButtonStyle)style;

@end
