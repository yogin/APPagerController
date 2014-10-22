//
//  APPagerController.h
//  Pods
//
//  Created by Anthony Powles on 10/17/14.
//
//

#import <UIKit/UIKit.h>
#import "APPagerDataSource.h"
#import "APPagerDelegate.h"

@interface APPagerController : UIViewController

// The main UI components
@property (nonatomic, strong, readonly) UIScrollView *pageScrollView;
@property (nonatomic, strong, readonly) UIScrollView *titleScrollView;

// Sets the spacing between each title view (default: 20)
@property (nonatomic) NSUInteger titleSpacing;

// Sets the height for the titleScrollView (default: 48)
@property (nonatomic) NSUInteger titleScrollViewHeight;

// Sets the default start page (default: 0)
// TODO BUG: it won't update the view
@property (nonatomic) NSUInteger defaultPageIndex;

// Gets the current page index
@property (nonatomic, readonly) NSUInteger currentPageIndex;

// DataSource and delegate
@property (nonatomic, weak) id<APPagerDataSource> dataSource;
@property (nonatomic, weak) id<APPagerDelegate> delegate;

// Force a reload of the data and a refresh of the layout
- (void)reloadData;

// Number of pages loaded
- (NSUInteger)numberOfPages;

// Ability to enumerate over registered titles and pages (can be different from dataSource)
- (void)enumerateTitleAndPageWithBlock:(void (^)(UIView *title, UIViewController *page, NSUInteger index))block;

// Programmatically move to a specific page
- (BOOL)moveToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

// Access underlying views and controllers for a specific page
- (UIView *)viewForPageAtIndex:(NSUInteger)index;
- (UIViewController *)controllerForPageAtIndex:(NSUInteger)index;

@end
