//
//  LWM9Dev.h
//
//  Created by lw0717 on 2016-04-20.
//  Copyright (c) 2016 lw0717. Released under the MIT license.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** for statement-expression */

#define lw_return

/** cast */

#define lw_as(_OBJECT, CLASS) ({                                 \
    __typeof__(_OBJECT) OBJECT = _OBJECT;                         \
    ([OBJECT isKindOfClass:CLASS.class] ? (CLASS *)OBJECT : nil); \
})

static inline BOOL lw_eq(id _Nullable a, id _Nullable b) {
    return a == b || [a isEqual:b];
}

/** struct */

// cast to ignore const: lw_set((CGRect)CGRectZero, { set.size = self.intrinsicContentSize; })
#define lw_set(_STRUCT, STATEMENTS) ({ \
    __typeof__(_STRUCT) set = _STRUCT;  \
    STATEMENTS                          \
    set;                                \
})

/** variable arguments */

#define _lw_va_for(TYPE, VAR, FIRST, ARGS, TERMINATION) \
    for (TYPE VAR = FIRST; VAR != TERMINATION; VAR = va_arg(ARGS, TYPE))

// lw_va_each(type, first, termination, ^(type var) { ... });
#define lw_va_each(TYPE, FIRST, TERMINATION, BLOCK)       \
    {                                                      \
        va_list ARGS;                                      \
        va_start(ARGS, FIRST);                             \
        _lw_va_for(TYPE, VAR, FIRST, ARGS, TERMINATION) { \
            BLOCK(VAR);                                    \
        }                                                  \
        va_end(ARGS);                                      \
    }

/** just weakify */

#define lw_weak_var(...) \
    lw_metamacro_foreach(lw_weak_var_, , __VA_ARGS__)

#define lw_weak_var_(INDEX, VAR)                              \
    __typeof__(VAR) lw_metamacro_concat(VAR, _temp_) = (VAR); \
    __weak __typeof__(VAR) VAR = lw_metamacro_concat(VAR, _temp_);

#define lw_weak_block(ARGS, BLOCK) ({                          \
    _Pragma("GCC diagnostic push")                              \
        _Pragma("GCC diagnostic ignored \"-Wunused-variable\"") \
            lw_weak_var ARGS;                                  \
    _Pragma("GCC diagnostic pop")                               \
        BLOCK;                                                  \
})

/** strongify if nil */

#define lw_strongify_ifNil(...) \
    lw_strongify(__VA_ARGS__);  \
    if ([NSArray arrayWithObjects:__VA_ARGS__, nil].count != lw_metamacro_argcount(__VA_ARGS__))

/** LWWeakRef */

@interface LWWeakRef<ObjectType>: NSObject
@property (nonatomic, weak, nullable) ObjectType object;
+ (instancetype)weakRefWithObject:(nullable ObjectType)object;
@end

/** dispatch */

/*
static inline dispatch_time_t lw_dispatch_time_in_seconds(NSTimeInterval seconds) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
}
static inline void lw_dispatch_after_seconds(NSTimeInterval seconds, dispatch_queue_t queue, dispatch_block_t block) {
    dispatch_after(lw_dispatch_time_in_seconds(seconds), queue ?: dispatch_get_main_queue(), block);
} // */

// execute immediately if on the queue, or async if not - the earlier the better
static inline void lw_dispatch_on(dispatch_queue_t queue, dispatch_block_t block) {
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue))
        block();
    else
        dispatch_async(queue, block);
}
static inline void lw_dispatch_on_main_queue(dispatch_block_t block) {
    lw_dispatch_on(dispatch_get_main_queue(), block);
}

// execute immediately if on the queue, to avoid deadlock - a serial queue dispatch_sync to itself
static inline void lw_dispatch_sync(dispatch_queue_t queue, dispatch_block_t block) {
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(queue))
        block();
    else
        dispatch_sync(queue, block);
}
static inline void lw_dispatch_sync_main_queue(dispatch_block_t block) {
    lw_dispatch_sync(dispatch_get_main_queue(), block);
}

static inline void lw_dispatch_async_main_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}
static inline void lw_dispatch_async_high_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
}
static inline void lw_dispatch_async_default_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
static inline void lw_dispatch_async_low_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), block);
}
static inline void lw_dispatch_async_background_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

