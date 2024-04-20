//
//  UIButton+LW.m
//  NC1020
//
//  Created by lw0717 on 2024/4/15.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "UIButton+LW.h"
#import "UIColor+LW.h"
#import "UIImage+LW.h"

@implementation UIButton (LW)

- (void)setupStyle:(LWKeyButtonStyle)style {
    UIImage *bgImgNormal = [UIImage imageWithColor:[UIColor colorWithRGBA:0x404040FF]];
    UIImage *bgImgHighlighted = [UIImage imageWithColor:[UIColor colorWithRGBA:0xFFA800FF]];
    UIColor *labelColorNormal = [UIColor colorWithRGBA:0xC5C5C5FF];
    UIColor *labelColorHighlighted = [UIColor blackColor];
    UIFont *labelFont = [UIFont systemFontOfSize:12.0f];

    switch (style) {
        case kWQXKeyButtonNormal:
            break;
        case kWQXKeyButtonFunction:
        case kWQXKeyButtonPrimary:
            bgImgNormal = [UIImage imageWithColor:[UIColor colorWithRGBA:0x5D5D5DFF]];
            labelFont = [UIFont fontWithName:@"Arial-BoldMT" size:12.0f];
            break;
        case kWQXKeyButtonNumber:
            bgImgNormal = [UIImage imageWithColor:[UIColor colorWithRGBA:0x737E92FF]];
            break;
        case kWQXKeyButtonSystem:
            bgImgNormal = [UIImage imageWithColor:[UIColor colorWithRGBA:0x574B3AFF]];
            break;
        default:
            break;
    }

    [self setBackgroundImage:bgImgNormal forState:UIControlStateNormal];
    [self setBackgroundImage:bgImgHighlighted forState:UIControlStateHighlighted];

    [self setTitleColor:labelColorNormal forState:UIControlStateNormal];
    [self setTitleColor:labelColorHighlighted forState:UIControlStateHighlighted];

    self.titleLabel.font = labelFont;
}

- (void)setupOrigin:(CGPoint)origin andRadius:(CGFloat)radius {

    CGRect rect = CGRectMake(origin.x, origin.y, radius * 2, radius * 2);
    self.frame = rect;

    self.layer.cornerRadius = radius;
    self.alpha = 0.3f;

    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

@end
