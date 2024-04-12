//
//  LWAutolayout.m
//
//  Created by lw0717 on 2018-10-12.
//  Copyright (c) 2018 lw0717. Released under the MIT license.
//

#import <objc/runtime.h>

#import "LWAutolayout.h"

#import "LWEXTScope.h"
#import "LWM9Dev.h"

// !!!: NO lw_dblcmp - `(double)1.2f == 1.2f` is true, but `(double)1.2f == 1.2` is false
#define lw_fltcmp(A, CMP, B) ({ (float)A CMP(float) B; })

/*
@implementation LWAutolayout
@end // */

@class LWConstraint;

#pragma mark - UIView (lw_constraints)

@interface UIView (lw_constraints)
@property (nonatomic, nullable, setter=lw_setConstraints:)
    NSMutableArray<LWConstraint *> *lw_constraints;
@end

@implementation UIView (lw_constraints)
lw_associate_reference_type((NSMutableArray<LWConstraint *> *),
    lw_constraints,
    lw_constraints,
    lw_setConstraints:,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC);
@end

#pragma mark - NSLayoutConstraint (lw_constraints)

@interface NSLayoutConstraint (lw_constraints)
+ (NSString *)lw_descriptionStartWithConstraint:(NSObject *)constraint
                                            view:(id)view
                                      attributes:(NSSet<NSNumber /* <NSLayoutAttribute> */ *> *)attributes
                                        relation:(NSLayoutRelation)relation
                                         targets:(NSSet<LWConstraintTarget *> *)targets
                             ignoreTargetNumbers:(BOOL)ignoreTargetNumbers
                                      multiplier:(CGFloat)multiplier
                                  constantString:(nullable NSString *)constantString
                                shouldBeArchived:(BOOL)shouldBeArchived
                                      identifier:(nullable NSString *)identifier
                                        priority:(UILayoutPriority)priority
                                          active:(BOOL)active;
@end

@implementation NSLayoutConstraint (lw_constraints)

#if DEBUG
+ (void)load {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (LWIsDebuggerAttached()
        && ![UIView instancesRespondToSelector:@selector(mas_makeConstraints:)]) {
        LWSwizzleMethod(self, @selector(description), @selector(lw_description));
    }
#pragma clang diagnostic pop
}
#endif

- (NSString *)lw_description {
    if ([self isKindOfClass:NSClassFromString(@"NSContentSizeLayoutConstraint")]) {
        BOOL swizzled = (_cmd == @selector(description));
        return swizzled ? [self lw_description] : [self description];
    }
    NSSet<NSNumber /* <NSLayoutAttribute> */ *> *attributes = [NSSet setWithObject:@(self.firstAttribute)];
    NSSet<LWConstraintTarget *> *targets = self.secondItem ? [NSSet setWithObject:[LWConstraintTarget targetWithObject:self.secondItem attribute:self.secondAttribute]] : nil;
    NSString *constantString = [NSLayoutConstraint lw_constantString:self.constant hasTargt:targets.count > 0];
    return [NSLayoutConstraint lw_descriptionStartWithConstraint:self
                                                             view:self.firstItem
                                                       attributes:attributes
                                                         relation:self.relation
                                                          targets:targets
                                              ignoreTargetNumbers:YES
                                                       multiplier:self.multiplier
                                                   constantString:constantString
                                                 shouldBeArchived:self.shouldBeArchived
                                                       identifier:self.identifier
                                                         priority:self.priority
                                                           active:self.active];
}

+ (NSString *)lw_descriptionStartWithConstraint:(NSObject *)constraint
                                            view:(id)view
                                      attributes:(NSSet<NSNumber /* <NSLayoutAttribute> */ *> *)attributes
                                        relation:(NSLayoutRelation)relation
                                         targets:(NSSet<LWConstraintTarget *> *)targets
                             ignoreTargetNumbers:(BOOL)ignoreTargetNumbers
                                      multiplier:(CGFloat)multiplier
                                  constantString:(nullable NSString *)constantString
                                shouldBeArchived:(BOOL)shouldBeArchived
                                      identifier:(nullable NSString *)identifier
                                        priority:(UILayoutPriority)priority
                                          active:(BOOL)active {
    // view.attr1.attr2 = [item1.attr1.attr2, item1.attr1.attr2] × multiplier + constant
    //  | shouldBeArchived | id: ... | high | inactive

    NSMutableString *description = [NSMutableString new];

    [description appendFormat:@"<%@:%p ", constraint.class, constraint];
    [description appendString:[self lw_objectDescription:view]];

    if (attributes.count == 4 && [attributes isEqual:[NSSet setWithObjects:@(NSLayoutAttributeTop), @(NSLayoutAttributeLeft), @(NSLayoutAttributeBottom), @(NSLayoutAttributeRight), nil]]) {
        [description appendString:@".edges"];
    }
    else if (attributes.count == 2 && [attributes isEqual:[NSSet setWithObjects:@(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY), nil]]) {
        [description appendString:@".center"];
    }
    else if (attributes.count == 2 && [attributes isEqual:[NSSet setWithObjects:@(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight), nil]]) {
        [description appendString:@".size"];
    }
    else {
        for (NSNumber *nunmber in attributes) {
            [description appendString:[self lw_layoutAttributeDescription:(NSLayoutAttribute)nunmber.integerValue]];
        }
    }

    [description appendString:[self lw_layoutRelationDescription:relation]];

    if (targets.count > 1) [description appendString:@"["];
    BOOL isFirst = YES;
    for (LWConstraintTarget *target in targets) {
        if (!isFirst) [description appendString:@", "];
        [description appendString:[self lw_objectDescription:((target.object || ignoreTargetNumbers) ? target.object : target.number)]];
        [description appendString:[self lw_layoutAttributeDescription:target.attribute]];
        isFirst = NO;
    }
    if (targets.count > 1) [description appendString:@"]"];

    if (targets.count && lw_fltcmp(multiplier, !=, 1.0)) [description appendFormat:@" x %g", multiplier];
    if (constantString) [description appendString:constantString];

    if (shouldBeArchived) [description appendFormat:@" | shouldBeArchived"];
    if (identifier) [description appendFormat:@" | ID:%@", identifier];
    if (priority != UILayoutPriorityRequired) [description appendString:[NSLayoutConstraint lw_layoutPriorityDescription:priority]];
    if (!active) [description appendFormat:@" | inactive"];

    [description appendString:@">"];
    return description;
}

