//
//  WQXToolBox.m
//  nc1020
//
//  Created by rainyx on 15/8/22.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "LWToolbox.h"
#import <CommonCrypto/CommonDigest.h>

@implementation LWToolbox

+ (CGRect)rectForCurrentOrientation:(CGRect)rect {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    BOOL needFlip = NO;
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            needFlip = rect.size.width > rect.size.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            needFlip = rect.size.height > rect.size.width;
            break;
        default:
            break;
    }
    
    CGRect ret = CGRectMake(rect.origin.x, rect.origin.y,
                            needFlip?rect.size.height:rect.size.width,
                            needFlip?rect.size.width:rect.size.height);
    
    return ret;
}

@end
