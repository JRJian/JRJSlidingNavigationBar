//
//  ViewController.m
//  JRJSlidingNavigationBar
//
//  Created by jian on 15/11/25.
//  Copyright © 2015年 jian. All rights reserved.
//

#import "ViewController.h"
#import "UINavigationController+JRJSliding.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
}

- (void)tap {
    Class class = NSClassFromString(@"TableViewController");
    [self.navigationController pushViewController:[class new] animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
