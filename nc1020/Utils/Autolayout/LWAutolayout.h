//
//  LWAutolayout.h
//
//  Created by lw0717 on 2018-10-12.
//  Copyright (c) 2018 lw0717. Released under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  item1.attr1 == [item2.attr2 [× multiplier]] + constant
 */

/*
@interface LWAutolayout: NSObject
@end // */

@class LWConstraintAttributesMaker, LWConstraintConstantMaker;

#pragma mark - LWConstraint

@interface LWConstraint: NSObject
@property (nonatomic, readonly) LWConstraintAttributesMaker *replace;
@property (nonatomic, readonly) LWConstraintConstantMaker *update;
- (void)install;
- (void)uninstall;
@end

#pragma mark - LWConstraintTarget

@interface LWConstraintTarget: NSObject
@property (nonatomic, readonly, weak, nullable) id object; // nil
@property (nonatomic, readonly) NSLayoutAttribute attribute; // NSLayoutAttributeNotAnAttribute
@property (nonatomic, readonly, nullable) NSNumber *number; // nil
+ (instancetype)targetWithObject:(nullable id)object;
+ (instancetype)targetWithObject:(nullable id)object attribute:(NSLayoutAttribute)attribute;
@end

#pragma mark - LWConstraintMaker

@interface LWConstraintMakerRef: NSObject
@property (nonatomic, readonly) LWConstraint *constraint;
@property (nonatomic, readonly) LWConstraint * (^install)(void);
@property (nonatomic, readonly) LWConstraint * (^uninstall)(void);
- (instancetype)and;
- (instancetype)with;
@end

@interface LWConstraintMetaMaker: LWConstraintMakerRef
@property (nonatomic, readonly) LWConstraintMetaMaker * (^shouldBeArchived)(BOOL shouldBeArchived); // NO
@property (nonatomic, readonly) LWConstraintMetaMaker * (^identifier)(NSString *identifier); // nil
@property (nonatomic, readonly) LWConstraintMetaMaker * (^priority)(UILayoutPriority priority); // UILayoutPriorityRequired
@property (nonatomic, readonly) LWConstraintMetaMaker * (^required)(void);
@property (nonatomic, readonly) LWConstraintMetaMaker * (^defaultHigh)(void);
@property (nonatomic, readonly) LWConstraintMetaMaker * (^defaultLow)(void);
@property (nonatomic, readonly) LWConstraintMetaMaker * (^fittingSizeLevel)(void);
@property (nonatomic, readonly) LWConstraintMetaMaker * (^active)(BOOL active); // YES
@property (nonatomic, readonly) LWConstraintMetaMaker * (^activate)(void);
@property (nonatomic, readonly) LWConstraintMetaMaker * (^deactivate)(void);
@end

@interface LWConstraintConstantMaker: LWConstraintMetaMaker
@property (nonatomic, readonly) LWConstraintMetaMaker * (^constant)(CGFloat constant); // 0.0
@property (nonatomic, readonly) LWConstraintMetaMaker * (^offset)(CGFloat offset);
@property (nonatomic, readonly) LWConstraintMetaMaker * (^insets)(UIEdgeInsets insets); // insets from target
@property (nonatomic, readonly) LWConstraintMetaMaker * (^inset)(CGFloat inset); // inset from target.attribute
@property (nonatomic, readonly) LWConstraintMetaMaker * (^centerOffset)(CGPoint centerOffset);
@property (nonatomic, readonly) LWConstraintMetaMaker * (^sizeOffset)(CGSize sizeOffset);
@end

@interface LWConstraintMultiplierMaker: LWConstraintConstantMaker
@property (nonatomic, readonly) LWConstraintConstantMaker * (^multipliedBy)(CGFloat multiplier); // 1.0
@property (nonatomic, readonly) LWConstraintConstantMaker * (^dividedBy)(CGFloat divider); // multiplier = 1.0 / divider
@end
@interface LWConstraintTargetMaker: LWConstraintConstantMaker
@property (nonatomic, readonly) LWConstraintMultiplierMaker * (^to)(id _Nullable target); // nil, accepts NSNumber and NSArray
@property (nonatomic, readonly) LWConstraintMultiplierMaker * (^toTargets)(id _Nullable target, ...); // NS_REQUIRES_NIL_TERMINATION, nil, accepts NSNumber
@end

@interface LWConstraintRelationMaker: LWConstraintMakerRef
@property (nonatomic, readonly) LWConstraintTargetMaker * (^relation)(NSLayoutRelation relation); // NSLayoutRelationEqual
@property (nonatomic, readonly) LWConstraintTargetMaker *equal, *lessThanOrEqual, *greaterThanOrEqual;
@end

