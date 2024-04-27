//
//  LWWQXArchiveManagerViewController.m
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWWQXArchiveManagerViewController.h"
#import "LWAddWQXArchiveViewController.h"
#import "LWAboutViewController.h"
#import "MBProgressHUD+LW.h"
#import "LWAutolayout.h"
#import "LWTableView.h"
#import "LWFileTools.h"
#import "LWWQXArchiveManager.h"
#import "LWWQXRootViewController.h"

@interface LWWQXArchiveManagerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) LWTableView *tableview;

@end

@implementation LWWQXArchiveManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:NO];
    self.title = @"Roms";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [self.tableview reloadData];
}

- (void)setupUI {
    self.tableview = [[LWTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
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
        label.text = @"没有找到 Rom 文件，请添加 Rom 文件";
        label;
    });
    [self.view addSubview:self.tableview];
    [self.tableview lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.left.right.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
        make.top.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
        make.bottom.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
    }];

    UIImage *addImage = [UIImage imageNamed:@"add"];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithImage:addImage style:UIBarButtonItemStyleDone target:self action:@selector(addItemOnClick:)];
    addItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = addItem;

    UIImage *settingImage = [UIImage imageNamed:@"setting"];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:settingImage style:UIBarButtonItemStyleDone target:self action:@selector(settingItemOnClick:)];
    settingItem.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = settingItem;
}

#pragma mark - Action
- (void)addItemOnClick:(UIBarButtonItem *)item {
    LWAddWQXArchiveViewController *addVC = [[LWAddWQXArchiveViewController alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)settingItemOnClick:(UIBarButtonItem *)item {
    LWAboutViewController *settingVc = [[LWAboutViewController alloc] init];
    [self.navigationController pushViewController:settingVc animated:YES];
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [LWWQXArchiveManager sharedInstance].archives.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    NSString *name = [LWWQXArchiveManager sharedInstance].archives.allKeys[indexPath.row];
    cell.textLabel.text = name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *name = [LWWQXArchiveManager sharedInstance].archives.allKeys[indexPath.row];
    LWWQXArchive *archive = [[LWWQXArchiveManager sharedInstance] archiveWithName:name];
    LWWQXRootViewController * vc = [[LWWQXRootViewController alloc] initWithArchive:archive];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
