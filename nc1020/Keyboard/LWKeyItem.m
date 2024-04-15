//
//  WQXKeyItem.m
//  nc1020
//
//  Created by rainyx on 15/8/22.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "LWKeyItem.h"

@implementation LWKeyItem

- (instancetype)initWithTitle:(NSString *)title andKeyCode:(NSInteger)keyCode andButtonStyle:(LWKeyButtonStyle)style {
    if ([self init]) {
        self.title = title;
        self.keyCode = keyCode;
        self.buttonStyle = style;
        return self;
    } else {
        return Nil;
    }
}

@end
