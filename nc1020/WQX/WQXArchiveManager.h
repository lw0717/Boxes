//
//  WQXArchiveManager.m
//  NC1020
//
//  Created by rainyx on 15/8/23.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "nc1020.h"
#import "UIColor+LW.h"
#import "WQXArchive.h"

@interface WQXArchiveManager : NSObject

@property (nonatomic, readonly) NSDictionary *archives;

+ (instancetype)sharedInstance;

- (WQXArchive *)archiveWithName:(NSString *)name;
- (WQXArchive *)archiveCopyFrom:(WQXArchive *)archive withNewName:(NSString *)name;

- (wqx::WqxRom)wqxRomWithArchive:(WQXArchive *)archive;

- (void)addArchive:(WQXArchive *)archive;
- (void)removeArchiveWithName:(NSString *)name;
- (void)removeAllArchives;

- (BOOL)save;

@end
