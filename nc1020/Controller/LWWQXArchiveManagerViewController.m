//
//  LWWQXArchiveManagerViewController.m
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWWQXArchiveManagerViewController.h"
#import "LWAddWQXArchiveViewController.h"
#import "LWAutolayout.h"
#import "LWTableView.h"

@interface LWWQXArchiveManagerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) LWTableView *tableview;

@end

@implementation LWWQXArchiveManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"abc";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableview = [[LWTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.placeholderView = ({
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"no rom, add rom";
//        label.backgroundColor = [UIColor redColor];
        label;
    });
//    self.tableview.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.tableview];
    CGFloat height = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.tableview lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(height);
        make.bottom.equalTo(self.view);
    }];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleDone target:self action:@selector(addItemOnClick:)];
    item.tintColor = [UIColor blackColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)addItemOnClick:(UIBarButtonItem *)item {
    NSLog(@"addItemOnClick...");
    LWAddWQXArchiveViewController *vc = [[LWAddWQXArchiveViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"abc";
    return cell;
}

@end
