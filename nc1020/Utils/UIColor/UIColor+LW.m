//
//  UIColor+LW.m
//  NC1020
//
//  Created by lw0717 on 2024/4/13.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "UIColor+LW.h"

@implementation UIColor (LW)

+ (UIColor *)lcdBackgroundColor {
    return [UIColor colorWithRGB:0xC1C1C1];
}

+ (UIColor *)colorWithRGB:(NSUInteger)rgb {
    return [UIColor colorWithR:(rgb >> 16) & 0xFF
                             g:(rgb >> 8) & 0xFF
                             b:rgb & 0xFF
                             a:0xFF];
}

+ (UIColor *)colorWithARGB:(NSUInteger)argb {
    return [UIColor colorWithR:(argb >> 16) & 0xFF
                             g:(argb >> 8) & 0xFF
                             b:argb & 0xFF
                             a:(argb >>24 ) & 0xFF];
}

+ (UIColor *)colorWithRGBA:(NSUInteger)rgba {
    return [UIColor colorWithR:rgba >> 24
                             g:(rgba >> 16) & 0xFF
                             b:(rgba >> 8) & 0xFF
                             a:rgba & 0xFF];
}

+ (UIColor *)colorWithR:(NSInteger)r g:(NSInteger)g b:(NSInteger)b a:(NSInteger)a {
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:a / 255.0f];
}

@end
