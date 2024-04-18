//
//  LWWQXRootViewController.m
//  nc1020
//
//  Created by eric on 15/8/20.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "nc1020.h"
#import "LWWQXRootViewController.h"
#import "WQXScreenLayout.h"
#import "WQXDefaultScreenLayout.h"
#import "WQXGMUDScreenLayout.h"
#import "LWKeyItem.h"
#import "LWToolbox.h"
#import "WQXArchiveManager.h"
#import "MBProgressHUD+LW.h"
#import "UIColor+LW.h"

static NSArray *_layoutClassNames = Nil;

@interface LWWQXRootViewController ()
{
    NSThread *_wqxLoopThread;
    WQXScreenLayout *_layout;
    CGRect _screenBounds;
}

@property (nonatomic, strong) UIView *safeView;

@property (nonatomic, assign) NSInteger defaultLayoutClassIndex;

- (NSString *)defaultLayoutClassName;
- (NSString *)switchLayout;

@end

@implementation LWWQXRootViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _layoutClassNames = [[NSArray alloc] initWithObjects:@"WQXDefaultScreenLayout", @"WQXGMUDScreenLayout", nil];

    self.view.backgroundColor = [UIColor colorWithRGB:0x222222];
    self.safeView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, self.view.frame.size.height - 40)];
    [self.view addSubview:self.safeView];
    _screenBounds = [LWToolbox rectForCurrentOrientation:self.safeView.bounds];

    WQXArchiveManager *wqx = [WQXArchiveManager sharedInstance];

    // Load screen layout.
    NSString *screenLayoutClassName = self.defaultLayoutClassName;
    _layout = [[NSClassFromString(screenLayoutClassName) alloc] initWithBounds:_screenBounds andKeyboardViewDelegate:self];
    [_layout attachToView:self.safeView];
    
    // Load archive.
    WQXArchive *archive = [wqx defaultArchive];
    if (archive == Nil) {
        archive = [WQXArchiveManager archiveWithName:@"default"];
        [wqx addArchive:archive];
        [wqx setDefaultArchive:archive];
        [wqx save];
    }
    
    wqx::WqxRom rom = [WQXArchiveManager wqxRomWithArchive:archive];

    NSLog(@"lw0717: RAM path %s", rom.norFlashPath.c_str());
    NSLog(@"lw0717: ROM path %s", rom.romPath.c_str());
    wqx::Initialize(rom);
    wqx::LoadNC1020();
    
    [[_layout lcdView] beginUpdate];
    _wqxLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(wqxloopThreadCallback) object:nil];
    
    [_wqxLoopThread start];
}

- (void)keyboardView:(LWKeyboardView *)view didKeydown:(NSInteger)keyCode {
    if (keyCode < kWQXCustomKeyCodeBegin) {
        wqx::SetKey((uint8_t)keyCode, TRUE);
    }
    NSLog(@"lw0717: Did keydown with keycode: %zd\n", keyCode);
}

- (void)setScreenLayout:(WQXScreenLayout *)layout {
    if (_layout != Nil) {
        [_layout detachFromView:self.safeView];
    }
    _layout = layout;
    [[_layout lcdView] beginUpdate];
    [_layout attachToView:self.safeView];
}

- (void)switchScreenLayout {
    WQXArchiveManager *wqx = [WQXArchiveManager sharedInstance];
    NSString *className = [self switchLayout];
    [wqx save];
    WQXScreenLayout *layout = [[NSClassFromString(className) alloc] initWithBounds:_screenBounds andKeyboardViewDelegate:self];
    [self setScreenLayout:layout];
}

- (void)keyboardView:(LWKeyboardView *)view didKeyup:(NSInteger)keyCode {
    if (keyCode < kWQXCustomKeyCodeBegin) {
        wqx::SetKey((uint8_t)keyCode, FALSE);
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
    NSLog(@"lw0717: Did keyup with keycode: %zd\n", keyCode);
}

- (void)wqxloopThreadCallback {
    while (true) {
        wqx::RunTimeSlice(20, false);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[_layout lcdView] setNeedsDisplay];
        });
        [NSThread sleepForTimeInterval:0.02];
    }
}

- (NSString *)defaultLayoutClassName {
    return [_layoutClassNames objectAtIndex:_defaultLayoutClassIndex];
}

- (NSString *)switchLayout {
    _defaultLayoutClassIndex = (_defaultLayoutClassIndex + 1) % _layoutClassNames.count;
    return [self defaultLayoutClassName];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end
