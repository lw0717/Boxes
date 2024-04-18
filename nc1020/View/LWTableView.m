//
//  LWTableView.m
//  NC1020
//
//  Created by lw0717 on 2024/4/18.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWTableView.h"
#import "LWAutolayout.h"

@implementation LWTableView

- (void)setPlaceholderView:(UIView *)placeholderView {
    if (_placeholderView) {
        [_placeholderView removeFromSuperview];
    }
    _placeholderView = placeholderView;
}

- (void)reloadData {
    [super reloadData];
    [self checkEmpty];
}

- (void)checkEmpty {
    if (self.placeholderView == nil) {
        return;
    }
    BOOL isEmpty = YES;

    id<UITableViewDataSource> src = self.dataSource;
    NSInteger sections = 1;
    if ([src respondsToSelector: @selector(numberOfSectionsInTableView:)]) {
        sections = [src numberOfSectionsInTableView:self];
    }
    for (int i = 0; i < sections; ++i) {
        NSInteger rows = [src tableView:self numberOfRowsInSection:i];
        if (rows > 0) {
            isEmpty = NO;
            break;
        }
    }

    [self.placeholderView removeFromSuperview];
    if (isEmpty) {
        [self addSubview:self.placeholderView];
        [self.placeholderView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
            make.width.equalTo(@300);
            make.height.equalTo(@300);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
//            make.left.right.equalTo(self);
//            make.top.bottom.equalTo(self);
        }];
    }
}

@end
