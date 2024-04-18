//
//  LWAddWQXArchiveViewController.m
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWAddWQXArchiveViewController.h"

@interface LWAddWQXArchiveViewController () <UIDocumentPickerDelegate>

@property (nonatomic, strong) UIDocumentPickerViewController *documentPickerVC;

//@property (nonatomic, strong)

@end

@implementation LWAddWQXArchiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];

    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"bin" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 100, 100);
    [button addTarget:self action:@selector(binButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)binButtonOnClick:(UIButton *)button {
    NSLog(@"binButtonOnClick...");
    [self presentViewController:self.documentPickerVC animated:YES completion:nil];
}

- (UIDocumentPickerViewController *)documentPickerVC {
    if (_documentPickerVC == nil) {
        self.documentPickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] 
                                                                                       inMode:UIDocumentPickerModeOpen];
        _documentPickerVC.delegate = self;
        _documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return _documentPickerVC;
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
    }
}

@end
