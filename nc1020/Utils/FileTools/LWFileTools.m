//
//  LWFileTools.m
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "LWFileTools.h"

@implementation LWFileTools

+ (NSString *)documentDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:path error:error];
}

+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(nullable BOOL *)isDirectory {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:path isDirectory:isDirectory];
}

+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager copyItemAtPath:srcPath toPath:dstPath error:error];
}

+ (nullable NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager contentsOfDirectoryAtPath:path error:error];
}

@end
