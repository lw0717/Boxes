//
//  WQXArchive.h
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WQXArchive : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *directory;
/// rom: eg. obj_lu.bin
@property (nonatomic, copy) NSString *romName;
/// backups nor flash, fls: eg. obj_nc1020.fls
@property (nonatomic, copy) NSString *flsName;
/// fls: eg. nc1020.fls
@property (nonatomic, copy) NSString *norFlashName;
/// sts: eg. nc1020.sts
@property (nonatomic, copy) NSString *statesName;

- (instancetype)initWithName:(NSString *)name directory:(NSString *)directory;

- (NSString *)romPath;
- (NSString *)flsPath;
- (NSString *)norFlashPath;
- (NSString *)statesPath;

- (NSDictionary *)toDictionary;
- (void)fromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
