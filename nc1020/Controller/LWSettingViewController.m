//
//  LWSettingViewController.m
//  NC1020
//
//  Created by lw0717 on 2024/4/20.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWSettingViewController.h"
#import "LWAutolayout.h"
#import <SafariServices/SafariServices.h>

#define SettingCellReuseIdentifier @"SettingCellReuseIdentifier"

@interface LWSettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSArray <NSArray *>*titles;
@property (nonatomic, strong) NSDictionary *values;

@end

@implementation LWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"关于";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if (@available(iOS 11.0, *)) {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.view addSubview:self.tableview];
    [self.tableview lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.left.right.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
        make.top.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
        make.bottom.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
    }];
}

- (void)setupData {
    self.titles = @[
        @[
            @"项目简介:",
            @"隐私策略:",
        ],
        @[
            @"开源地址:",
//            @"捐赠项目:",
        ],
        @[
            @"联系我:",
        ],
        @[
            @"版本号:",
        ],
    ];
    self.values = @{
        @"项目简介:" : @"https://nc1020.lw0717.com",
        @"隐私策略:" : @"https://nc1020.lw0717.com/privacy.html",
        @"捐赠项目:" : @"https://afdian.net/a/lw0717",
        @"开源地址:" : @"https://github.com/lw0717/NC1020",
        @"联系我:": @"nc1020app@outlook.com",
        @"版本号:" : [NSString stringWithFormat:@"%@ (%@)", [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleVersion"]],
    };
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingCellReuseIdentifier];
    NSString *title = self.titles[indexPath.section][indexPath.row];
    cell.textLabel.text = title;
    NSString *value = self.values[title];
    if (value) {
        cell.detailTextLabel.text = value;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section < 2) {
        NSString *title = self.titles[indexPath.section][indexPath.row];
        NSString *value = self.values[title];
        if (value) {
            SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:value]];
            [self presentViewController:safariVc animated:YES completion:nil];
        }
    }
}

@end
