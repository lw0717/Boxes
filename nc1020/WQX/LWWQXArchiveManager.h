//
//  LWWQXArchiveManager.m
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "nc1020.h"
#import "UIColor+LW.h"
#import "LWWQXArchive.h"

@interface LWWQXArchiveManager : NSObject

@property (nonatomic, readonly) NSDictionary *archives;

+ (instancetype)sharedInstance;

- (LWWQXArchive *)archiveWithName:(NSString *)name;
- (LWWQXArchive *)archiveCopyFrom:(LWWQXArchive *)archive withNewName:(NSString *)name;

- (wqx::WqxRom)wqxRomWithArchive:(LWWQXArchive *)archive;

- (void)addArchive:(LWWQXArchive *)archive;
- (void)removeArchiveWithName:(NSString *)name;
- (void)removeAllArchives;

- (BOOL)save;

@end
