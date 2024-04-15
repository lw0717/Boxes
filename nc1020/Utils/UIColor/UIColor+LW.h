//
//  UIColor+LW.h
//  NC1020
//
//  Created by lw0717 on 2024/4/13.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (LW)

+ (UIColor *)lcdBackgroundColor;

+ (UIColor *)colorWithRGB:(NSUInteger)rgb;

+ (UIColor *)colorWithARGB:(NSUInteger)argb;

+ (UIColor *)colorWithRGBA:(NSUInteger)rgba;

@end

NS_ASSUME_NONNULL_END