@interface LWConstraintAttributesMaker: LWConstraintRelationMaker
@property (nonatomic, readonly) LWConstraintRelationMaker * (^attributes)(NSLayoutAttribute first, ...); // edges
@property (nonatomic, readonly) LWConstraintAttributesMaker
    *left,
    *right, *top, *bottom, *leading, *trailing,
    *width, *height, *centerX, *centerY,
    *firstBaseline, *lastBaseline,
    *leftMargin, *rightMargin, *topMargin, *bottomMargin, *leadingMargin, *trailingMargin,
    *centerXWithinMargins, *centerYWithinMargins;
@property (nonatomic, readonly) LWConstraintAttributesMaker
    *edges,
    *center, *size;
@end

@interface LWConstraintMaker: LWConstraintAttributesMaker
@property (nonatomic, readonly) LWConstraintAttributesMaker
    *replaceSimilar, // `replace` if has same view, attributes, relation
    *updateExisting; // for each attribute, `update`  if has same view, relation, target+attribute-s, multiplier
@end

#pragma mark - LWLayoutAttribute

@protocol LWLayoutGuide <NSObject>
@property (nonatomic, readonly) LWConstraintTarget
    *lw_left,
    *lw_right, *lw_top, *lw_bottom, *lw_leading, *lw_trailing,
    *lw_width, *lw_height, *lw_centerX, *lw_centerY;
@end

@protocol LWLayoutAttribute <LWLayoutGuide>
@property (nonatomic, readonly) LWConstraintTarget
    *lw_firstBaseline,
    *lw_lastBaseline,
    *lw_leftMargin, *lw_rightMargin, *lw_topMargin, *lw_bottomMargin, *lw_leadingMargin, *lw_trailingMargin,
    *lw_centerXWithinMargins, *lw_centerYWithinMargins;
@end

@interface UILayoutGuide (LWLayoutAttribute) <LWLayoutGuide>
@end

@interface UIView (LWLayoutAttribute) <LWLayoutGuide, LWLayoutAttribute>
@property (nonatomic, readonly, nullable) UILayoutGuide *lw_safeAreaLayoutGuide;
@end

@interface UIScrollView (LWLayoutAttribute)
@property (nonatomic, readonly, nullable) UILayoutGuide *lw_contentLayoutGuide, *lw_frameLayoutGuide;
@end

#pragma mark - LWAutolayout

@interface UIView (LWAutolayout)
@property (nonatomic, readonly) LWConstraintMaker *lw_make __APPLE_API_UNSTABLE;
// - (void)lw_install __APPLE_API_UNSTABLE;
- (void)lw_makeConstraints:(void(NS_NOESCAPE ^)(LWConstraintMaker *make))block;
- (void)lw_updateConstraints:(void(NS_NOESCAPE ^)(LWConstraintMaker *make))block;
- (void)lw_remakeConstraints:(void(NS_NOESCAPE ^)(LWConstraintMaker *make))block; // uninstall & make
- (void)lw_uninstallConstraints; // only LWConstraint
- (void)lw_removeAllConstraints; // include NSLayoutConstraint
@end

#pragma mark - MasonryCompatible

@interface LWConstraintMetaMaker (MasonryCompatible)
@property (nonatomic, readonly) LWConstraintMetaMaker * (^priorityLow)(void)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) LWConstraintMetaMaker * (^priorityMedium)(void)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) LWConstraintMetaMaker * (^priorityHigh)(void)__APPLE_API_UNSTABLE;
@end

@interface LWConstraintRelationMaker (MasonryCompatible)
@property (nonatomic, readonly) LWConstraintMultiplierMaker * (^equalTo)(id _Nullable target)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) LWConstraintMultiplierMaker * (^lessThanOrEqualTo)(id _Nullable target)__APPLE_API_UNSTABLE;
@property (nonatomic, readonly) LWConstraintMultiplierMaker * (^greaterThanOrEqualTo)(id _Nullable target)__APPLE_API_UNSTABLE;
@end

#pragma mark - LWContentMode

@interface LWContentMakerRef: NSObject
@end

@interface LWContentPriorityMaker: LWContentMakerRef
@property (nonatomic, readonly) void (^priority)(UILayoutPriority priority); // UILayoutPriorityRequired
@property (nonatomic, readonly) void (^required)(void);
@property (nonatomic, readonly) void (^defaultHigh)(void);
@property (nonatomic, readonly) void (^defaultLow)(void);
@property (nonatomic, readonly) void (^fittingSizeLevel)(void);
@end

