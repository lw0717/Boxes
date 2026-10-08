//
//  LWAboutViewController.m
//  NC1020
//
//  Created by lw0717 on 2024/4/20.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWAboutViewController.h"
#import "LWAutolayout.h"

#define SettingCellReuseIdentifier @"SettingCellReuseIdentifier"

@interface LWAboutViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSArray <NSArray *>*titles;
@property (nonatomic, strong) NSDictionary *values;

@end

@implementation LWAboutViewController

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
    self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
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
            @"项目简介",
            @"隐私策略",
            @"演示视频",
        ], @[
            @"开源地址",
        ], @[
            @"联系我们",
        ], @[
            @"版本号",
        ],
    ];
    self.values = @{
        @"项目简介": @"https://boxes.lw0717.com",
        @"隐私策略": @"https://boxes.lw0717.com/privacy.html",
        @"演示视频": @"https://www.bilibili.com/video/BV1kt421w7Pb/",
        @"开源地址": @"https://github.com/lw0717/Boxes",
        @"联系我们": @"boxes.app@outlook.com",
        @"版本号" : [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]],
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
            [UIApplication.sharedApplication openURL:[NSURL URLWithString:value]
                                             options:@{}
                                   completionHandler:nil];
        }
    }
}

@end
