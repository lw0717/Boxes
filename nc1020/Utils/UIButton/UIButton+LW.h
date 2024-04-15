//
//  UIButton+LW.h
//  NC1020
//
//  Created by lw0717 on 2024/4/15.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LWKeyButtonStyle) {
    kWQXKeyButtonNormal,
    kWQXKeyButtonNumber,
    kWQXKeyButtonPrimary,
    kWQXKeyButtonSystem,
    kWQXKeyButtonFunction
};

@interface UIButton (LW)

- (void)setupStyle:(LWKeyButtonStyle)style;

- (void)setupOrigin:(CGPoint)origin andRadius:(CGFloat)radius;

@end

NS_ASSUME_NONNULL_END
