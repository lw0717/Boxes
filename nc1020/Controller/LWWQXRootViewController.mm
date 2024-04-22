//
//  LWWQXRootViewController.m
//  nc1020
//
//  Created by eric on 15/8/20.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "nc1020.h"
#import "LWWQXRootViewController.h"
#import "LWWQXScreenView.h"
#import "LWWQXDefaultScreenView.h"
#import "LWWQXGMUDScreenView.h"
#import "LWKeyItem.h"
#import "LWWQXArchiveManager.h"
#import "MBProgressHUD+LW.h"
#import "UIColor+LW.h"
#import "LWAutolayout.h"

@interface LWWQXRootViewController () <LWKeyboardViewDelegate>
{
    NSThread *_wqxLoopThread;
    CGRect _screenBounds;
}

@property (nonatomic, strong) LWWQXArchive *archive;

@property (nonatomic, strong) UIView *safeView;

@property (nonatomic, strong) LWWQXScreenView *screenView;

@property (nonatomic, assign) BOOL defaultScreenView;

@property (nonatomic, assign) BOOL run;

@end

@implementation LWWQXRootViewController

- (instancetype)initWithArchive:(LWWQXArchive *)archive {
    if (self = [super init]) {
        self.archive = archive;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:YES];
    self.view.backgroundColor = [UIColor colorWithRGB:0x222222];
    self.safeView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.safeView];
    _screenBounds = self.safeView.bounds;
    [self.safeView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.top.equalTo(self.view.lw_safeAreaLayoutGuide.lw_top ?: self.view.lw_top);
        make.left.equalTo(self.view.lw_safeAreaLayoutGuide.lw_left ?: self.view.lw_left);
        make.bottom.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
        make.right.equalTo(self.view.lw_safeAreaLayoutGuide ?: self.view);
    }];

    LWWQXArchiveManager *wqx = [LWWQXArchiveManager sharedInstance];

    self.defaultScreenView = YES;
    self.run = YES;
    self.screenView = [[LWWQXDefaultScreenView alloc] initWithFrame:_screenBounds andKeyboardViewDelegate:self];

    wqx::WqxRom rom = [wqx wqxRomWithArchive:self.archive];
    NSLog(@"lw0717: RAM path %s", rom.norFlashPath.c_str());
    NSLog(@"lw0717: ROM path %s", rom.romPath.c_str());
    wqx::Initialize(rom);
    wqx::LoadNC1020();

    [[self.screenView lcdView] beginUpdate];
    _wqxLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(wqxloopThreadCallback) object:nil];

    [_wqxLoopThread start];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)setScreenView:(LWWQXScreenView *)screenView {
    if (_screenView != nil) {
        [_screenView removeFromSuperview];
    }
    _screenView = screenView;
    [[_screenView lcdView] beginUpdate];
    [self.safeView addSubview:_screenView];
    [_screenView lw_makeConstraints:^(LWConstraintMaker * _Nonnull make) {
        make.top.bottom.left.right.equalTo(self.safeView);
    }];
}

- (void)switchScreenLayout {
    self.defaultScreenView = !self.defaultScreenView;
    if (self.defaultScreenView) {
        self.screenView = [[LWWQXDefaultScreenView alloc] initWithFrame:_screenBounds andKeyboardViewDelegate:self];
    } else {
        self.screenView = [[LWWQXGMUDScreenView alloc] initWithFrame:_screenBounds andKeyboardViewDelegate:self];
    }
}

- (void)wqxloopThreadCallback {
    while (self.run) {
        wqx::RunTimeSlice(20, false);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[self.screenView lcdView] setNeedsDisplay];
        });
        [NSThread sleepForTimeInterval:0.02];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - LWKeyboardViewDelegate

- (void)keyboardView:(LWKeyboardView *)view didKeydown:(NSInteger)keyCode {
    NSLog(@"lw0717: Did keydown with keycode: %zd\n", keyCode);
    if (keyCode < kWQXCustomKeyCodeBegin) {
        wqx::SetKey((uint8_t)keyCode, TRUE);
    }
}

- (void)keyboardView:(LWKeyboardView *)view didKeyup:(NSInteger)keyCode {
    NSLog(@"lw0717: Did keyup with keycode: %zd\n", keyCode);
    if (keyCode < kWQXCustomKeyCodeBegin) {
        wqx::SetKey((uint8_t)keyCode, FALSE);
        if (keyCode == 0x0F) {
            NSLog(@"lw0717: 电源");
            self.screenView = nil;
            self.run = NO;
            _wqxLoopThread = nil;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        // Handle custom keys.
        switch (keyCode) {
            case kWQXCustomKeyCodeSwitch:
                [self switchScreenLayout];
                break;
            case kWQXCustomKeyCodeLoad:
                wqx::LoadNC1020();
                break;
            case kWQXCustomKeyCodeSave:
                wqx::SaveNC1020();
                [MBProgressHUD lw_showMessageThenHide:@"保存完毕" toView:self.safeView];
                break;
            case kWQXCustomKeyCodeSeppdup:
                break;
            case kWQXCustomKeyCodeSpeedReset:
                break;
            default:
                break;
        }
    }
}

@end
