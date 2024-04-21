//
//  LWAddWQXArchiveViewController.m
//  NC1020
//
//  Created by lw0717 on 2024/4/21.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWAddWQXArchiveViewController.h"
#import "MBProgressHUD+LW.h"
#import "LWFileTools.h"
#import "LWAutolayout.h"
#import "WQXArchive.h"
#import "WQXArchiveManager.h"

#define AddCellReuseIdentifier @"AddCellReuseIdentifier"

@interface LWAddWQXArchiveViewController () <UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate>

@property (nonatomic, strong) UIDocumentPickerViewController *documentPickerVC;

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) WQXArchive *archive;

@property (nonatomic, assign) BOOL chooseRom;

@end

@implementation LWAddWQXArchiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加 Rom";
    self.view.backgroundColor = [UIColor whiteColor];
    self.archive = [[WQXArchive alloc] init];
    self.archive.directory = [NSUUID UUID].UUIDString;
    BOOL isDirectory = NO;
    NSString *documentPath = [LWFileTools documentDirectoryPath];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:self.archive.directory];
    if ([LWFileTools fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
        //
    } else {
        [LWFileTools createDirectoryAtPath:directoryPath error:nil];
    }
    [self setupUI];
}

- (void)setupUI {
    self.tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (@available(iOS 11.0, *)) {
        self.tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview registerClass:UITableViewCell.self forCellReuseIdentifier:AddCellReuseIdentifier];
    [self.view addSubview:self.tableview];
    [self.tableview lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.left.right.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
        make.top.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
        make.bottom.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
    }];

    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishItemOnClick:)];
    finishItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = finishItem;

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelItemOnClick:)];
    cancelItem.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)finishItemOnClick:(UIBarButtonItem *)item {
    if (self.textField.text.length == 0) {
        [MBProgressHUD lw_showMessageThenHide:@"请先输入名字" toView:self.view];
        return;
    }
    self.archive.name = self.textField.text;
    BOOL isDirectory = NO;
    NSString *documentPath = [LWFileTools documentDirectoryPath];
    NSString *romPath = [documentPath stringByAppendingPathComponent:self.archive.romPath];
    if (![LWFileTools fileExistsAtPath:romPath isDirectory:&isDirectory]) {
        [MBProgressHUD lw_showMessageThenHide:@"请先选择 Rom 文件" toView:self.view];
        return;
    }
    NSString *flsPath = [documentPath stringByAppendingPathComponent:self.archive.flsPath];
    if (![LWFileTools fileExistsAtPath:flsPath isDirectory:&isDirectory]) {
        [MBProgressHUD lw_showMessageThenHide:@"请先选择 fls 文件" toView:self.view];
        return;
    }
    [[WQXArchiveManager sharedInstance] addArchive:self.archive];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelItemOnClick:(UIBarButtonItem *)item {
    NSString *documentPath = [LWFileTools documentDirectoryPath];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:self.archive.directory];
    [LWFileTools removeItemAtPath:directoryPath error:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddCellReuseIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddCellReuseIdentifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"名字";
        if (self.textField == nil) {
            self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
            self.textField.placeholder = @"请输入名字";
            self.textField.textAlignment = NSTextAlignmentRight;
        }
        cell.accessoryView = self.textField;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"bin 文件 (*.bin)";
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 24)];
        label.text = @"选择";
        label.textAlignment = NSTextAlignmentRight;
        cell.accessoryView = label;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"fls 文件 (*.fls)";
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 24)];
        label.text = @"选择";
        label.textAlignment = NSTextAlignmentRight;
        cell.accessoryView = label;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.textField becomeFirstResponder];
    } else if (indexPath.row == 1 || indexPath.row == 2) {
        [self.textField resignFirstResponder];
        if (self.textField.text.length > 0) {
            if (indexPath.row == 1) {
                self.chooseRom = YES;
            } else {
                self.chooseRom = NO;
            }
            [self presentViewController:self.documentPickerVC animated:YES completion:nil];
        } else {
            [MBProgressHUD lw_showMessageThenHide:@"请先输入名字" toView:self.view];
        }
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    // 获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        // 通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;

        NSLog(@"lw0717: did pick file name: %@, url: %@", [urls.firstObject lastPathComponent], urls.firstObject);

        [MBProgressHUD lw_showLoading:@"正在导入文件" toView:self.view];

        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            // 读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                //读取出错
                [MBProgressHUD lw_showMessageThenHide:@"获取文件失败" toView:self.view];
            } else {
                NSString *filePath ;
                if (self.chooseRom) {
                    filePath = [[LWFileTools documentDirectoryPath] stringByAppendingPathComponent:self.archive.romPath];
                } else {
                    filePath = [[LWFileTools documentDirectoryPath] stringByAppendingPathComponent:self.archive.flsPath];
                }
                BOOL isSucceed = [fileData writeToFile:filePath atomically:YES];
                if (self.chooseRom == NO) {
                    NSString *norFlashPath = [[LWFileTools documentDirectoryPath] stringByAppendingPathComponent:self.archive.norFlashPath];
                    [fileData writeToFile:norFlashPath atomically:YES];
                }
                if (isSucceed) {
                    NSLog(@"lw0717: get file name: %@, of url: %@", fileName, filePath);
                    [MBProgressHUD lw_showMessageThenHide:@"导入文件成功" toView:self.view];
                } else {
                    [MBProgressHUD lw_showMessageThenHide:@"获取文件失败" toView:self.view];
                }
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        // 授权失败
        [MBProgressHUD lw_showMessageThenHide:@"获取文件失败" toView:self.view];
    }
}

@end