/** to string */

#define LWStringFromLiteral(...)                              @ #__VA_ARGS__
#define LWCStringFromLiteral(...)                             #__VA_ARGS__
#define LWStringFromValue(VALUE, DEFAULT_VALUE)               ({ VALUE ? [@(VALUE) description] : DEFAULT_VALUE; })
#define LWObjectFromValue(VALUE, DEFAULT_VALUE)               ({ VALUE ? @(VALUE) : DEFAULT_VALUE; })
#define LWStringFromValue_Nonnull(VALUE)                      ({ [@(VALUE) description] ?: [NSString stringWithFormat:@"%@", @(VALUE)]; }) // high-performance ?: ensure-nonnull
#define LWObjectFromValue_Nonnull(VALUE)                      ({ @(VALUE); })
#define LWStringFromBoolean(BOOLEAN)                          ({ BOOLEAN ? @"YES" : @"NO"; })

// !!!: use DEFAULT_VALUE if PREPROCESSOR is undefined or its value is same to itself
#define LWStringFromPreprocessor(PREPROCESSOR, DEFAULT_VALUE) ({                 \
    NSString *string = LWStringFromLiteral(PREPROCESSOR);                        \
    lw_return [string isEqualToString:@ #PREPROCESSOR] ? DEFAULT_VALUE : string; \
})

#define TMIN(TYPE, A, B)                (TYPE) MIN((TYPE)A, (TYPE)B)
#define TMAX(TYPE, A, B)                (TYPE) MAX((TYPE)A, (TYPE)B)

#define MINMAX(V, L, R)                 MIN(MAX(L, V), R)
#define TMINMAX(TYPE, V, L, R)          (TYPE) MIN((TYPE)MAX((TYPE)L, (TYPE)V), (TYPE)R)

/** keypath */

#define LWInstanceKeypath(CLASS, PATH) ({ \
    CLASS *INSTANCE = nil;                 \
    LWKeypath(INSTANCE, PATH);            \
})

#define LWKeypath(OBJECT, PATH) ({                                                        \
    (void)(NO && ((void)OBJECT.PATH, NO)); /* copied from libextobjc/EXTKeyPathCoding.h */ \
    @ #PATH;                                                                               \
})

/** version comparison */

// 10 < 10.0 < 10.0.0
// NO `LWVersionGT` and `LWVersionLE`
#define LWVersionCMP(A, B) ({ \
    [A hasPrefix:[B stringByAppendingString:@"-"]] ? -1 \
    : [B hasPrefix:[A stringByAppendingString:@"-"]] ? 1 \
    : [A compare:B options:NSNumericSearch]; \
})
#define LWVersionEQ(A, B) ({ LWVersionCMP(A, B) == NSOrderedSame; })
#define LWVersionLT(A, B) ({ LWVersionCMP(A, B) <  NSOrderedSame; })
#define LWVersionGE(A, B) ({ LWVersionCMP(A, B) >= NSOrderedSame; })
#define LWRemovingBuildMetadata(V) ({ \
    NSRange range = [V rangeOfString:@"+"]; \
    range.location == NSNotFound ? V : [V substringToIndex:range.location]; \
})

/** milliseconds */

typedef long long LWMilliseconds;
#define LW_MSEC_PER_SEC 1000ll // 1000ull for `unsigned long long`
// Conversions between NSTimeInterval and LWMilliseconds
static inline NSTimeInterval LWTimeIntervalFromMilliseconds(LWMilliseconds milliseconds) {
    return (NSTimeInterval)((double)milliseconds / LW_MSEC_PER_SEC);
}
static inline LWMilliseconds LWMillisecondsFromTimeInterval(NSTimeInterval timeInterval) {
    return (LWMilliseconds)(timeInterval * LW_MSEC_PER_SEC);
}
// NSTimeInterval/LWMilliseconds between 1970 and 2001
#define LWTimeIntervalBetween1970AndReferenceDate NSTimeIntervalSince1970
#define LWMillisecondsBetween1970AndReferenceDate LWMillisecondsFromTimeInterval(LWTimeIntervalBetween1970AndReferenceDate)
// NSTimeInterval/LWMilliseconds between 2001 and now
static inline NSTimeInterval LWTimeIntervalSinceReferenceDate(void) {
    return NSDate.timeIntervalSinceReferenceDate;
}
static inline LWMilliseconds LWMillisecondsSinceReferenceDate(void) {
    return LWMillisecondsFromTimeInterval(LWTimeIntervalSinceReferenceDate());
}
// NSTimeInterval/LWMilliseconds between 1970 and now, but NOT between 1970 and 2001
static inline NSTimeInterval LWTimeIntervalSince1970(void) {
    return NSDate.timeIntervalSinceReferenceDate + LWTimeIntervalBetween1970AndReferenceDate;
}
static inline LWMilliseconds LWMillisecondsSince1970(void) {
    return LWMillisecondsFromTimeInterval(LWTimeIntervalSince1970());
}