@interface LWContentPriorityModeMaker: LWContentPriorityMaker
@property (nonatomic, readonly) LWContentPriorityModeMaker
    *hugging,
    *compressionResistance;
@end

@interface LWContentModeMaker: LWContentMakerRef
@property (nonatomic, readonly) LWContentPriorityModeMaker
    *hugging,
    *compressionResistance;
@end

@interface LWContentAxisMaker: LWContentModeMaker
@property (nonatomic, readonly) LWContentAxisMaker
    *horizontal,
    *vertical;
@end

@interface LWConstraintAttributesMaker (LWContentMode)
@property (nonatomic, readonly) LWContentAxisMaker
    *horizontal,
    *vertical;
@property (nonatomic, readonly) LWContentPriorityModeMaker
    *hugging,
    *compressionResistance;
@end

// #pragma mark -
//
// static inline void LWMakeConstraint(UIView *aView, UIView *bView) {
//
//     /* REQUIRED: `install` for `lw_make` */
//     aView.lw_make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0).required().activate().install();
//
//     [aView lw_makeConstraints:^(LWConstraintMaker *make) {
//
//         /* OPTIONAL: `attributes` */
//         make/* <#.edges#> */.equal.to(bView).multipliedBy(1.0).constant(0.0);
//
//         /* REQUIRED: `relation` */
//         // make.left.right/* <#.equal#> */.to(bView).multipliedBy(1.0).constant(0.0);
//         // make.left.right/* <#.equal#> <#.to(bView)#> */.multipliedBy(1.0).constant(0.0);
//         // make.left.right/* <#.equal#> <#.to(bView)#> */.multipliedBy(1.0).constant(0.0);
//         // make.left.right/* <#.equal#> <#.to(bView)#> <#.multipliedBy(1.0)#> */.constant(0.0);
//
//         /* OPTIONAL: `to` */
//         make.left.right.equal/* <#.to(bView)#> <#.multipliedBy(1.0)#> */.constant(0.0);
//
//         /* REQUIRED: `multipliedBy` available only after `to` */
//         // make.left.right.equal/* <#.to(bView)#> */.multipliedBy(1.0).constant(0.0);
//
//         /* OPTIONAL: `attribute`, `multipliedBy`, `constant` after `to` */
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0);
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> */.constant(0.0);
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> <#.constant(0.0)#> */;
//         make.left.right.equal.to(bView).multipliedBy(1.0)/* <#.constant(0.0)#> */;
//
//         /* DEPRECATED: `make.left.right.equal;`, use `make.left.right.equal.constant(0.0);` */
//         // make.left.right.equal/* <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> */;
//
//         /* OPTIONAL: `priority`, `active` */
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0).required().activate();
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0)/* <#.required()#> */.activate();
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0).required()/* <#.activate()#> */;
//         make.left.right.equal.to(bView).multipliedBy(1.0).constant(0.0)/* <#.required()#> <#.activate()#> */;
//         make.left.right.equal.to(bView).multipliedBy(1.0)/* <#.constant(0.0)#> <#.required()#> <#.activate()#> */;
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> <#.constant(0.0)#> <#.required()#> <#.activate()#> */;
//         make.left.right.equal.to(bView)/* <#.multipliedBy(1.0)#> <#.constant(0.0)#> <#.required()#> <#.activate()#> */;
//         make.left.right.equal/* <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> <#.required()#> <#.activate()#> */.install();
//         /* REQUIRED: `priority`, `active` available only after `to` */
//         // make.left.right/* <#.equal#> <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> */.required().activate();
//         // make/* <#.left#> <#.right#> <#.equal#> <#.to(bView)#> <#.multipliedBy(1.0)#> <#.constant(0.0)#> */.required().activate();
//
//         /* OPTIONAL: `axes` */
//         make.horizontal.vertical.hugging.compressionResistance.required();
//         make.horizontal/* <#.vertical#> */.hugging.compressionResistance.required();
//         make/* <#.horizontal#> */.vertical.hugging.compressionResistance.required();
//         make/* <#.horizontal#> <#.vertical#> */.hugging.compressionResistance.required();
//         /* REQUIRED: `mode` */
//         make.hugging/* <#.compressionResistance#> */.required();
//         make/* <#.hugging#> */.compressionResistance.required();
//         // maker/* <#.hugging#> <#.compressionResistance#> */.required();
//         /* REQUIRED: `priority` */
//         // make.hugging.compressionResistance/* <#.required()#> */;
//
//     }];
// }

NS_ASSUME_NONNULL_END
