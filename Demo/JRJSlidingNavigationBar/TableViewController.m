//
//  TableViewController.m
//  JRJSlidingNavigationBar
//
//  Created by jian on 15/11/25.
//  Copyright © 2015年 jian. All rights reserved.
//

#import "TableViewController.h"
#import "UINavigationController+JRJSliding.h"

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.jpg"]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = imageView;
    self.tableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController jrj_setNavigationBarBackgroundHidden:self.tableView.contentOffset.y <= 500 animated:YES];
}

- (BOOL)jrj_prefersNavigationBarBackgroundHidden {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:.55];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = backgroundView;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class class = NSClassFromString(@"ViewController");
    [self.navigationController pushViewController:[class new] animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.navigationController jrj_setNavigationBarBackgroundHidden:scrollView.contentOffset.y <= 500 animated:YES];
}

@end