+ (NSString *)lw_objectDescription:(id)object {
    UILayoutGuide *layoutGuide = lw_as(object, UILayoutGuide);
    if (layoutGuide) {
        return [NSString stringWithFormat:@"%@:%@", layoutGuide.class, layoutGuide.identifier];
    }

    UIView *view = lw_as(object, UIView);
    if (!view) {
        NSNumber *number = lw_as(object, NSNumber);
        if (number != nil) {
            CGFloat constant = number.doubleValue;
            return [NSString stringWithFormat:lw_fltcmp(constant, >=, 0.0) ? @"%g" : @"- %g", ABS(constant)];
        }
        else {
            return [NSString stringWithFormat:@"%@", object];
        }
    }

    NSString *description = view.accessibilityIdentifier;
    if (!description.length) {
        description = (lw_as(view, UILabel).text
                           ?: ({ UITextField *textField = lw_as(view, UITextField); textField.text.length ? textField.text : textField.placeholder; })
                              ?
                          : lw_as(view, UITextField).placeholder
                              ?
                          : lw_as(view, UITextView).text
                              ?
                              : lw_as(view, UIButton).currentTitle);
        static const NSInteger maxLength = 20;
        if (description.length > maxLength) {
            description = [[description substringToIndex:maxLength] stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        }
    }

    if (description.length) {
        return [NSString stringWithFormat:@"%@:%@", view.class, description];
    }
    else {
        return [NSString stringWithFormat:@"%@:%p", view.class, view];
    }
}

+ (NSString *)lw_layoutRelationDescription:(NSLayoutRelation)relation {
    switch (relation) {
        case NSLayoutRelationLessThanOrEqual:
            return @" <= ";
        case NSLayoutRelationGreaterThanOrEqual:
            return @" >= ";
        case NSLayoutRelationEqual:
            return @" == ";
        default:
            return @" ??? ";
    }
}

+ (NSString *)lw_layoutAttributeDescription:(NSLayoutAttribute)attribute {
    switch (attribute) {
        case NSLayoutAttributeLeft:
            return @".left";
        case NSLayoutAttributeRight:
            return @".right";
        case NSLayoutAttributeTop:
            return @".top";
        case NSLayoutAttributeBottom:
            return @".bottom";
        case NSLayoutAttributeLeading:
            return @".leading";
        case NSLayoutAttributeTrailing:
            return @".trailing";
        case NSLayoutAttributeWidth:
            return @".width";
        case NSLayoutAttributeHeight:
            return @".height";
        case NSLayoutAttributeCenterX:
            return @".centerX";
        case NSLayoutAttributeCenterY:
            return @".centerY";
        case NSLayoutAttributeFirstBaseline:
            return @".firstBaseline";
        case NSLayoutAttributeLastBaseline:
            return @".lastBaseline";
        case NSLayoutAttributeLeftMargin:
            return @".leftMargin";
        case NSLayoutAttributeRightMargin:
            return @".rightMargin";
        case NSLayoutAttributeTopMargin:
            return @".topMargin";
        case NSLayoutAttributeBottomMargin:
            return @".bottomMargin";
        case NSLayoutAttributeLeadingMargin:
            return @".leadingMargin";
        case NSLayoutAttributeTrailingMargin:
            return @".trailingMargin";
        case NSLayoutAttributeCenterXWithinMargins:
            return @".centerXWithinMargins";
        case NSLayoutAttributeCenterYWithinMargins:
            return @".centerYWithinMargins";
        default:
            return @"";
    }
}

+ (nullable NSString *)lw_constantString:(CGFloat)constant hasTargt:(BOOL)hasTargt {
    if (hasTargt && lw_fltcmp(constant, ==, 0.0)) {
        return nil;
    }
    NSMutableString *description = [NSMutableString new];
    if (hasTargt) {
        [description appendString:lw_fltcmp(constant, >, 0.0) ? @" + " : @" - "];
    }
    else if (lw_fltcmp(constant, <, 0.0)) {
        [description appendString:@"- "];
    }
    [description appendFormat:@"%g", ABS(constant)];
    return description;
}

+ (NSString *)lw_layoutPriorityDescription:(UILayoutPriority)priority {
    if (priority == UILayoutPriorityRequired) {
        return @" | required";
    }
    else if (priority == UILayoutPriorityDefaultHigh) {
        return @" | high";
    }
    else if (priority == 510) { // UILayoutPriorityDragThatCanResizeScene
        return @" | DragThatCanResizeScene";
    }
    else if (priority == 500) { // UILayoutPrioritySceneSizeStayPut
        return @" | SceneSizeStayPut";
    }
    else if (priority == 490) { // UILayoutPriorityDragThatCannotResizeScene
        return @" | DragThatCannotResizeScene";
    }
    else if (priority == UILayoutPriorityDefaultLow) {
        return @" | low";
    }
    else if (priority == UILayoutPriorityFittingSizeLevel) {
        return @" | FittingSizeLevel";
    }
    else {
        return [NSString stringWithFormat:@" | priority: %g", priority];
    }
}

@end

#pragma mark - LWConstraintTarget

@implementation LWConstraintTarget

+ (instancetype)targetWithObject:(id)object {
    return [self targetWithObject:object attribute:NSLayoutAttributeNotAnAttribute];
}

+ (instancetype)targetWithObject:(id)object attribute:(NSLayoutAttribute)attribute {
    LWConstraintTarget *target = [LWConstraintTarget new];
    target->_number = lw_as(object, NSNumber);
    target->_object = (target.number == nil ? object : nil);
    target->_attribute = attribute;
    return target;
}

- (NSUInteger)hash {
    return [self.object hash] + (NSInteger)self.attribute; // hash: without number, because it is a constant instead of target
}

- (BOOL)isEqual:(id)_target {
    LWConstraintTarget *target = lw_as(_target, LWConstraintTarget);
    return (target
            && self.object == target.object
            && self.attribute == target.attribute); // isEqual: without number, because it is a constant instead of target
}

- (NSString *)description {
    if (self.number != nil) {
        return [NSString stringWithFormat:@"@%@", self.number];
    }
    NSMutableString *description = [NSMutableString new];
    [description appendFormat:@"<%@:%p ", self.class, self];
    [description appendString:[NSLayoutConstraint lw_objectDescription:self.object]];
    [description appendString:[NSLayoutConstraint lw_layoutAttributeDescription:self.attribute]];
    [description appendString:@">"];
    return description;
}

@end

#pragma mark - LWConstraintMakerRef

@interface LWConstraintMakerRef ()
@property (nonatomic, readwrite) LWConstraint *constraint;
+ (instancetype)makerWithConstraint:(LWConstraint *)constraint;
@end

#pragma mark - LWConstraint

typedef NS_ENUM(NSUInteger, LWConstraintType) {
    LWConstraintType_none,
    LWConstraintType_constant,
    LWConstraintType_insets,
    LWConstraintType_centerOffset,
    LWConstraintType_sizeOffset
};

@interface LWConstraint ()

@property (nonatomic, weak, nullable) UIView *view; // nil

@property (nonatomic) NSMutableSet<NSNumber /* <NSLayoutAttribute> */ *> *attributes; // edges

@property (nonatomic) NSLayoutRelation relation; // NSLayoutRelationEqual

@property (nonatomic) NSMutableSet<LWConstraintTarget *> *targets; // nil

@property (nonatomic) CGFloat multiplier; // 1.0

@property (nonatomic) CGFloat constant; // 0.0
@property (nonatomic) UIEdgeInsets insets; // UIEdgeInsetsZero
@property (nonatomic) CGPoint centerOffset; // CGPointZero
@property (nonatomic) CGSize sizeOffset; // CGSizeZero
@property (nonatomic) LWConstraintType constantType; // LWConstraintType_none

@property (nonatomic) BOOL shouldBeArchived; // NO
@property (nonatomic, nullable) NSString *identifier; // nil
@property (nonatomic) UILayoutPriority priority; // UILayoutPriorityRequired
@property (nonatomic) BOOL active; // YES

#pragma mark NSLayoutConstraint

@property (nonatomic, nullable) NSMutableArray<NSLayoutConstraint *> *nsConstraints; // nil
@property (nonatomic) BOOL needsInstall; // NO, YES when addToView
@property (nonatomic) BOOL needsReplace, needsUpdate; // NO

- (void)removeConflictsForUpdating;
- (void)removeSimilarForReplacing;

- (void)install;
- (void)uninstall;

- (void)addToView;
- (void)removeFromView;

@end

@implementation LWConstraint

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareForMake];
    }
    return self;
}

