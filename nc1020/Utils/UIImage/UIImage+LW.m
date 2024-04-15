//
//  UIImage+LW.m
//  NC1020
//
//  Created by lw0717 on 2024/4/13.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "UIImage+LW.h"

@implementation UIImage (LW)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
