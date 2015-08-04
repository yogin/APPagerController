//
//  APPagerController.m
//  Pods
//
//  Created by Anthony Powles on 10/17/14.
//
//

#import "APPagerController.h"

@interface APPagerController () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *pageViewControllers;
@property (nonatomic, strong) NSMutableArray *titleViews;

@property (nonatomic, strong) NSMutableArray *pageCenterPoints;
@property (nonatomic, strong) NSMutableArray *titleCenterPoints;

@property (nonatomic, strong) UITapGestureRecognizer *tapTitleGestureRecognizer;

@property (nonatomic) UIDeviceOrientation currentDeviceOrientation;

@end

@implementation APPagerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    _currentDeviceOrientation = [self deviceOrientation:[[UIDevice currentDevice] orientation]];
    [self moveToPageAtIndex:_defaultPageIndex animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    
    [self reloadData];
    [self setupDefaults];
    [self setupLayout];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
}

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Accessors

- (NSUInteger)numberOfPages
{
    return [_pageViewControllers count];
}

- (UIView *)viewForPageAtIndex:(NSUInteger)index
{
    return [_titleViews objectAtIndex:index];
}

- (UIViewController *)controllerForPageAtIndex:(NSUInteger)index
{
    return [_pageViewControllers objectAtIndex:index];
}

- (void)enumerateTitleAndPageWithBlock:(void (^)(UIView *title, UIViewController *page, NSUInteger index))block
{
    for (NSUInteger idx = 0; idx < [self numberOfPages]; ++idx) {
        UIView *titleView = [self viewForPageAtIndex:idx];
        UIViewController *pageController = [self controllerForPageAtIndex:idx];

        if (block) {
            block(titleView, pageController, idx);
        }
    }
}

#pragma mark - View Setup

- (void)setupDefaults
{
    _pageScrollView.backgroundColor = [UIColor darkGrayColor];
    _titleSpacing = _titleSpacing ? _titleSpacing : 20;
    _titleScrollViewHeight = _titleScrollViewHeight ? _titleScrollViewHeight : 48;
    _defaultPageIndex = _defaultPageIndex ? _defaultPageIndex : 0;
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
    
    [self setupLayout];
}

- (void)setupLayout
{
    CGRect frame = self.view.frame;
    
    // content
    
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
        [_pageCenterPoints addObject:[NSValue valueWithCGPoint:vc.view.center]];
    }];
    
    [self.view addSubview:_pageScrollView];
    
    // titles
    
    _titleCenterPoints = [[NSMutableArray alloc] init];

    _titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(frame), _titleScrollViewHeight)];
    _titleScrollView.delegate = self;
    _titleScrollView.backgroundColor = [UIColor colorWithWhite:.5 alpha:.8];
    [_titleScrollView setPagingEnabled:NO];
    [_titleScrollView setShowsVerticalScrollIndicator:NO];
    [_titleScrollView setShowsHorizontalScrollIndicator:NO];
    [_titleScrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    
    __block CGFloat titlePosX = 0;
    
    [_titleViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        CGRect frame = view.frame;
        
        if (frame.size.width == 0 && [self.dataSource respondsToSelector:@selector(titleViewWidthForPager:atIndex:)]) {
            frame.size.width = ceilf([self.dataSource titleViewWidthForPager:self atIndex:idx]);
        }
        
        if (frame.size.height == 0 && [self.dataSource respondsToSelector:@selector(titleViewHeightForPager:atIndex:)]) {
            frame.size.height = ceilf([self.dataSource titleViewHeightForPager:self atIndex:idx]);
        }
        
        if (frame.size.height == 0 || frame.size.width == 0) {
            [NSException raise:@"InvalidViewFrameSize" format:@"A view frame's size much have both a width and height greater than 0! The title view at index %lu has the following size %@", (unsigned long)idx, NSStringFromCGSize(frame.size)];
        }

        if (titlePosX == 0) {
            titlePosX = ceilf(_titleScrollView.center.x - frame.size.width / 2);
        }
        
        frame.origin = CGPointMake(titlePosX, (_titleScrollViewHeight - frame.size.height) / 2);
        view.frame = frame;
        
        [_titleCenterPoints addObject:[NSValue valueWithCGPoint:view.center]];
        [_titleScrollView addSubview:view];
        
        titlePosX += frame.size.width + _titleSpacing;
        
        if (idx == _titleViews.count - 1) {
            titlePosX -= frame.size.width / 2;
            titlePosX -= _titleSpacing;
            titlePosX += _titleScrollView.center.x;
        }
    }];

    // Add Tap gesture on title scrollView so we can change pages by simply tapping on a title
    _tapTitleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitleTap:)];
    [_titleScrollView addGestureRecognizer:_tapTitleGestureRecognizer];

    [_titleScrollView setContentSize:CGSizeMake(titlePosX, _titleScrollViewHeight)];
    [self.view addSubview:_titleScrollView];

    if ([self.delegate respondsToSelector:@selector(customizeLayoutForPagerController:)]) {
        [self.delegate customizeLayoutForPagerController:self];
    }
}

