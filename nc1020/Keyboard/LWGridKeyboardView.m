//
//  WQXGridKeyboardView.m
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "LWGridKeyboardView.h"
#import "LWKeyItem.h"
#import "UIButton+LW.h"
#import "LWAutolayout.h"

@interface LWGridKeyboardView ()

@property (nonatomic, strong) UIStackView *vStackView;

@end

@implementation LWGridKeyboardView

- (instancetype)initWithFrame:(CGRect)frame andRows:(NSMutableArray *)rows {
    if (self = [super initWithFrame:frame]) {
        self.vStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
        self.vStackView.axis = UILayoutConstraintAxisVertical;
        self.vStackView.distribution = UIStackViewDistributionFillEqually;
        self.vStackView.alignment = UIStackViewAlignmentFill;
        self.vStackView.spacing = 3.0;

        for (NSMutableArray *cols in rows) {
            UIStackView *hStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
            hStackView.axis = UILayoutConstraintAxisHorizontal;
            hStackView.distribution = UIStackViewDistributionFillEqually;
            hStackView.alignment = UIStackViewAlignmentFill;
            hStackView.spacing = 3.0;
            for (LWKeyItem *keyItem in cols) {
                UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
                [btn setupStyle:keyItem.buttonStyle];
                [btn setTitle:keyItem.title forState:UIControlStateNormal];
                [btn setTag:keyItem.keyCode];
                [btn addTarget:self action:@selector(didButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
                [btn addTarget:self action:@selector(didButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                [btn addTarget:self action:@selector(didButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
                [hStackView addArrangedSubview:btn];
            }
            [self.vStackView addArrangedSubview:hStackView];
        }
        [self addSubview:self.vStackView];
        [self.vStackView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
            make.top.bottom.left.right.equalTo(self);
        }];
    }
    return self;
}

@end
