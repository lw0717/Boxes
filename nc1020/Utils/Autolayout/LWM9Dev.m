//
//  LWM9Dev.m
//
//  Created by lw0717 on 2016-04-20.
//  Copyright (c) 2016 lw0717. Released under the MIT license.
//

#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>
#import <objc/runtime.h>

#import <UIKit/UIKit.h>

#import "LWM9Dev.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - LWWeakRef

@implementation LWWeakRef
+ (instancetype)weakRefWithObject:(nullable __kindof id)object {
    LWWeakRef *wrapper = [self new];
    wrapper.object = object;
    return wrapper;
}
- (NSUInteger)hash {
    return [self.object hash];
}
- (BOOL)isEqual:(id)_object {
    LWWeakRef *object = lw_as(_object, LWWeakRef);
    return (object && self.object == object.object);
}
@end

#pragma mark - method swizzle

void LWSwizzleMethod(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

/*
// FOUNDATION_EXPORT BOOL LWAddMethod(Class theClass, SEL selector, Method method);
BOOL LWAddMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
} */

#pragma mark - debugger

// A: https://stackoverflow.com/a/2188222/456536
// B: https://stackoverflow.com/a/47457802/456536
// C: https://developer.apple.com/library/archive/qa/qa1361/_index.html

#pragma mark - MD5

// #see https://stackoverflow.com/questions/1524604/md5-algorithm-in-objective-c
// #see https://stackoverflow.com/questions/10988369/is-there-a-md5-library-that-doesnt-require-the-whole-input-at-the-same-time/

// !!!: will CRASH if use 1024KB
static const NSUInteger LWChunkSize = 256 * 1024;

static NSString *LWMD5ToString(unsigned char *r) {
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     r[0],
                     r[1],
                     r[2],
                     r[3],
                     r[4],
                     r[5],
                     r[6],
                     r[7],
                     r[8],
                     r[9],
                     r[10],
                     r[11],
                     r[12],
                     r[13],
                     r[14],
                     r[15]];
}

NSString *LWMD5FromString(NSString *string) {
    NSCParameterAssert(string);

    unsigned char r[CC_MD5_DIGEST_LENGTH];

    const char *chars = string.UTF8String;
    CC_MD5(chars, (CC_LONG)strlen(chars), r);

    return LWMD5ToString(r);
}

NSString *LWMD5FromData(NSData *data) {
    NSCParameterAssert(data);

    unsigned char r[CC_MD5_DIGEST_LENGTH];

    NSUInteger dataLength = data.length;
    if (dataLength < LWChunkSize) {
        @autoreleasepool {
            CC_MD5(data.bytes, (CC_LONG)dataLength, r);
        }
    }
    else {
        CC_MD5_CTX md5;
        CC_MD5_Init(&md5);
        NSUInteger loc = 0;
        while (loc < dataLength) {
            @autoreleasepool {
                NSUInteger len = MIN(LWChunkSize, dataLength - loc);
                uint8_t bytes[len];
                [data getBytes:&bytes range:NSMakeRange(loc, len)];
                CC_MD5_Update(&md5, bytes, (CC_LONG)len); // len: sizeof(bytes)?
                loc += len;
            }
        }
        CC_MD5_Final(r, &md5);
    }

    return LWMD5ToString(r);
}

/* The performance of NSFileHandle is lower than NSInputStream
NSString * LWMD5FromFile(NSString *filePath) {
    NSCParameterAssert(filePath);
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (!handle) return nil;
    
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    while (true) { @autoreleasepool {
        NSData *data = [handle readDataOfLength:LWChunkSize];
        if (data.length) CC_MD5_Update(&md5, data.bytes, (CC_LONG)data.length);
        else break;
    }}
    CC_MD5_Final(r, &md5);
    
    return LWMD5ToString(r);
} // */