/** safe range */

static inline NSRange LWMakeSafeRange(NSUInteger loc, NSUInteger len, NSUInteger length) {
    loc = MIN(loc, length);
    len = MIN(len, length - loc);
    return NSMakeRange(loc, len);
}
static inline NSRange LWSafeRangeForLength(NSRange range, NSUInteger length) {
    return LWMakeSafeRange(range.location, range.length, length);
}

/** progress */

typedef struct {
    long long totalUnitCount, completedUnitCount;
    BOOL determinate; // NOT indeterminate
    double fractionCompleted;
    BOOL finished;
} LWProgress;

static inline LWProgress
LWProgressMake(long long totalUnitCount, long long completedUnitCount) {
    BOOL indeterminate = (totalUnitCount < 0
                          || completedUnitCount < 0
                          || (completedUnitCount == 0 && totalUnitCount == 0));
    BOOL finished = (!indeterminate
                     && completedUnitCount >= totalUnitCount);
    double fractionCompleted = (indeterminate ? 0.0
                                : finished    ? 1.0
                                              : ((double)completedUnitCount / totalUnitCount));
    return (LWProgress){
        .totalUnitCount = totalUnitCount,
        .completedUnitCount = completedUnitCount,
        .determinate = !indeterminate,
        .finished = finished,
        .fractionCompleted = fractionCompleted};
}
static inline BOOL
LWProgressEqualToProgress(LWProgress progress1, LWProgress progress2) {
    return (progress1.totalUnitCount == progress2.totalUnitCount
            && progress1.completedUnitCount == progress2.completedUnitCount);
}

static inline LWProgress
LWProgressFromString(NSString *string) {
    NSRange range = [string rangeOfString:@"/"];
    if (range.location == NSNotFound) {
        return LWProgressMake(0, 0);
    }
    long long completedUnitCount = [[string substringToIndex:range.location] longLongValue];
    long long totalUnitCount = [[string substringFromIndex:range.location + range.length] longLongValue];
    return LWProgressMake(totalUnitCount, completedUnitCount);
}
static inline NSString *
LWStringFromProgress(LWProgress progress) {
    return [NSString stringWithFormat:@"%lld/%lld", progress.completedUnitCount, progress.totalUnitCount];
}

static inline NSString *
LWProgressString(LWProgress progress) {
    return [NSString stringWithFormat:@"%.2f%%",
                     progress.fractionCompleted * 100];
}
static inline NSString *
LWProgressDescription(LWProgress progress) {
    return [NSString stringWithFormat:@"<LWProgress: %.2f%% = %lld / %lld (determinate: %d, finished: %d)>",
                     progress.fractionCompleted * 100,
                     progress.completedUnitCount,
                     progress.totalUnitCount,
                     progress.determinate,
                     progress.finished];
}

/** this class */

#define lw_this_class_name ({                                                          \
    static NSString *ClassName = nil;                                                   \
    if (!ClassName) {                                                                   \
        NSString *prettyFunction = [NSString stringWithUTF8String:__PRETTY_FUNCTION__]; \
        NSUInteger loc = [prettyFunction rangeOfString:@"["].location + 1;              \
        NSUInteger len = [prettyFunction rangeOfString:@" "].location - loc;            \
        NSRange range = LWMakeSafeRange(loc, len, prettyFunction.length);              \
        ClassName = [prettyFunction substringWithRange:range];                          \
    }                                                                                   \
    ClassName;                                                                          \
})
#define lw_this_class                       NSClassFromString(lw_this_class_name)