- (void)prepareForMake {
    self.view = nil;
    [self prepareForReplace];
}

- (void)prepareForReplace {
    self.attributes = [NSMutableSet new];
    self.relation = NSLayoutRelationEqual;
    self.targets = [NSMutableSet new];
    self.multiplier = 1.0;
    self.constant = 0.0;
    self.insets = UIEdgeInsetsZero;
    self.centerOffset = CGPointZero;
    self.sizeOffset = CGSizeZero;
    self.constantType = LWConstraintType_none;
    self.priority = UILayoutPriorityRequired;
    self.active = YES;
}

- (CGFloat)constantForAttribute:(NSLayoutAttribute)attribute defaultConstant:(CGFloat)constant {
    switch (attribute) {
        case NSLayoutAttributeLeft:
        case NSLayoutAttributeLeading:
        case NSLayoutAttributeLeftMargin:
        case NSLayoutAttributeLeadingMargin:
            return (self.constantType == LWConstraintType_insets ? self.insets.left : constant);
        case NSLayoutAttributeRight:
        case NSLayoutAttributeTrailing:
        case NSLayoutAttributeRightMargin:
        case NSLayoutAttributeTrailingMargin:
            return (self.constantType == LWConstraintType_insets ? -self.insets.right : constant);
        case NSLayoutAttributeTop:
        case NSLayoutAttributeTopMargin:
        case NSLayoutAttributeFirstBaseline:
            return (self.constantType == LWConstraintType_insets ? self.insets.top : constant);
        case NSLayoutAttributeBottom:
        case NSLayoutAttributeBottomMargin:
        case NSLayoutAttributeLastBaseline:
            return (self.constantType == LWConstraintType_insets ? -self.insets.bottom : constant);
        case NSLayoutAttributeCenterX:
        case NSLayoutAttributeCenterXWithinMargins:
            return (self.constantType == LWConstraintType_centerOffset ? self.centerOffset.x : constant);
        case NSLayoutAttributeCenterY:
        case NSLayoutAttributeCenterYWithinMargins:
            return (self.constantType == LWConstraintType_centerOffset ? self.centerOffset.y : constant);
        case NSLayoutAttributeWidth:
            return (self.constantType == LWConstraintType_sizeOffset ? self.sizeOffset.width : constant);
        case NSLayoutAttributeHeight:
            return (self.constantType == LWConstraintType_sizeOffset ? self.sizeOffset.height : constant);
        default:
            return constant;
    }
}

- (void)removeConflictsForUpdating {
    NSMutableArray<NSLayoutConstraint *> *nsConstraints = [NSMutableArray new];
    for (LWConstraint *constraint in [self.view.lw_constraints copy]) {
        if (!constraint.needsInstall
            && constraint != self
            && constraint.view == self.view
            && [constraint.attributes intersectsSet:self.attributes]
            && constraint.relation == self.relation
            && [constraint.targets isEqual:self.targets]
            && lw_fltcmp(constraint.multiplier, ==, self.multiplier)) {
            for (NSNumber *attributeNumber in self.attributes) {
                if (![constraint.attributes containsObject:attributeNumber]) {
                    continue;
                }
                [constraint.attributes removeObject:attributeNumber]; // 1
                for (NSLayoutConstraint *nsConstraint in [constraint.nsConstraints copy]) {
                    if ([self isConflictConstraint:nsConstraint attribute:attributeNumber.integerValue]) {
                        [nsConstraints addObject:nsConstraint]; // 2
                        [constraint.nsConstraints removeObject:nsConstraint]; // 3
                    }
                }
            }
            if (!constraint.attributes.count) {
                [self.view.lw_constraints removeObject:constraint]; // 4
                [constraint removeFromView]; // 5
            }
            // else partly updating
            break;
        }
    }
    if (nsConstraints.count) {
        self.nsConstraints = nsConstraints;
    }
}

