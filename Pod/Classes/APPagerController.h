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
@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIScrollView *titleScrollView;

// Sets the spacing between each title view (default: 20)
@property (nonatomic) NSUInteger titleSpacing;
@property (nonatomic) NSUInteger titleScrollViewHeight;
@property (nonatomic) NSUInteger defaultPageIndex;

// DataSource and delegate
@property (nonatomic, weak) id<APPagerDataSource> dataSource;
@property (nonatomic, weak) id<APPagerDelegate> delegate;

// Force a reload of the data and a refresh of the layout
- (void)reloadData;

// Programmatically move to a specific page
- (BOOL)moveToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;

// Access underlying views and controllers for a specific page
- (UIView *)viewForPageAtIndex:(NSUInteger)index;
- (UIViewController *)controllerForPageAtIndex:(NSUInteger)index;

@end