NSString *_Nullable LWMD5FromFile(NSString *filePath) {
    NSInputStream *input = [NSInputStream inputStreamWithFileAtPath:filePath];
    NSCParameterAssert(filePath && input);

    unsigned char r[CC_MD5_DIGEST_LENGTH];

    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    [input open];
    while ([input hasBytesAvailable] && !input.streamError) {
        @autoreleasepool {
            uint8_t buffer[LWChunkSize];
            NSInteger length = [input read:buffer maxLength:LWChunkSize];
            if (length > 0)
                CC_MD5_Update(&md5, buffer, (CC_LONG)length);
            else
                break;
        }
    }
    [input close];
    CC_MD5_Final(r, &md5);

    if (input.streamError) return nil;

    return LWMD5ToString(r);
}

#pragma mark - Base64

#pragma mark 6 bits

char LWBase64Encode6Bits(UInt8 n) {
    n = MIN(MAX(0, n), 63);
    if (n >= 0 && n <= 25)
        return 'A' + n; // ['A', 'Z']
    else if (n >= 26 && n <= 51)
        return 'a' + n - 26; // ['a', 'z']
    else if (n >= 52 && n <= 61)
        return '0' + n - 52; // ['0', '9']
    else if (n == 62)
        return '+';
    else /* if (n == 63) */
        return '/';
}

UInt8 LWBase64Decode6Bits(char c) {
    if (c >= 'A' && c <= 'Z')
        return c - 'A'; // [ 0, 25]
    else if (c >= 'a' && c <= 'z')
        return c - 'a' + 26; // [26, 51]
    else if (c >= '0' && c <= '9')
        return c - '0' + 52; // [52, 61]
    else if (c == '+')
        return 62;
    else /* if (c == '/') */
        return 63;
}

#pragma mark 64 bits

// 64 bits ~= 11 chars * 6 bits
const UInt8 LWBits64MaxLength = 11;

NSString *LWBase64Encode64Bits(UInt64 bits64) {
    const UInt8 bits06Max = 0b111111;
    NSMutableString *base64 = [NSMutableString new];
    while (bits64 > 0) {
        [base64 appendFormat:@"%c", LWBase64Encode6Bits(bits64 & bits06Max)];
        bits64 >>= 6;
    }
    if (base64.length == 0) {
        [base64 appendFormat:@"%c", LWBase64Encode6Bits(0)];
    }
    return base64;
}

UInt64 LWBase64Decode64Bits(NSString *base64, NSUInteger offset) {
    UInt8 length = MIN(base64.length - offset, LWBits64MaxLength);
    UInt64 bits64 = 0;
    for (UInt8 i = 0; i < length; ++i) {
        bits64 |= (UInt64)LWBase64Decode6Bits([base64 characterAtIndex:offset + i]) << (6 * i);
    }
    return bits64;
}

#pragma mark - hardware

// iPhone X: iPhone10,3 || iPhone10,6
// Simultor.Any: i386 || x86_64
NSString *LWHardwareType(void) {
    struct utsname systemInfo;
    uname(&systemInfo);
    return @(systemInfo.machine);
}

NSString *LWDeviceUUID(void) {
    NSString *uuid = UIDevice.currentDevice.identifierForVendor.UUIDString;
    if (!uuid.length) {
        static NSString *const UUIDKey = @"UUID@BaijiaYun";
        NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
        uuid = [ud stringForKey:UUIDKey];
        if (!uuid.length) {
            uuid = NSUUID.UUID.UUIDString;
            [ud setObject:uuid forKey:UUIDKey];
        }
    }
    return uuid;
}

#pragma mark - Tuple

@interface LWTuple ()

@property (nonatomic, copy) LWTuplePackBlock pack;

@end

@implementation LWTuple

+ (instancetype)defaultTuple {
    static LWTuple *DefaultTuple = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DefaultTuple = [self new];
    });
    return DefaultTuple;
}

+ (instancetype)tupleWithPack:(LWTuplePackBlock)pack {
    LWTuple *tuple = [self new];
    tuple.pack = pack;
    return tuple;
}

@dynamic unpack; // writeonly: no getter
- (void)unpack:(id /* LWTupleUnpackBlock */)unpack {
    (self.pack ?: ^(LWTupleUnpackBlock unpack) {
        if (unpack) unpack(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); // 0/nil
    })(unpack);
}

@end

NS_ASSUME_NONNULL_END