- (BOOL)isConflictConstraint:(NSLayoutConstraint *)nsConstraint attribute:(NSLayoutAttribute)attribute {
    // already done before calling this method
    // if (nsConstraint.firstItem != self.view
    //     || nsConstraint.firstAttribute != attribute
    //     || nsConstraint.relation != self.relation
    //     || lw_fltcmp(nsConstraint.multiplier, !=, self.multiplier)) {
    //     return NO;
    // }
    if (!self.targets.count && !nsConstraint.secondItem) {
        return YES;
    }
    if ([self.targets containsObject:[LWConstraintTarget targetWithObject:nsConstraint.secondItem attribute:nsConstraint.secondAttribute]]) {
        return YES;
    }
    if (nsConstraint.firstAttribute == nsConstraint.secondAttribute
        && [self.targets containsObject:[LWConstraintTarget targetWithObject:nsConstraint.secondItem attribute:NSLayoutAttributeNotAnAttribute]]) {
        return YES;
    }
    return NO;
}

- (void)removeSimilarForReplacing {
    for (LWConstraint *constraint in [self.view.lw_constraints copy]) {
        if (!constraint.needsInstall
            && constraint != self
            && constraint.view == self.view
            && [constraint.attributes isEqualToSet:self.attributes]
            && constraint.relation == self.relation) {
            [constraint uninstall];
        }
    }
}

- (void)install {
    [self addToView];

    if (self.needsReplace) {
        // replace self
        if (self.nsConstraints) {
            [NSLayoutConstraint deactivateConstraints:self.nsConstraints];
            self.nsConstraints = nil;
            // NO [self uninstall] && NO [self removeFromView] - will re-install
        }
        // replaceSimilar
        else {
            [self removeSimilarForReplacing];
        }
    }
    else if (self.needsUpdate) {
        // updateExisting
        if (!self.nsConstraints) {
            [self removeConflictsForUpdating];
        }
        // else install self
    }

    UIView *view = self.view;
    NSLayoutRelation relation = self.relation;
    NSSet<LWConstraintTarget *> *targets = (self.targets.count ? [self.targets copy] : [NSSet setWithObject:[LWConstraintTarget targetWithObject:nil]]);
    CGFloat multiplier = self.multiplier;
    BOOL shouldBeArchived = self.shouldBeArchived;
    NSString *identifier = self.identifier;
    UILayoutPriority priority = self.priority;
    BOOL active = self.active;

    NSMutableArray<NSLayoutConstraint *> *nsConstraints = (self.nsConstraints ? nil : [NSMutableArray new]);
    for (NSNumber *attributeNumber in self.attributes) {
        NSLayoutAttribute attribute = attributeNumber.integerValue;
        if (attribute == NSLayoutAttributeNotAnAttribute) {
            continue; // impossible
        }

        for (LWConstraintTarget *_target in targets) {
            NSNumber *number = _target.number;

            id target = (number == nil ? _target.object : nil);
            UILayoutGuide *layoutGuide = lw_as(_target.object, UILayoutGuide);
            if (layoutGuide) {
                target = layoutGuide;
            }

            if (attribute != NSLayoutAttributeWidth
                && attribute != NSLayoutAttributeHeight) {
                if (!target) {
                    target = self.view.superview;
                }
                if (lw_fltcmp(multiplier, ==, 0.0)) {
                    multiplier = FLT_MIN; // NOT only width and height
                }
            }

            NSLayoutAttribute targetAttribute = (!target                                                ? NSLayoutAttributeNotAnAttribute
                                                 : _target.attribute == NSLayoutAttributeNotAnAttribute ? attribute
                                                                                                        : _target.attribute);

            CGFloat constant = [self constantForAttribute:targetAttribute != NSLayoutAttributeNotAnAttribute ? targetAttribute : attribute
                                          defaultConstant:self.constantType == LWConstraintType_constant ? self.constant : number.doubleValue];

            if (self.nsConstraints) {
                for (NSLayoutConstraint *nsConstraint in self.nsConstraints) {
                    if (view == nsConstraint.firstItem
                        && attribute == nsConstraint.firstAttribute
                        && relation == nsConstraint.relation
                        && target == nsConstraint.secondItem
                        && targetAttribute == nsConstraint.secondAttribute
                        && lw_fltcmp(multiplier, ==, nsConstraint.multiplier)) {
                        nsConstraint.constant = constant;
                        nsConstraint.shouldBeArchived = shouldBeArchived;
                        nsConstraint.identifier = identifier;
                        nsConstraint.priority = priority;
                        nsConstraint.active = active;
                    }
                }
            }
            else {
                NSLayoutConstraint *nsConstraint =
                    [NSLayoutConstraint constraintWithItem:view
                                                 attribute:attribute
                                                 relatedBy:relation
                                                    toItem:target
                                                 attribute:targetAttribute
                                                multiplier:multiplier
                                                  constant:constant];
                nsConstraint.shouldBeArchived = shouldBeArchived;
                nsConstraint.identifier = identifier;
                nsConstraint.priority = priority;
                nsConstraint.active = active;
                [nsConstraints addObject:nsConstraint];
            }
        }
    }
    if (nsConstraints.count) {
        self.nsConstraints = nsConstraints;
    }

    self.needsReplace = NO;
    self.needsUpdate = NO;
    self.needsInstall = NO;
}

- (void)uninstall {
    [NSLayoutConstraint deactivateConstraints:self.nsConstraints];
    self.nsConstraints = nil;
    [self removeFromView];
}

- (void)addToView {
    self.needsInstall = YES;
    if (!self.view.lw_constraints) {
        self.view.lw_constraints = [NSMutableArray new];
    }
    if (![self.view.lw_constraints containsObject:self]) {
        [self.view.lw_constraints addObject:self];
    }
}

- (void)removeFromView {
    [self.view.lw_constraints removeObject:self];
}

- (LWConstraintAttributesMaker *)replace {
    [self prepareForReplace];
    self.needsReplace = YES;
    self.needsUpdate = NO;
    self.needsInstall = YES;
    return [LWConstraintAttributesMaker makerWithConstraint:self];
}

- (LWConstraintConstantMaker *)update {
    self.needsReplace = NO;
    self.needsUpdate = YES;
    self.needsInstall = YES;
    return [LWConstraintConstantMaker makerWithConstraint:self];
}

