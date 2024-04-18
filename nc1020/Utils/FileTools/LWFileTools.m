//
//  LWFileTools.m
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWFileTools.h"

static LWFileTools *_instance;
static dispatch_once_t _file_once_token;

@interface LWFileTools ()

@end

@implementation LWFileTools

+ (instancetype)sharedInstance {
    dispatch_once(&_file_once_token, ^{
        _instance = [[LWFileTools alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        //
    }
    return self;
}

- (void)copyFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
}


+ (void)copyFileAtPath:(NSString *)srcPath toPath:(NSString *)dstPath {
    NSFileManager* manager = [NSFileManager defaultManager];
    NSError *error;
    [manager copyItemAtPath:srcPath toPath:dstPath error:&error];
    //
}

@end