- (void)orientationChanged:(NSNotification *)notification
{
//    UIDeviceOrientation orientation = [self deviceOrientation:[[UIDevice currentDevice] orientation]];
//    if (_currentDeviceOrientation != orientation) {
//        _currentDeviceOrientation = orientation;
//        [self setupLayout];
//    }
}

- (UIDeviceOrientation)deviceOrientation:(UIDeviceOrientation)orientation
{
    if (orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationLandscapeLeft) {
        return orientation;
    }

    return UIDeviceOrientationPortrait;
}

#pragma mark - UIGestureRecognizer

- (void)onTitleTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:_titleScrollView];
    NSUInteger nearestTitleIndex = [self indexOfNearestObject:_titleCenterPoints fromPoint:tapPoint];
    [self moveToPageAtIndex:nearestTitleIndex animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat halfOffsetX = _titleScrollView.frame.size.width / 2;
    CGPoint targetOffset = *targetContentOffset;
    targetOffset.x += halfOffsetX;

    if (scrollView == _titleScrollView) {
        // mimic pagination when scrolling through titles
        NSUInteger nearestIndex = [self indexOfNearestObject:_titleCenterPoints fromPoint:targetOffset];
        CGPoint nearestTitlePoint = [[_titleCenterPoints objectAtIndex:nearestIndex] CGPointValue];
        [self updatePageIndex:nearestIndex];

        [UIView animateWithDuration:.4f animations:^{
            targetContentOffset->x = nearestTitlePoint.x - halfOffsetX;
        }];
    }
    else if (scrollView == _pageScrollView) {
        // this scrollView already has pagination enabled natively, so we only need to find the nearest page
        NSUInteger nearestIndex = [self indexOfNearestObject:_pageCenterPoints fromPoint:targetOffset];
        [self updatePageIndex:nearestIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint currentTitlePoint = [[_titleCenterPoints objectAtIndex:_currentPageIndex] CGPointValue];
    CGFloat pageWidth = _pageScrollView.frame.size.width;
    CGFloat halfPageWidth = pageWidth / 2;
    CGPoint currentContentOffset = scrollView.contentOffset;
    currentContentOffset.x += halfPageWidth;

    if (scrollView == _titleScrollView) {
        // transfer scroll from title to content
        
        CGFloat progress = [self progressBetweenTitlesForPoint:currentContentOffset];
        
        // Calculate required page offset based on title progression
        CGFloat contentOffsetX = pageWidth * progress;

        if (currentContentOffset.x < currentTitlePoint.x) {
            contentOffsetX *= -1;
        }

        contentOffsetX = pageWidth * _currentPageIndex + contentOffsetX;
        
        // Cap offset lower bound to 0
        contentOffsetX = MAX(0, contentOffsetX);

        // Cap offset upper bound
        CGFloat maxOffset = _pageScrollView.frame.size.width * ([_pageViewControllers count] - 1);
        contentOffsetX = MIN(maxOffset, contentOffsetX);

        CGPoint newPageContentOffset = CGPointMake(roundf(contentOffsetX), 0);
        [self updateScrollView:_pageScrollView contentOffset:newPageContentOffset];
    }
    else if (scrollView == _pageScrollView) {
        // transfer scroll from content to title

        CGFloat progress = [self progressBetweenPagesForPoint:currentContentOffset];
        CGFloat contentOffset = currentTitlePoint.x + progress - halfPageWidth;
        CGPoint newContentOffset = CGPointMake(contentOffset, 0);
        [self updateScrollView:_titleScrollView contentOffset:newContentOffset];
    }
}

#pragma mark - Helpers

// Finds the nearest index for a given point
- (NSUInteger)indexOfNearestObject:(NSArray *)objects fromPoint:(CGPoint)point
{
    __block NSUInteger index;
    __block CGFloat distance = CGFLOAT_MAX;
    
    [objects enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        CGPoint objectPoint = [obj CGPointValue];
        CGFloat currentDistance = objectPoint.x > point.x ? objectPoint.x - point.x : point.x - objectPoint.x;
        
        if (currentDistance < distance) {
            distance = currentDistance;
            index = idx;
        }
        else {
            // distance should go down as we get closer to it
            // when the currentDistance gets bigger, it means we are moving away
            *stop = YES;
        }
    }];
    
    return index;
}

// Starting from currentIndex, return the next index in the direction the point is going
- (NSUInteger)nextIndexForObjects:(NSArray *)objects fromIndex:(NSInteger)currentIndex andPoint:(CGPoint)point
{
    NSUInteger nextIndex;
    CGPoint currentPoint = [[objects objectAtIndex:currentIndex] CGPointValue];
    
    if (currentPoint.x < point.x) {
        // get next
        nextIndex = currentIndex < objects.count - 1 ? currentIndex + 1 : currentIndex;
    }
    else if (currentPoint.x > point.x) {
        // get previous
        nextIndex = currentIndex > 0 ? currentIndex - 1 : currentIndex;
    }
    else {
        // on the point
        nextIndex = currentIndex;
    }
    
    return nextIndex;
}

// Finds how far between 2 titles a point is, returns a percent (0 <= progress <= 1)
- (CGFloat)progressBetweenTitlesForPoint:(CGPoint)point
{
    CGFloat progress = 0;
    
    // From our last known page index, determinte the index of the next page
    NSUInteger nextIndex = [self nextIndexForObjects:_titleCenterPoints
                                           fromIndex:_currentPageIndex
                                            andPoint:point];
    
    if (nextIndex != _currentPageIndex) {
        CGPoint currentTitlePoint = [[_titleCenterPoints objectAtIndex:_currentPageIndex] CGPointValue];
        CGPoint nextTitlePoint = [[_titleCenterPoints objectAtIndex:nextIndex] CGPointValue];
        
        // Calculate the distance between the current and the next title
        CGFloat distanceBetweenTitlePoints = [self distanceBetweenPoint:currentTitlePoint andPoint:nextTitlePoint];

        // Calculate how far have we moved from the current title
        CGFloat offsetDistance = [self distanceBetweenPoint:point andPoint:currentTitlePoint];

        // Calculate the progression between the current and next title (percent value 0 <= progress <= 1)
        progress = offsetDistance / distanceBetweenTitlePoints;
    }
    
    return progress;
}

// Finds how far between 2 pages a point is, returns the offset we need to move the titles
- (CGFloat)progressBetweenPagesForPoint:(CGPoint)point
{
    CGFloat progress = 0;
    NSUInteger nextPageIndex = [self nextIndexForObjects:_pageCenterPoints
                                               fromIndex:_currentPageIndex
                                                andPoint:point];
    
    if (nextPageIndex != _currentPageIndex) {
        CGPoint currentPagePoint = [[_pageCenterPoints objectAtIndex:_currentPageIndex] CGPointValue];
        CGPoint nextPagePoint = [[_pageCenterPoints objectAtIndex:nextPageIndex] CGPointValue];

        // Calculate the distance between the current and next page
        CGFloat distanceBetweenPagePoints = [self distanceBetweenPoint:currentPagePoint andPoint:nextPagePoint];

        // Calculate how far we moved from the current page
        CGFloat offsetDistance = [self distanceBetweenPoint:point andPoint:currentPagePoint];

        // Calculate the progression between the current and next page (percent value 0 <= pageProgress <= 1)
        CGFloat pageProgress = offsetDistance / distanceBetweenPagePoints;

        CGPoint currentTitlePoint = [[_titleCenterPoints objectAtIndex:_currentPageIndex] CGPointValue];
        CGPoint nextTitlePoint = [[_titleCenterPoints objectAtIndex:nextPageIndex] CGPointValue];

        if (nextTitlePoint.x > currentTitlePoint.x) {
            progress = (nextTitlePoint.x - currentTitlePoint.x) * pageProgress;
        }
        else {
            progress = (currentTitlePoint.x - nextTitlePoint.x) * pageProgress * -1;
        }
        
    }
    
    return progress;
}

// Set a scrollview's contentOffset without triggering delegate calls
// We don't want to trigger delegate calls here or we'll hit an infinite loop
- (void)updateScrollView:(UIScrollView *)scrollView contentOffset:(CGPoint)point
{
    id scrollViewDelegate = scrollView.delegate;
    scrollView.delegate = nil;
    scrollView.contentOffset = point;
    scrollView.delegate = scrollViewDelegate;
}

- (CGFloat)distanceBetweenPoint:(CGPoint)firstPoint andPoint:(CGPoint)secondPoint
{
    CGFloat distance;
    
    if (firstPoint.x > secondPoint.x) {
        distance = firstPoint.x - secondPoint.x;
    }
    else {
        distance = secondPoint.x - firstPoint.x;
    }
    
    return distance;
}

- (CGFloat)offsetBetweenPoint:(CGPoint)firstPoint andPoint:(CGPoint)secondPoint
{
    CGFloat distance = [self distanceBetweenPoint:firstPoint andPoint:secondPoint];
    
    if (firstPoint.x > secondPoint.x) {
        distance *= -1;
    }

    return distance;
}

// Set page index and notify delegate of changes
- (void)updatePageIndex:(NSUInteger)index
{
    BOOL isSamePage = _currentPageIndex == index;

    if (!isSamePage && [self.delegate respondsToSelector:@selector(pagerController:didDeselectPageAtIndex:)]) {
        [self.delegate pagerController:self didDeselectPageAtIndex:_currentPageIndex];
    }
    
    _currentPageIndex = index;
    
    if (!isSamePage && [self.delegate respondsToSelector:@selector(pagerController:didSelectPageAtIndex:)]) {
        [self.delegate pagerController:self didSelectPageAtIndex:_currentPageIndex];
    }
}

#pragma mark - Interactions

- (BOOL)moveToPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index >= [_titleViews count] || _currentPageIndex == index) {
        return NO;
    }

    CGPoint currentOffset = [[_pageCenterPoints objectAtIndex:_currentPageIndex] CGPointValue];
    CGPoint targetOffset = [[_pageCenterPoints objectAtIndex:index] CGPointValue];
    CGFloat distance = [self offsetBetweenPoint:currentOffset andPoint:targetOffset];
    CGPoint newOffset = CGPointMake(currentOffset.x + distance - _pageScrollView.frame.size.width / 2, 0);
    [self updatePageIndex:index];
    [_pageScrollView setContentOffset:newOffset animated:animated];

//    if (!animated) {
//        // the call above won't trigger scrollView events so we need to update the title scrollView ourselves
//        CGPoint currentTitleOffset = [[_titleCenterPoints objectAtIndex:_currentPageIndex] CGPointValue];
//        CGPoint targetTitleOffset = [[_titleCenterPoints objectAtIndex:index] CGPointValue];
//        CGFloat titleDistance = [self offsetBetweenPoint:currentTitleOffset andPoint:targetTitleOffset];
//        CGPoint newTitleOffset = CGPointMake(currentTitleOffset.x + titleDistance - _titleScrollView.frame.size.width / 2, 0);
//        [_titleScrollView setContentOffset:newTitleOffset animated:animated];
//    }

    return YES;
}

@end