- (NSString *)description {
    return [NSLayoutConstraint lw_descriptionStartWithConstraint:self
                                                             view:self.view
                                                       attributes:self.attributes
                                                         relation:self.relation
                                                          targets:self.targets
                                              ignoreTargetNumbers:self.constantType != LWConstraintType_none
                                                       multiplier:self.multiplier
                                                   constantString:[self constantString]
                                                 shouldBeArchived:self.shouldBeArchived
                                                       identifier:self.identifier
                                                         priority:self.priority
                                                           active:self.active];
}

- (NSString *)constantString {
    NSMutableString *description = [NSMutableString new];
    if (self.constantType == LWConstraintType_constant) {
        NSString *constantString = [NSLayoutConstraint lw_constantString:self.constant hasTargt:self.targets.count > 0];
        if (constantString) {
            [description appendString:constantString];
        }
    }
    else if (self.constantType == LWConstraintType_insets) {
        if (self.targets.count) [description appendString:@"."];
        [description appendFormat:@"insets(%@)", NSStringFromUIEdgeInsets(self.insets)];
    }
    else if (self.constantType == LWConstraintType_centerOffset) {
        if (self.targets.count) [description appendString:@"."];
        [description appendFormat:@"center(%@)", NSStringFromCGPoint(self.centerOffset)];
    }
    else if (self.constantType == LWConstraintType_sizeOffset) {
        if (self.targets.count) [description appendString:@"."];
        [description appendFormat:@"size(%@)", NSStringFromCGSize(self.sizeOffset)];
    }
    return description;
}

@end

#pragma mark - LWConstraintMakerRef

#define LWConstraintMakerCast(MAKER, CLASS) ({                                                                                                                    \
    CLASS *maker = lw_as(MAKER, CLASS) ?: [CLASS makerWithConstraint:MAKER.constraint];                                                                           \
    if ((id)maker != (id)MAKER) MAKER.constraint = nil; /* supports `lw_install` for multiple `make...` in `lw_makeConstraints:` and `lw_updateConstraints:` */ \
    maker;                                                                                                                                                         \
})

@implementation LWConstraintMakerRef

@synthesize constraint = _constraint;
- (LWConstraint *)constraint {
    return _constraint ?: (_constraint = [LWConstraint new]);
}

+ (instancetype)makerWithConstraint:(LWConstraint *)constraint {
    LWConstraintMakerRef *maker = [self new];
    maker.constraint = constraint;
    return maker;
}

- (LWConstraint * (^)(void))install {
    return ^LWConstraint *(void) {
        [self.constraint install];
        return self.constraint;
    };
}

- (LWConstraint * (^)(void))uninstall {
    return ^LWConstraint *(void) {
        [self.constraint uninstall];
        return self.constraint;
    };
}

- (instancetype)and {
    return self;
}
- (instancetype)with {
    return self;
}

@end

#pragma mark - LWConstraintMetaMaker

@implementation LWConstraintMetaMaker

