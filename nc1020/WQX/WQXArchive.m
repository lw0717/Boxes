//
//  WQXArchive.m
//  NC1020
//
//  Created by lw0717 on 2024/4/16.
//  Copyright © 2024 lw0717. All rights reserved.
//

#import "WQXArchive.h"

@interface WQXArchive ()

@end

@implementation WQXArchive

- (instancetype)initWithName:(NSString *)name directory:(NSString *)directory {
    if (self = [super init]) {
        self.name = name;
        self.directory = directory;
        self.romName = @"obj_lu.bin";
        self.flsName = @"obj_nc1020.fls";
        self.norFlashName = @"archive_nc1020.fls";
        self.statesName = @"archive_nc1020.sts";
    }
    return self;
}

- (NSString *)romPath {
    return [self.directory stringByAppendingPathComponent:self.romName];
}

- (NSString *)flsPath {
    return [self.directory stringByAppendingPathComponent:self.flsName];
}

- (NSString *)norFlashPath {
    return [self.directory stringByAppendingPathComponent:self.norFlashName];
}

- (NSString *)statesPath {
    return [self.directory stringByAppendingPathComponent:self.statesName];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.name ?: @"new" forKey:@"name"];
    [dict setValue:self.directory ?: @"new" forKey:@"directory"];
    [dict setValue:self.romName ?: @"obj_lu.bin" forKey:@"obj_rom"];
    [dict setValue:self.flsName ?: @"obj_nc1020.fls" forKey:@"obj_fls"];
    [dict setValue:self.norFlashName ?: @"archive_nc1020.fls" forKey:@"archive_fls"];
    [dict setValue:self.statesName ?: @"archive_nc1020.sts" forKey:@"archive_sts"];
    return [dict copy];
}

- (void)fromDictionary:(NSDictionary *)dict {
    NSString *name = dict[@"name"];
    if (name) {
        self.name = name;
    }
    NSString *directory = dict[@"directory"];
    if (directory) {
        self.directory = directory;
    }
    NSString *romName = dict[@"obj_rom"];
    if (romName) {
        self.romName = romName;
    }
    NSString *flsName = dict[@"obj_fls"];
    if (flsName) {
        self.flsName = flsName;
    }
    NSString *fls = dict[@"archive_fls"];
    if (fls) {
        self.norFlashName = fls;
    }
    NSString *sts = dict[@"archive_sts"];
    if (sts) {
        self.statesName = sts;
    }
}

@end
