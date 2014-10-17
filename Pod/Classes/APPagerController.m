//
//  APPagerController.m
//  Pods
//
//  Created by Anthony Powles on 10/17/14.
//
//

#import "APPagerController.h"

@interface APPagerController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIScrollView *titleScrollView;

@property (nonatomic, strong) NSMutableArray *pageViewControllers;
@property (nonatomic, strong) NSMutableArray *titleViews;

@property (nonatomic) NSUInteger titleSpacing;

@property (nonatomic, strong) NSMutableArray *pageOffsetPoints;
@property (nonatomic, strong) NSMutableArray *pageCenterPoints;
@property (nonatomic, strong) NSMutableArray *titleCenterPoints;
@property (nonatomic) NSUInteger currentPageIndex;

@end

@implementation APPagerController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    [self setupPager];
    [self reloadData];
    [self setupPagerContent];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - View Setup

- (void)setupPager
{
    _pageScrollView.backgroundColor = [UIColor darkGrayColor];
    _titleSpacing = 20;
}

- (void)reloadData
{
    _pageViewControllers = [[NSMutableArray alloc] init];
    _titleViews = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < [self.dataSource numberOfPagesForPager:self]; ++i) {
        // Get child controller from dataSource
        UIViewController *vc = [self.dataSource pageControllerForPager:self atIndex:i];
        [self.pageViewControllers addObject:vc];
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        
        // Get title view from dataSource
        [self.titleViews addObject:[self.dataSource titleViewForPager:self atIndex:i]];
    }
}

- (void)setupPagerContent
{
    CGRect frame = self.view.frame;
    
    // content
    
    _pageOffsetPoints = [[NSMutableArray alloc] init];
    _pageCenterPoints = [[NSMutableArray alloc] init];

    _pageScrollView = [[UIScrollView alloc] initWithFrame:frame];
    _pageScrollView.delegate = self;
    [_pageScrollView setPagingEnabled:YES];
    [_pageScrollView setShowsVerticalScrollIndicator:NO];
    [_pageScrollView setShowsHorizontalScrollIndicator:NO];
    [_pageScrollView setContentSize:CGSizeMake(frame.size.width * [self.pageViewControllers count], frame.size.height)];
    
    [_pageViewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
        vc.view.frame = CGRectOffset(frame, frame.size.width * idx, 0);
        [_pageScrollView addSubview:vc.view];
        [_pageOffsetPoints addObject:[NSValue valueWithCGPoint:vc.view.frame.origin]];
        [_pageCenterPoints addObject:[NSValue valueWithCGPoint:vc.view.center]];
    }];
    
    [self.view addSubview:_pageScrollView];
    
    // titles
    
    _titleCenterPoints = [[NSMutableArray alloc] init];

    _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(frame), 48)];
    _titleScrollView.delegate = self;
    _titleScrollView.backgroundColor = [UIColor colorWithWhite:.5 alpha:.8];
    [_titleScrollView setPagingEnabled:NO];
    [_titleScrollView setShowsVerticalScrollIndicator:NO];
    [_titleScrollView setShowsHorizontalScrollIndicator:NO];
    //    [_titleScrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    
    __block CGFloat titlePosX = 0;
    
    [_titleViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        CGFloat width = ceilf([self.dataSource titleViewWidthForPager:self atIndex:idx]);
        
        if (titlePosX == 0) {
            titlePosX = ceilf(_titleScrollView.center.x - width / 2);
        }
        
        view.frame = CGRectMake(titlePosX, 17, width, 24);
        
        [_titleCenterPoints addObject:[NSValue valueWithCGPoint:view.center]];
        [_titleScrollView addSubview:view];
        
        titlePosX += width + _titleSpacing;
        
        if (idx == _titleViews.count - 1) {
            titlePosX -= width / 2;
            titlePosX -= _titleSpacing;
            titlePosX += _titleScrollView.center.x;
        }
    }];
    
    [_titleScrollView setContentSize:CGSizeMake(titlePosX, 48)];
    [self.view addSubview:_titleScrollView];
    
    NSLog(@"titleCenterPoints: %@", _titleCenterPoints);
    NSLog(@"pageOffsetPoints: %@", _pageOffsetPoints);
    NSLog(@"pageCenterPoints: %@", _pageCenterPoints);
    
    self.currentPageIndex = 0;
}

@end