- (LWConstraintMetaMaker * (^)(BOOL))shouldBeArchived {
    return ^LWConstraintMetaMaker *(BOOL shouldBeArchived) {
        self.constraint.shouldBeArchived = shouldBeArchived;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}

- (LWConstraintMetaMaker * (^)(NSString *))identifier {
    return ^LWConstraintMetaMaker *(NSString *identifier) {
        self.constraint.identifier = identifier;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}

- (LWConstraintMetaMaker * (^)(UILayoutPriority priority))priority {
    return ^LWConstraintMetaMaker *(UILayoutPriority priority) {
        self.constraint.priority = priority;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}
- (LWConstraintMetaMaker * (^)(void))setPriority:(UILayoutPriority)priority {
    return ^LWConstraintMetaMaker *(void) {
        self.constraint.priority = priority;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}
- (LWConstraintMetaMaker * (^)(void))required {
    return [self setPriority:UILayoutPriorityRequired];
}
- (LWConstraintMetaMaker * (^)(void))defaultHigh {
    return [self setPriority:UILayoutPriorityDefaultHigh];
}
- (LWConstraintMetaMaker * (^)(void))defaultLow {
    return [self setPriority:UILayoutPriorityDefaultLow];
}
- (LWConstraintMetaMaker * (^)(void))fittingSizeLevel {
    return [self setPriority:UILayoutPriorityFittingSizeLevel];
}

- (LWConstraintMetaMaker *)setActive:(BOOL)active {
    self.constraint.active = active;
    return LWConstraintMakerCast(self, LWConstraintMetaMaker);
}
- (LWConstraintMetaMaker * (^)(BOOL))active {
    return ^LWConstraintMetaMaker *(BOOL active) {
        return [self setActive:active];
    };
}
- (LWConstraintMetaMaker * (^)(void))activate {
    return ^LWConstraintMetaMaker *(void) {
        return [self setActive:YES];
    };
}
- (LWConstraintMetaMaker * (^)(void))deactivate {
    return ^LWConstraintMetaMaker *(void) {
        return [self setActive:NO];
    };
}

@end

#pragma mark - LWConstraintConstantMaker

@implementation LWConstraintConstantMaker

- (LWConstraintMetaMaker * (^)(CGFloat))constant {
    return ^LWConstraintMetaMaker *(CGFloat constant) {
        self.constraint.constant = constant;
        self.constraint.constantType = LWConstraintType_constant;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}
- (LWConstraintMetaMaker * (^)(CGFloat))offset {
    return self.constant;
}

- (LWConstraintMetaMaker * (^)(UIEdgeInsets))insets {
    return ^LWConstraintMetaMaker *(UIEdgeInsets insets) {
        self.constraint.insets = insets;
        self.constraint.constantType = LWConstraintType_insets;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}
- (LWConstraintMetaMaker * (^)(CGFloat))inset {
    return ^LWConstraintMetaMaker *(CGFloat inset) {
        self.constraint.insets = UIEdgeInsetsMake(inset, inset, inset, inset);
        self.constraint.constantType = LWConstraintType_insets;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}
- (LWConstraintMetaMaker * (^)(CGPoint))centerOffset {
    return ^LWConstraintMetaMaker *(CGPoint centerOffset) {
        self.constraint.centerOffset = centerOffset;
        self.constraint.constantType = LWConstraintType_centerOffset;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}
- (LWConstraintMetaMaker * (^)(CGSize))sizeOffset {
    return ^LWConstraintMetaMaker *(CGSize sizeOffset) {
        self.constraint.sizeOffset = sizeOffset;
        self.constraint.constantType = LWConstraintType_sizeOffset;
        return LWConstraintMakerCast(self, LWConstraintMetaMaker);
    };
}

@end

#pragma mark - LWConstraintMultiplierMaker

@implementation LWConstraintMultiplierMaker

- (LWConstraintConstantMaker * (^)(CGFloat))multipliedBy {
    return ^LWConstraintConstantMaker *(CGFloat multiplier) {
        self.constraint.multiplier = multiplier;
        return LWConstraintMakerCast(self, LWConstraintConstantMaker);
    };
}

- (LWConstraintConstantMaker * (^)(CGFloat))dividedBy {
    return ^LWConstraintConstantMaker *(CGFloat divider) {
        self.constraint.multiplier = 1.0 / divider;
        return LWConstraintMakerCast(self, LWConstraintConstantMaker);
    };
}

@end

#pragma mark - LWConstraintTargetMaker

@implementation LWConstraintTargetMaker

- (void)addTarget:(id)_target {
    LWConstraintTarget *target = (lw_as(_target, LWConstraintTarget)
                                       ?: [LWConstraintTarget targetWithObject:_target]);
    [self.constraint.targets addObject:target];
}

- (LWConstraintMultiplierMaker * (^)(id _Nullable))to {
    return ^LWConstraintMultiplierMaker *(id _Nullable target) {
        NSArray *targets = lw_as(target, NSArray);
        if (targets) {
            for (id target in targets) {
                [self addTarget:target];
            }
        }
        else {
            [self addTarget:target];
        }
        return LWConstraintMakerCast(self, LWConstraintMultiplierMaker);
    };
}

- (LWConstraintMultiplierMaker * (^)(id _Nullable, ...))toTargets {
    return ^LWConstraintMultiplierMaker *(id _Nullable first, ...) {
        lw_va_each(id, first, nil, ^(id target) {
            [self addTarget:target];
        });
        return LWConstraintMakerCast(self, LWConstraintMultiplierMaker);
    };
}

@end

#pragma mark - LWConstraintRelationMaker

@interface LWConstraintRelationMaker ()
- (LWConstraintTargetMaker *)setRelation:(NSLayoutRelation)relation;
@end

@implementation LWConstraintRelationMaker

- (LWConstraintTargetMaker *)setRelation:(NSLayoutRelation)relation {
    self.constraint.relation = relation;
    [self.constraint addToView]; // supports multiple `lw_install` for `make...` in `lw_makeConstraints:`
    return LWConstraintMakerCast(self, LWConstraintTargetMaker);
}

- (LWConstraintTargetMaker * (^)(NSLayoutRelation))relation {
    return ^LWConstraintTargetMaker *(NSLayoutRelation relation) {
        return [self setRelation:relation];
    };
}
- (LWConstraintTargetMaker *)equal {
    return [self setRelation:NSLayoutRelationEqual];
}
- (LWConstraintTargetMaker *)lessThanOrEqual {
    return [self setRelation:NSLayoutRelationLessThanOrEqual];
}
- (LWConstraintTargetMaker *)greaterThanOrEqual {
    return [self setRelation:NSLayoutRelationGreaterThanOrEqual];
}

@end

#pragma mark - LWConstraintAttributesMaker

@implementation LWConstraintAttributesMaker

- (LWConstraintTargetMaker *)setRelation:(NSLayoutRelation)relation {
    if (!self.constraint.attributes.count) {
        /* NO return */ [self edges];
    }
    return [super setRelation:relation];
}

- (LWConstraintRelationMaker * (^)(NSLayoutAttribute, ...))attributes {
    return ^LWConstraintRelationMaker *(NSLayoutAttribute first, ...) {
        lw_va_each(NSLayoutAttribute, first, NSLayoutAttributeNotAnAttribute, ^(NSLayoutAttribute attribute) {
            [self.constraint.attributes addObject:@(attribute)];
        });
        return LWConstraintMakerCast(self, LWConstraintRelationMaker);
    };
}

#define lw_addAttribute(SEL, ATTR)                     \
    -(LWConstraintAttributesMaker *)SEL {              \
        [self.constraint.attributes addObject:@(ATTR)]; \
        return self;                                    \
    }
lw_addAttribute(left, NSLayoutAttributeLeft);
lw_addAttribute(right, NSLayoutAttributeRight);
lw_addAttribute(top, NSLayoutAttributeTop);
lw_addAttribute(bottom, NSLayoutAttributeBottom);
lw_addAttribute(leading, NSLayoutAttributeLeading);
lw_addAttribute(trailing, NSLayoutAttributeTrailing);
lw_addAttribute(width, NSLayoutAttributeWidth);
lw_addAttribute(height, NSLayoutAttributeHeight);
lw_addAttribute(centerX, NSLayoutAttributeCenterX);
lw_addAttribute(centerY, NSLayoutAttributeCenterY);
lw_addAttribute(firstBaseline, NSLayoutAttributeFirstBaseline);
lw_addAttribute(lastBaseline, NSLayoutAttributeLastBaseline);
lw_addAttribute(leftMargin, NSLayoutAttributeLeftMargin);
lw_addAttribute(rightMargin, NSLayoutAttributeRightMargin);
lw_addAttribute(topMargin, NSLayoutAttributeTopMargin);
lw_addAttribute(bottomMargin, NSLayoutAttributeBottomMargin);
lw_addAttribute(leadingMargin, NSLayoutAttributeLeadingMargin);
lw_addAttribute(trailingMargin, NSLayoutAttributeTrailingMargin);
lw_addAttribute(centerXWithinMargins, NSLayoutAttributeCenterXWithinMargins);
lw_addAttribute(centerYWithinMargins, NSLayoutAttributeCenterYWithinMargins);

- (LWConstraintAttributesMaker *)addAttributes:(NSLayoutAttribute)first, ... {
    lw_va_each(NSLayoutAttribute, first, NSLayoutAttributeNotAnAttribute, ^(NSLayoutAttribute attribute) {
        [self.constraint.attributes addObject:@(attribute)];
    });
    return self;
}
- (LWConstraintAttributesMaker *)edges {
    return [self addAttributes:NSLayoutAttributeTop, NSLayoutAttributeLeft, NSLayoutAttributeBottom, NSLayoutAttributeRight, NSLayoutAttributeNotAnAttribute];
}
- (LWConstraintAttributesMaker *)center {
    return [self addAttributes:NSLayoutAttributeCenterX, NSLayoutAttributeCenterY, NSLayoutAttributeNotAnAttribute];
}
- (LWConstraintAttributesMaker *)size {
    return [self addAttributes:NSLayoutAttributeWidth, NSLayoutAttributeHeight, NSLayoutAttributeNotAnAttribute];
}

@end

#pragma mark - LWConstraintMaker

@implementation LWConstraintMaker

- (LWConstraintAttributesMaker *)replaceSimilar {
    [self.constraint prepareForReplace];
    self.constraint.needsReplace = YES;
    self.constraint.needsUpdate = NO;
    return LWConstraintMakerCast(self, LWConstraintAttributesMaker);
}

- (LWConstraintAttributesMaker *)updateExisting {
    self.constraint.needsReplace = NO;
    self.constraint.needsUpdate = YES;
    return LWConstraintMakerCast(self, LWConstraintAttributesMaker);
}

@end

#pragma mark - LWConstraintMultipleMaker

@interface LWConstraintMultipleMaker: LWConstraintMaker

@property (nonatomic, weak) UIView *view; // nil, supports `lw_install` for multiple `make...` in `lw_makeConstraints:` and `lw_updateConstraints:`
@property (nonatomic) BOOL needsUpdate; // NO, supports `lw_install` for multiple `make...` in `lw_updateConstraints:`

@end

@implementation LWConstraintMultipleMaker

- (LWConstraint *)constraint {
    LWConstraint *constraint = [super constraint];
    if (!constraint.view) {
        constraint.view = self.view;
        constraint.needsUpdate = self.needsUpdate;
    }
    return constraint;
}

@end

#pragma mark - LWLayoutAttribute

#define lw_attribute(SEL, OBJ, ATTR)                                     \
    -(LWConstraintTarget *)SEL {                                         \
        return [LWConstraintTarget targetWithObject:OBJ attribute:ATTR]; \
    }

@interface NSObject (LWLayoutAttribute) <LWLayoutGuide, LWLayoutAttribute>
@end
@implementation NSObject (LWLayoutAttribute)
// LWLayoutGuide
lw_attribute(lw_left, self, NSLayoutAttributeLeft);
lw_attribute(lw_right, self, NSLayoutAttributeRight);
lw_attribute(lw_top, self, NSLayoutAttributeTop);
lw_attribute(lw_bottom, self, NSLayoutAttributeBottom);
lw_attribute(lw_leading, self, NSLayoutAttributeLeading);
lw_attribute(lw_trailing, self, NSLayoutAttributeTrailing);
lw_attribute(lw_width, self, NSLayoutAttributeWidth);
lw_attribute(lw_height, self, NSLayoutAttributeHeight);
lw_attribute(lw_centerX, self, NSLayoutAttributeCenterX);
lw_attribute(lw_centerY, self, NSLayoutAttributeCenterY);
// LWLayoutAttribute
lw_attribute(lw_firstBaseline, self, NSLayoutAttributeFirstBaseline);
lw_attribute(lw_lastBaseline, self, NSLayoutAttributeLastBaseline);
lw_attribute(lw_leftMargin, self, NSLayoutAttributeLeftMargin);
lw_attribute(lw_rightMargin, self, NSLayoutAttributeRightMargin);
lw_attribute(lw_topMargin, self, NSLayoutAttributeTopMargin);
lw_attribute(lw_bottomMargin, self, NSLayoutAttributeBottomMargin);
lw_attribute(lw_leadingMargin, self, NSLayoutAttributeLeadingMargin);
lw_attribute(lw_trailingMargin, self, NSLayoutAttributeTrailingMargin);
lw_attribute(lw_centerXWithinMargins, self, NSLayoutAttributeCenterXWithinMargins);
lw_attribute(lw_centerYWithinMargins, self, NSLayoutAttributeCenterYWithinMargins);
@end

@implementation UILayoutGuide (LWLayoutAttribute)
@end

@implementation UIView (LWLayoutAttribute)
- (UILayoutGuide *)lw_safeAreaLayoutGuide {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaLayoutGuide;
    }
    return nil;
}
@end

@implementation UIScrollView (LWLayoutAttribute)
- (UILayoutGuide *)lw_contentLayoutGuide {
    if (@available(iOS 11.0, *)) {
        return self.contentLayoutGuide;
    }
    return nil;
}
- (UILayoutGuide *)lw_frameLayoutGuide {
    if (@available(iOS 11.0, *)) {
        return self.frameLayoutGuide;
    }
    return nil;
}
@end

#pragma mark - UIView (LWAutolayout)

@implementation UIView (LWAutolayout)

- (LWConstraintMaker *)lw_make {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    LWConstraintMaker *maker = [LWConstraintMaker new];
    maker.constraint.view = self;
    return maker;
}

- (void)lw_install {
    for (LWConstraint *constraint in [self.lw_constraints copy]) {
        if (/* !constraint.nsConstraints
            || constraint.needsReplace
            || constraint.needsUpdate
            || */
            constraint.needsInstall) {
            // maybe removed by other [constraint install]
            if ([self.lw_constraints containsObject:constraint]) {
                [constraint install];
            }
        }
    }
}

- (void)lw_makeConstraints:(void(NS_NOESCAPE ^)(LWConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (!block) return;
    LWConstraintMultipleMaker *make = [LWConstraintMultipleMaker new];
    make.view = self;
    block(make);
    [self lw_install];
}
- (void)lw_updateConstraints:(void(NS_NOESCAPE ^)(LWConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    if (!block) return;
    LWConstraintMultipleMaker *make = [LWConstraintMultipleMaker new];
    make.view = self;
    make.needsUpdate = YES;
    block(make);
    [self lw_install];
}
- (void)lw_remakeConstraints:(void(NS_NOESCAPE ^)(LWConstraintMaker *make))block {
    [self lw_uninstallConstraints];
    [self lw_makeConstraints:block];
}
- (void)lw_uninstallConstraints {
    [[self.lw_constraints copy] makeObjectsPerformSelector:@selector(uninstall)];
    self.lw_constraints = nil;
}

// #see https://stackoverflow.com/a/30491911/456536
- (void)lw_removeAllConstraints {
    UIView *superview = self;
    while ((superview = superview.superview)) {
        for (NSLayoutConstraint *nsConstraint in superview.constraints) {
            if (nsConstraint.firstItem == self || nsConstraint.secondItem == self) {
                [superview removeConstraint:nsConstraint];
            }
        }
    }
    [self removeConstraints:self.constraints];
}

@end

#pragma mark - Masonry

@implementation LWConstraintMetaMaker (MasonryCompatible)
- (LWConstraintMetaMaker * (^)(void))priorityLow {
    return [self setPriority:UILayoutPriorityDefaultLow];
}
- (LWConstraintMetaMaker * (^)(void))priorityMedium {
    return [self setPriority:(UILayoutPriority)500];
}
- (LWConstraintMetaMaker * (^)(void))priorityHigh {
    return [self setPriority:UILayoutPriorityDefaultHigh];
}
@end

@implementation LWConstraintRelationMaker (MasonryCompatible)
- (LWConstraintMultiplierMaker * (^)(id _Nullable))equalTo {
    return self.equal.to;
}
- (LWConstraintMultiplierMaker * (^)(id _Nullable))lessThanOrEqualTo {
    return self.lessThanOrEqual.to;
}
- (LWConstraintMultiplierMaker * (^)(id _Nullable))greaterThanOrEqualTo {
    return self.greaterThanOrEqual.to;
}
@end

#pragma mark - LWContentMode

#define LWContentMakerCast(MAKER, CLASS) ({                     \
    lw_as(MAKER, CLASS) ?: [CLASS makerByCopyingAnother:MAKER]; \
})

@interface LWContentMakerRef ()
@property (nonatomic, weak, nullable) UIView *view;
@property (nonatomic) BOOL hasHorizontal, hasVertical; // UILayoutConstraintAxis
@property (nonatomic) BOOL hasHugging, hasCompressionResistance;
+ (instancetype)makerByCopyingAnother:(LWContentMakerRef *)another;
@end

@implementation LWContentMakerRef
+ (instancetype)makerByCopyingAnother:(LWContentMakerRef *)another {
    LWContentMakerRef *maker = [self new];
    maker.view = another.view;
    maker.hasHorizontal = another.hasHorizontal;
    maker.hasVertical = another.hasVertical;
    maker.hasHugging = another.hasHugging;
    maker.hasCompressionResistance = another.hasCompressionResistance;
    return maker;
}
@end

@implementation LWContentPriorityMaker
- (void)finishWithPriority:(UILayoutPriority)priority {
    if (self.hasHugging) {
        if (self.hasHorizontal) [self.view setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisHorizontal];
        if (self.hasVertical) [self.view setContentHuggingPriority:priority forAxis:UILayoutConstraintAxisVertical];
    }
    if (self.hasCompressionResistance) {
        if (self.hasHorizontal) [self.view setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisHorizontal];
        if (self.hasVertical) [self.view setContentCompressionResistancePriority:priority forAxis:UILayoutConstraintAxisVertical];
    }
}
- (void (^)(UILayoutPriority priority))priority {
    return ^void(UILayoutPriority priority) {
        [self finishWithPriority:priority];
    };
}
- (void (^)(void))setPriority:(UILayoutPriority)priority {
    return ^void(void) {
        [self finishWithPriority:priority];
    };
}
- (void (^)(void))required {
    return [self setPriority:UILayoutPriorityRequired];
}
- (void (^)(void))defaultHigh {
    return [self setPriority:UILayoutPriorityDefaultHigh];
}
- (void (^)(void))defaultLow {
    return [self setPriority:UILayoutPriorityDefaultLow];
}
- (void (^)(void))fittingSizeLevel {
    return [self setPriority:UILayoutPriorityFittingSizeLevel];
}
@end

@implementation LWContentPriorityModeMaker
- (LWContentPriorityModeMaker *)hugging {
    self.hasHugging = YES;
    return self;
}
- (LWContentPriorityModeMaker *)compressionResistance {
    self.hasCompressionResistance = YES;
    return self;
}
@end

@implementation LWContentModeMaker
- (LWContentPriorityModeMaker *)hugging {
    self.hasHugging = YES;
    return LWContentMakerCast(self, LWContentPriorityModeMaker);
}
- (LWContentPriorityModeMaker *)compressionResistance {
    self.hasCompressionResistance = YES;
    return LWContentMakerCast(self, LWContentPriorityModeMaker);
}
@end

@implementation LWContentAxisMaker
- (LWContentAxisMaker *)horizontal {
    self.hasHorizontal = YES;
    return self;
}
- (LWContentAxisMaker *)vertical {
    self.hasVertical = YES;
    return self;
}
@end

@implementation LWConstraintAttributesMaker (LWContentMode)
- (LWContentAxisMaker *)contentAxisMaker {
    LWContentAxisMaker *maker = [LWContentAxisMaker new];
    maker.view = self.constraint.view;
    return maker;
}
- (LWContentAxisMaker *)horizontal {
    LWContentAxisMaker *maker = [self contentAxisMaker];
    maker.hasHorizontal = YES;
    return maker;
}
- (LWContentAxisMaker *)vertical {
    LWContentAxisMaker *maker = [self contentAxisMaker];
    maker.hasVertical = YES;
    return maker;
}
- (LWContentPriorityModeMaker *)contentModePriorityMaker {
    LWContentPriorityModeMaker *maker = [LWContentPriorityModeMaker new];
    maker.view = self.constraint.view;
    maker.hasHorizontal = maker.hasVertical = YES;
    return maker;
}
- (LWContentPriorityModeMaker *)hugging {
    LWContentPriorityModeMaker *maker = [self contentModePriorityMaker];
    maker.hasHugging = YES;
    return maker;
}
- (LWContentPriorityModeMaker *)compressionResistance {
    LWContentPriorityModeMaker *maker = [self contentModePriorityMaker];
    maker.hasCompressionResistance = YES;
    return maker;
}
@end
