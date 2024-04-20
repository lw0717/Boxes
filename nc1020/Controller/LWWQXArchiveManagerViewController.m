//
//  LWWQXArchiveManagerViewController.m
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWWQXArchiveManagerViewController.h"
#import "LWSettingViewController.h"
#import "MBProgressHUD+LW.h"
#import "LWAutolayout.h"
#import "LWTableView.h"

@interface LWWQXArchiveManagerViewController () <UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate>

@property (nonatomic, strong) UIDocumentPickerViewController *documentPickerVC;
@property (nonatomic, strong) LWTableView *tableview;

@end

@implementation LWWQXArchiveManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Roms";
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
        label.text = @"没有找到 Rom 文件，请添加 Rom 文件";
        label;
    });
    [self.view addSubview:self.tableview];
    CGFloat height = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.tableview lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(height);
        make.bottom.equalTo(self.view);
    }];

    [self setupUI];
}

- (void)setupUI {
    UIImage *addImage = [UIImage imageNamed:@"add"];
    UIBarButtonItem *additem = [[UIBarButtonItem alloc] initWithImage:addImage style:UIBarButtonItemStyleDone target:self action:@selector(addItemOnClick:)];
    additem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = additem;

    UIImage *settingImage = [UIImage imageNamed:@"setting"];
    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithImage:settingImage style:UIBarButtonItemStyleDone target:self action:@selector(settingItemOnClick:)];
    settingItem.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = settingItem;
}

#pragma mark - Action
- (void)addItemOnClick:(UIBarButtonItem *)item {
    [self presentViewController:self.documentPickerVC animated:YES completion:nil];
}

- (void)settingItemOnClick:(UIBarButtonItem *)item {
    LWSettingViewController *settingVc = [[LWSettingViewController alloc] init];
    [self presentViewController:settingVc animated:YES completion:nil];
}

#pragma mark - Private
- (UIDocumentPickerViewController *)documentPickerVC {
    if (_documentPickerVC == nil) {
        self.documentPickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                                                       inMode:UIDocumentPickerModeOpen];
        _documentPickerVC.delegate = self;
        _documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return _documentPickerVC;
}

#pragma mark -
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"abc";
    return cell;
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    //获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;

        NSLog(@"lw0717: did pick file name: %@, url: %@", [urls.firstObject lastPathComponent], urls.firstObject);

        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
//            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                //读取出错
            } else {
                //上传
                //[self uploadingWithFileData:fileData fileName:fileName fileURL:newURL];
                NSLog(@"get file name: %@, of url: %@", fileName, newURL);
            }

            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        // 授权失败
        [MBProgressHUD lw_showMessageThenHide:@"获取 Rom 失败" toView:self.view];
    }
}


@end
