//
//  UINavigationController+JRJSliding.h
//  JRJSlidingNavigationBar
//
//  Created by jian on 15/11/25.
//  Copyright © 2015年 jian. All rights reserved.
//

#import <UIKit/UIKit.h>

// 导航栏背景视图 隐藏/显示 动画持续时间
UIKIT_EXTERN const CGFloat kJRJSlidingNavigationBarBackgroundHideShowBarDuration;

// 方法调度/IMP(方法实现)交换
OBJC_EXPORT  void jrj_methodSwizzling(Class class, SEL originalSelector, SEL swizzledSelector);

@interface UINavigationController (JRJSliding)

- (BOOL)isJrj_navigationBarBackgroundHidden;

- (void)jrj_setNavigationBarBackgroundHidden:(BOOL)backgroundHidden animated:(BOOL)animated;

@end

@interface UIViewController(JRJSliding)

// Defaults to NO
- (BOOL)jrj_prefersNavigationBarBackgroundHidden;

@end
