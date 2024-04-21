//
//  WQXArchiveManager.m
//  NC1020
//
//  Created by eric on 15/8/25.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "WQXArchiveManager.h"
#import "LWFileTools.h"

@interface WQXArchiveManager ()

@property (nonatomic, strong, readwrite) NSMutableDictionary *archives;

@end

static WQXArchiveManager *_instance;
static dispatch_once_t _wqx_once_token;

@implementation WQXArchiveManager

+ (instancetype)sharedInstance {
    dispatch_once(&_wqx_once_token, ^{
        _instance = [[WQXArchiveManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.archives = [[NSMutableDictionary alloc] init];
        [self load];
    }
    return self;
}

- (WQXArchive *)archiveWithName:(NSString *)name {
    return self.archives[name];
}

- (WQXArchive *)archiveCopyFrom:(WQXArchive *)archive withNewName:(NSString *)name {

    NSString *documentPath = [LWFileTools documentDirectoryPath];
    NSString *newArchiveDirectoryPath = [documentPath stringByAppendingPathComponent:@"nc1020"];
    BOOL isDir;
    if (![LWFileTools fileExistsAtPath:newArchiveDirectoryPath isDirectory:&isDir]) {
        [LWFileTools createDirectoryAtPath:newArchiveDirectoryPath error:Nil];
    }

    WQXArchive *newArchive = [[WQXArchive alloc] initWithName:name directory:@"nc1020"];

    NSString *srcRomPath;
    NSString *srcNorFlashPath;
    NSString *srcStatesPath;
    NSString *romDirectoryPath = [LWFileTools documentDirectoryPath];

    if (archive != Nil) {
        srcNorFlashPath = [documentPath stringByAppendingPathComponent:archive.norFlashPath];
        srcStatesPath = [documentPath stringByAppendingPathComponent:archive.statesPath];
    } else {
        srcRomPath = [romDirectoryPath stringByAppendingPathComponent:@"obj_lu.bin"];
        srcNorFlashPath = [romDirectoryPath stringByAppendingPathComponent:@"nc1020.fls"];
        srcStatesPath = [romDirectoryPath stringByAppendingPathComponent:@"nc1020.sts"];
    }

    NSError *error;
    NSString *romPath = [documentPath stringByAppendingPathComponent:newArchive.romPath];
    if (![LWFileTools fileExistsAtPath:romPath isDirectory:&isDir]) {
        [LWFileTools copyItemAtPath:srcRomPath
                             toPath:romPath
                              error:&error];
    }

    NSString *flsPath = [documentPath stringByAppendingPathComponent:newArchive.flsPath];
    if (![LWFileTools fileExistsAtPath:romPath isDirectory:&isDir]) {
        [LWFileTools copyItemAtPath:srcNorFlashPath
                             toPath:flsPath
                              error:&error];
    }

    NSString *norFlashPath = [documentPath stringByAppendingPathComponent:newArchive.norFlashPath];
    if (![LWFileTools fileExistsAtPath:romPath isDirectory:&isDir]) {
        [LWFileTools copyItemAtPath:srcNorFlashPath
                             toPath:norFlashPath
                              error:&error];
    }

    NSString *statesPath = [documentPath stringByAppendingPathComponent:newArchive.statesPath];
    if(![LWFileTools fileExistsAtPath:romPath isDirectory:&isDir]) {
        [LWFileTools copyItemAtPath:srcStatesPath
                             toPath:statesPath
                              error:&error];
    }

    return newArchive;
}

- (wqx::WqxRom)wqxRomWithArchive:(WQXArchive *)archive {
    wqx::WqxRom rom;
    NSString *basePath = [LWFileTools documentDirectoryPath];
    rom.romPath = [basePath stringByAppendingPathComponent:archive.romPath].UTF8String;
    rom.norFlashPath = [basePath stringByAppendingPathComponent:archive.norFlashPath].UTF8String;
    rom.statesPath = [basePath stringByAppendingPathComponent:archive.statesPath].UTF8String;
    return rom;
}

- (void)removeAllArchives {
    [_archives removeAllObjects];
}

- (void)addArchive:(WQXArchive *)archive {
    if ([_archives objectForKey:archive.name] == Nil) {
        [_archives setObject:archive forKey:archive.name];
    }
    [self save];
}

- (void)removeArchiveWithName:(NSString *)name {
    //
}

- (BOOL)save {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *name in self.archives.allKeys) {
        WQXArchive *archive = self.archives[name];
        [dict setValue:archive.toDictionary forKey:name];
    }
    NSData *resultData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *path = [[LWFileTools documentDirectoryPath] stringByAppendingPathComponent:@"config.json"];
    return [resultData writeToFile:path atomically:YES];
}

- (void)load {
    NSString *path = [[LWFileTools documentDirectoryPath] stringByAppendingPathComponent:@"config.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) {
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    for (NSString *name in dict.allKeys) {
        WQXArchive *archive = [[WQXArchive alloc] initWithDictionary:dict[name]];
        [self.archives setValue:archive forKey:name];
    }
}

@end
