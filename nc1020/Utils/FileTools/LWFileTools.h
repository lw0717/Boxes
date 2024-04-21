//
//  LWFileTools.h
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWFileTools : NSObject

+ (NSString *)documentDirectoryPath;

+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

+ (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(nullable BOOL *)isDirectory;

+ (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError **)error;

+ (nullable NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