/** runtime */

/* invoking at runtime & invoking log
 !!!: ENABLE after all `import` statements and DISABLE after using likes `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END`
 
 // ENABLE invoking at runtime:
 #undef  lw_invoke_at_runtime
 #define lw_invoke_at_runtime 1
 
 // DISABLE invoking at runtime:
 #undef  lw_invoke_at_runtime
 #define lw_invoke_at_runtime 0
 
 // ENABLE invoking log:
 #undef  lw_invoke_log
 #define lw_invoke_log 1
 
 // DISABLE invoking log:
 #undef  lw_invoke_log
 #define lw_invoke_log 0
 */
#define lw_invoke_at_runtime                0
#define lw_invoke_log                       0

// lw_invoke(self, setA:, a, b:, b); // [self setA:a b:b];
#define lw_invoke(OBJ, ...)                 lw_metamacro_concat(lw_invoke_, lw_metamacro_if_eq(0, lw_invoke_at_runtime)(ct)(rt))(OBJ, __VA_ARGS__)
// o = lw_invoke_obj(id, self, getA); // o = [self getA];
#define lw_invoke_obj(TYPE, OBJ, ...)       lw_metamacro_concat(lw_invoke_obj_, lw_metamacro_if_eq(0, lw_invoke_at_runtime)(ct)(rt))(TYPE, OBJ, __VA_ARGS__)
// a = lw_invoke_val(int, 0, self, getA); // a = [self getA];
#define lw_invoke_val(TYPE, INIT, OBJ, ...) lw_metamacro_concat(lw_invoke_val_, lw_metamacro_if_eq(0, lw_invoke_at_runtime)(ct)(rt))(TYPE, INIT, OBJ, __VA_ARGS__)

// ct: compile-time
#define lw_invoke_ct(OBJ, ...)                                                               \
    {                                                                                         \
        if (lw_invoke_log) NSLog(@lw_metamacro_stringify(lw_invoke_ct(OBJ, __VA_ARGS__))); \
        [OBJ lw_metamacro_foreach_concat(, , __VA_ARGS__)];                                  \
    }
#define lw_invoke_obj_ct(TYPE, OBJ, ...)       lw_invoke_val_ct(TYPE, nil, OBJ, __VA_ARGS__)
#define lw_invoke_val_ct(TYPE, INIT, OBJ, ...) ({                                                        \
    if (lw_invoke_log) NSLog(@lw_metamacro_stringify(lw_invoke_val_ct(TYPE, INIT, OBJ, __VA_ARGS__))); \
    [OBJ lw_metamacro_foreach_concat(, , __VA_ARGS__)];                                                  \
})

// rt: run-time
#define lw_invoke_rt(OBJ, ...) \
    { lw_invoke_val_rt(void *, nil, OBJ, __VA_ARGS__); }
#define lw_invoke_obj_rt(TYPE, OBJ, ...)       (__bridge TYPE) lw_invoke_val_rt(void *, nil, OBJ, __VA_ARGS__)
#define lw_invoke_val_rt(TYPE, INIT, OBJ, ...) ({                                                                     \
    if (lw_invoke_log) NSLog(@lw_metamacro_stringify(lw_invoke_val_rt(TYPE, INIT, OBJ, __VA_ARGS__)));              \
    TYPE res = INIT;                                                                                                   \
    _Pragma("GCC diagnostic push")                                                                                     \
        _Pragma("GCC diagnostic ignored \"-Wundeclared-selector\"")                                                    \
            SEL sel = lw_invoke_sel(__VA_ARGS__);                                                                     \
    _Pragma("GCC diagnostic pop")                                                                                      \
        NSMethodSignature *methodSignature = [OBJ methodSignatureForSelector:sel];                                     \
    if (methodSignature) {                                                                                             \
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];                       \
        [invocation setTarget:OBJ];                                                                                    \
        [invocation setSelector:sel];                                                                                  \
        [invocation retainArguments];                                                                                  \
        NSUInteger index = 2; /* args start at 2 */                                                                    \
        if (invocation.methodSignature.numberOfArguments > index) lw_invoke_args(__VA_ARGS__);                        \
        [invocation invoke];                                                                                           \
        if (strcmp(invocation.methodSignature.methodReturnType, @encode(void)) != 0) [invocation getReturnValue:&res]; \
    }                                                                                                                  \
    res;                                                                                                               \
})

