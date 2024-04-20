//
//  WQXArchiveManager.m
//  NC1020
//
//  Created by eric on 15/8/25.
//  Copyright (c) 2015年 rainyx. All rights reserved.
//

#import "WQXArchiveManager.h"

@interface WQXArchiveManager ()

@property (nonatomic, strong) NSMutableDictionary *archives;
@property (nonatomic, copy) NSString *defaultArchiveName;

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

+ (WQXArchive *)archiveWithName:(NSString *)name {
    return [WQXArchiveManager archiveCopyFrom:Nil withNewName:name];
}

+ (WQXArchive *)archiveCopyFrom:(WQXArchive *)archive withNewName:(NSString *)name {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [WQXArchiveManager archiveDirectoryPath];
    NSString *newArchiveDirectoryPath = [basePath stringByAppendingPathComponent:@"nc1020"];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:newArchiveDirectoryPath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:newArchiveDirectoryPath withIntermediateDirectories:YES attributes:Nil error:Nil];
    }

    WQXArchive *newArchive = [[WQXArchive alloc] initWithName:name directory:@"nc1020"];

    NSString *srcRomPath;
    NSString *srcNorFlashPath;
    NSString *srcStatesPath;
    NSString *romDirectoryPath = [self romDirectoryPath];
    
    if (archive != Nil) {
        srcNorFlashPath = [basePath stringByAppendingPathComponent:archive.norFlashPath];
        srcStatesPath = [basePath stringByAppendingPathComponent:archive.statesPath];
    } else {
        srcRomPath = [romDirectoryPath stringByAppendingPathComponent:@"obj_lu.bin"];
        srcNorFlashPath = [romDirectoryPath stringByAppendingPathComponent:@"nc1020.fls"];
        srcStatesPath = [romDirectoryPath stringByAppendingPathComponent:@"nc1020.sts"];
    }
    
    NSError *error;
    NSString *romPath = [basePath stringByAppendingPathComponent:newArchive.romPath];
    if (![fileManager fileExistsAtPath:romPath]) {
        [fileManager copyItemAtPath:srcRomPath
                             toPath:romPath
                              error:&error];
    }

    NSString *flsPath = [basePath stringByAppendingPathComponent:newArchive.flsPath];
    if (![fileManager fileExistsAtPath:flsPath]) {
        [fileManager copyItemAtPath:srcNorFlashPath
                             toPath:flsPath
                              error:&error];
    }

    NSString *norFlashPath = [basePath stringByAppendingPathComponent:newArchive.norFlashPath];
    if (![fileManager fileExistsAtPath:norFlashPath]) {
        [fileManager copyItemAtPath:srcNorFlashPath
                             toPath:norFlashPath
                              error:&error];
    }

    NSString *statesPath = [basePath stringByAppendingPathComponent:newArchive.statesPath];
    if(![fileManager fileExistsAtPath:statesPath]) {
        [fileManager copyItemAtPath:srcStatesPath
                             toPath:statesPath
                              error:&error];
    }

    return newArchive;
}

+ (wqx::WqxRom)wqxRomWithArchive:(WQXArchive *)archive {
    wqx::WqxRom rom;
    NSString *basePath = [WQXArchiveManager archiveDirectoryPath];
    rom.romPath = [basePath stringByAppendingPathComponent:archive.romPath].UTF8String;
    rom.norFlashPath = [basePath stringByAppendingPathComponent:archive.norFlashPath].UTF8String;
    rom.statesPath = [basePath stringByAppendingPathComponent:archive.statesPath].UTF8String;
    return rom;
}

+ (NSString *)romDirectoryPath {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *path = [resourcePath stringByAppendingPathComponent:@"rom"];
    return path;
}

+ (NSString *)archiveDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

- (instancetype)init {
    if (self = [super init]) {

//        NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
//        NSData *data = [preferences objectForKey:@"perferences"];
//
//        WQXArchiveManager *manager = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (self.archives == Nil) {
            self.archives = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)removeAllArchives {
    [_archives removeAllObjects];
    _defaultArchiveName = Nil;
}

- (void)addArchive:(WQXArchive *)archive {
    if ([_archives objectForKey:archive.name] == Nil) {
        [_archives setObject:archive forKey:archive.name];
    }
}

- (void)removeArchiveWithName:(NSString *)name {
    
}

- (BOOL)save{
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:data forKey:@"perferences"];
//    return [defaults synchronize];
    return true;
}

//- (id)initWithCoder:(NSCoder *)coder {
//    if ([super init]) {
//        _archives = [coder decodeObjectForKey:@"archives"];
//        _defaultArchiveName = [coder decodeObjectForKey:@"defaultArchiveName"];
//        _defaultLayoutClassIndex = [coder decodeIntegerForKey:@"defaultLayoutClassIndex"];
//        return self;
//    } else {
//        return Nil;
//    }
//}

//- (void) encodeWithCoder:(NSCoder *)coder {
//    [coder encodeObject:_archives forKey:@"archives"];
//    [coder encodeObject:_defaultArchiveName forKey:@"defaultArchiveName"];
//    [coder encodeInteger:_defaultLayoutClassIndex forKey:@"defaultLayoutClassIndex"];
//}

- (NSDictionary *)archives {
    return _archives;
}

- (void)setDefaultArchive:(WQXArchive *)archive {
    _defaultArchiveName = archive.name;
}

- (WQXArchive *)defaultArchive {
    return [_archives objectForKey:_defaultArchiveName];
}

@end
