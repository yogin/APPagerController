//
//  APViewController.m
//  APPagerController
//
//  Created by Anthony Powles on 10/17/2014.
//  Copyright (c) 2014 Anthony Powles. All rights reserved.
//

#import "APViewController.h"
#import <APPagerController/APPagerController.h>

@interface APViewController () <APPagerDataSource, APPagerDelegate>

@property (nonatomic, strong) NSArray *pageTitles;
@property (nonatomic, strong) APPagerController *pagerController;

@end

@implementation APViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _pageTitles = @[@"New!", @"Entertainment", @"Massage & Spa", @"Food", @"Shopping"];

    self.view.backgroundColor = [UIColor redColor];
    _pagerController = [[APPagerController alloc] init];
    _pagerController.delegate = self;
    _pagerController.dataSource = self;

    [self.view addSubview:_pagerController.view];
    [self addChildViewController:_pagerController];
    [_pagerController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - APPagerDataSource

- (NSUInteger)numberOfPagesForPager:(APPagerController *)source
{
    return [_pageTitles count];
}

- (UIViewController *)pageControllerForPager:(APPagerController *)source atIndex:(NSUInteger)index
{
    UIViewController *vc = [[UIViewController alloc] init];
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );               //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    
    vc.view.backgroundColor = [UIColor colorWithHue:hue
                                         saturation:saturation
                                         brightness:brightness
                                              alpha:1];
    
    return vc;
}

- (UIView *)titleViewForPager:(APPagerController *)source atIndex:(NSUInteger)index
{
    UILabel *label = [[UILabel alloc] init];
    label.text = _pageTitles[index];
    label.font = [UIFont systemFontOfSize:14];
    
    return label;
}

- (CGFloat)titleViewWidthForPager:(APPagerController *)source atIndex:(NSUInteger)index
{
    NSString *title = _pageTitles[index];
    CGRect textRect = [title boundingRectWithSize:CGSizeZero
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                          context:nil];
    
    return textRect.size.width;
}


#pragma mark - APPagerDelegate

@end