// ???: DOES NOT work when `pod package`
// #define lw_pointer(VAR) ({ __typeof__(VAR) x = VAR; &x; })

#define lw_invoke_sel(...) \
    @selector(lw_metamacro_foreach(lw_invoke_sel_iter, , __VA_ARGS__))
#define lw_invoke_sel_iter(INDEX, VAR) \
    lw_metamacro_if_eq(lw_metamacro_is_even(INDEX), 1) /* ? */ (VAR) /* : */ ()

#define lw_invoke_args(...)                                        \
    {                                                               \
        lw_metamacro_foreach(lw_invoke_args_iter, , __VA_ARGS__); \
    }
#define lw_invoke_args_iter(INDEX, VAR) \
    lw_metamacro_if_eq(0, lw_metamacro_is_even(INDEX)) /* ? */ ({ __typeof__(VAR) arg = VAR; [invocation setArgument:&arg atIndex:index++]; }) /* : */ ()

/** swizzle */

FOUNDATION_EXPORT void LWSwizzleMethod(Class theClass, SEL originalSelector, SEL swizzledSelector);

/** debugger */

static inline BOOL LWIsDebuggerAttached(void) {
    return getppid() != 1;
}

/** assert */

#define LWAssert(CONDITION, DESCRIPTION, ...) ({                                 \
    if (LWIsDebuggerAttached()) NSAssert(CONDITION, DESCRIPTION, ##__VA_ARGS__); \
    CONDITION;                                                                    \
})
#define LWCAssert(CONDITION, DESCRIPTION, ...) ({                                 \
    if (LWIsDebuggerAttached()) NSCAssert(CONDITION, DESCRIPTION, ##__VA_ARGS__); \
    CONDITION;                                                                     \
})

#define LWParamAssert(CONDITION) ({                           \
    if (LWIsDebuggerAttached()) NSParameterAssert(CONDITION); \
    CONDITION;                                                 \
})
#define LWCParamAssert(CONDITION) ({                           \
    if (LWIsDebuggerAttached()) NSCParameterAssert(CONDITION); \
    CONDITION;                                                  \
})

/** @dynamic property with associated-object */

// #import <objc/runtime.h>

