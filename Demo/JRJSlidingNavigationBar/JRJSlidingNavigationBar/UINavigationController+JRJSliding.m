//
//  UINavigationController+JRJSliding.m
//  JRJSlidingNavigationBar
//
//  Created by jian on 15/11/25.
//  Copyright © 2015年 jian. All rights reserved.
//

#import "UINavigationController+JRJSliding.h"
#import <objc/runtime.h>

const CGFloat kJRJSlidingNavigationBarBackgroundHideShowBarDuration = 0.4f;

void jrj_methodSwizzling(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark -
#pragma mark -

typedef void (^_JRJViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (JRJSlidingPrivate)

@property (nonatomic, copy) _JRJViewControllerWillAppearInjectBlock jrj_willAppearInjectBlock;

@end

@implementation UIViewController (JRJSlidingPrivate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(jrj_viewWillAppear:);
        jrj_methodSwizzling(class, originalSelector, swizzledSelector);
    });
}

- (void)jrj_viewWillAppear:(BOOL)animated {
    [self jrj_viewWillAppear:animated];
    if (self.jrj_willAppearInjectBlock) {
        self.jrj_willAppearInjectBlock(self, animated);
    }
}

#pragma mark - Getter & Setter

- (_JRJViewControllerWillAppearInjectBlock)jrj_willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setJrj_willAppearInjectBlock:(_JRJViewControllerWillAppearInjectBlock)jrj_willAppearInjectBlock {
    objc_setAssociatedObject(self, @selector(jrj_willAppearInjectBlock), jrj_willAppearInjectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma mark -
#pragma mark -

@implementation UINavigationController (JRJSliding)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(pushViewController:animated:);
        SEL swizzledSelector = @selector(jrj_pushViewController:animated:);
        jrj_methodSwizzling(class, originalSelector, swizzledSelector);
    });
}

- (void)jrj_pushViewController:(UIViewController *)jrj_viewController animated:(BOOL)animated {

    __weak typeof(self) weakSelf = self;
    _JRJViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf jrj_setNavigationBarBackgroundHidden:viewController.jrj_prefersNavigationBarBackgroundHidden animated:YES];
    };
    
    if (!jrj_viewController.jrj_willAppearInjectBlock) {
        jrj_viewController.jrj_willAppearInjectBlock = block;
    }
    
    // 防止隐藏的 vc 没有设置block
    // 使用 SB 布局的导航控制器默认是不会走这个 pushViewController:animated:
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    
    if (disappearingViewController && !disappearingViewController.jrj_willAppearInjectBlock) {
        disappearingViewController.jrj_willAppearInjectBlock = block;
    }
    
    if (![self.viewControllers containsObject:jrj_viewController]) {
        [self jrj_pushViewController:jrj_viewController animated:animated];
    }
}

- (void)jrj_setNavigationBarBackgroundHidden:(BOOL)backgroundHidden animated:(BOOL)animated {
    
    if (!self.jrj_navigationBarBackgroundView) {
        // 为了防止让app审核拒绝
        Class UINavigationBarBackgroundClass = NSClassFromString([@"_" stringByAppendingString:@"UINavigationBarBackground"]);
        [self.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView *obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:UINavigationBarBackgroundClass]) {
                [self setJrj_navigationBarBackgroundView:obj];
                *stop = YES;
            }
        }];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (self.jrj_navigationBarBackgroundView.layer.opacity != backgroundHidden ? 0 : 1) {
        CABasicAnimation *ani = [self jrj_transparentAnimationWithAlpha:backgroundHidden ? 0.0f : 1.0f duration:animated ? kJRJSlidingNavigationBarBackgroundHideShowBarDuration : 0.0f];
        [self.jrj_navigationBarBackgroundView.layer addAnimation:ani forKey:nil];
    }
    
    [CATransaction commit];
}

#pragma mark - Getter & Setter

- (CABasicAnimation *)jrj_transparentAnimationWithAlpha:(CGFloat)alpha duration:(NSTimeInterval)duration {
    NSString *aniKey = @"opacity";
    [self.jrj_navigationBarBackgroundView.layer setValue:@(alpha) forKey:aniKey];
    
    CABasicAnimation *ani   = [CABasicAnimation animationWithKeyPath:aniKey];
    ani.fillMode            = kCAFillModeBoth;
    ani.duration            = duration;
    ani.fromValue           = [self.jrj_navigationBarBackgroundView.layer.presentationLayer valueForKey:aniKey];
    ani.toValue             = @(alpha);
    ani.removedOnCompletion = YES;
    return ani;
}

- (BOOL)isJrj_navigationBarBackgroundHidden {
    return self.jrj_navigationBarBackgroundView.layer.opacity == 0;
}

- (UIView *)jrj_navigationBarBackgroundView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setJrj_navigationBarBackgroundView:(UIView *)view {
    objc_setAssociatedObject(self, @selector(jrj_navigationBarBackgroundView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark -
#pragma mark -

@implementation UIViewController (JRJSliding)

- (BOOL)jrj_prefersNavigationBarBackgroundHidden {
    return NO;
}

@end