#define lw_associate_primitive_type(TYPE, PROPERTY, GETTER, DECODE, SETTER, ENCODE)                    \
    @dynamic PROPERTY;                                                                                  \
    -TYPE GETTER {                                                                                      \
        id PROPERTY = objc_getAssociatedObject(self, @selector(PROPERTY));                              \
        return DECODE;                                                                                  \
    }                                                                                                   \
    -(void)SETTER TYPE PROPERTY {                                                                       \
        objc_setAssociatedObject(self, @selector(PROPERTY), ENCODE, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
    }

#define lw_associate_reference_type(TYPE, PROPERTY, GETTER, SETTER, POLICY)   \
    @dynamic PROPERTY;                                                         \
    -TYPE GETTER {                                                             \
        return objc_getAssociatedObject(self, @selector(PROPERTY));            \
    }                                                                          \
    -(void)SETTER TYPE PROPERTY {                                              \
        objc_setAssociatedObject(self, @selector(PROPERTY), PROPERTY, POLICY); \
    }

/** MD5 */

FOUNDATION_EXPORT NSString *LWMD5FromString(NSString *string);
FOUNDATION_EXPORT NSString *LWMD5FromData(NSData *data);
FOUNDATION_EXPORT NSString *_Nullable LWMD5FromFile(NSString *filePath);

/** Base64 */

FOUNDATION_EXPORT char LWBase64Encode6Bits(UInt8 n);
FOUNDATION_EXPORT UInt8 LWBase64Decode6Bits(char c);

FOUNDATION_EXPORT NSString *LWBase64Encode64Bits(UInt64 bits64);
FOUNDATION_EXPORT UInt64 LWBase64Decode64Bits(NSString *base64, NSUInteger offset); // reads 11 chars: 64 bits ~= 11 chars * 6 bits

/**
 *  M9TuplePack & M9TupleUnpack
 *  1. define:
 *      - (LWTupleType(BOOL state1, BOOL state2))states;
 *  or:
 *      - (LWTuple<LWTupleGeneric(BOOL state1, BOOL state2> *)states;
 *  or:
 *      - (LWTuple<void (^)(BOOL state1, BOOL state2> *)states;
 *  2. pack:
 *      BOOL state1 = self.state1, state2 = self.state2;
 *      return LWTuplePack((BOOL, BOOL), state1, state2);
 *  3. unpack:
 *      LWTupleUnpack(tuple) = ^(BOOL state1, BOOL state2) {
 *          // ...
 *      };
 * !!!:
 *  1. LWTuplePack 中不要使用 `.`，否则会断言失败，例如
 *      LWTuplePack((BOOL, BOOL), self.state1, self.state2);
 *  原因是
 *      a. self 将被 tuple 持有、直到 tuple 被释放
 *      b. self.state1、self.state2 的值在拆包时才读取，取到的值可能与打包时不同
 *  为避免出现不可预期的结果，定义临时变量提前读取属性值、然后打包，例如
 *      BOOL state1 = self.state1, state2 = self.state2;
 *      LWTuple *tuple = LWTuplePack((BOOL, BOOL), state1, state2);
 *  2. LWTupleUnpack 中不需要 weakify、strongify，因为 unpack block 会被立即执行
 */

// 1. define:
/** - (LWTupleType(NSString *string, NSInteger integer))aTuple; */
#define LWTupleType(...)        LWTuple<void (^)(__VA_ARGS__)> *
/** - (LWTuple<LWTupleGeneric(NSString *string, NSInteger integer)> *)aTuple; */
#define LWTupleGeneric          void(^)
// 2. pack:
#define LWTuplePack(TYPE, ...)  _LWTuplePack(void(^) TYPE, __VA_ARGS__)
#define _LWTuplePack(TYPE, ...) ({                                                          \
    NSCAssert([LWStringFromLiteral(__VA_ARGS__) rangeOfString:@"."].location == NSNotFound, \
        @"DONOT use `.` in LWTuplePack(%@)",                                                \
        LWStringFromLiteral(__VA_ARGS__));                                                  \
    [LWTuple tupleWithPack:^(LWTupleUnpackBlock NS_NOESCAPE unpack) {                      \
        if (unpack) ((TYPE)unpack)(__VA_ARGS__);                                             \
    }];                                                                                      \
})
// 3. unpack:
// 用 (LWTuple.defaultTuple, TUPLE) 而不是 (TUPLE ?: LWTuple.defaultTuple)，因为后者会导致 TUPLE 被编译器认为是 nullable 的
#define LWTupleUnpack(TUPLE) (LWTuple.defaultTuple, TUPLE).unpack
// 4. internal:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^LWTupleUnpackBlock)(/* ... */);
#pragma clang diagnostic pop
typedef void (^LWTuplePackBlock)(LWTupleUnpackBlock NS_NOESCAPE unpack);
@interface LWTuple<T>: NSObject
@property (nonatomic /* , writeonly */, assign, setter=unpack:) id /* <T NS_NOESCAPE> */ unpack;
@property (class, nonatomic, readonly) LWTuple<T> *defaultTuple;
+ (instancetype)tupleWithPack:(LWTuplePackBlock)pack;
@end

/** RACTupleUnpack without unused warning */
#define LW_RACTupleUnpack(...)                                 \
    _Pragma("GCC diagnostic push")                              \
        _Pragma("GCC diagnostic ignored \"-Wunused-variable\"") \
            RACTupleUnpack(__VA_ARGS__)                         \
                _Pragma("GCC diagnostic pop")

/** hardware */

// iPhone X: iPhone10,3 || iPhone10,6
// Simultor.Any: i386 || x86_64
FOUNDATION_EXPORT NSString *LWHardwareType(void);
FOUNDATION_EXPORT NSString *LWDeviceUUID(void);

NS_ASSUME_NONNULL_END
