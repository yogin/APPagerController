//
//  APPagerDataSource.h
//  Pods
//
//  Created by Anthony Powles on 10/17/14.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class APPagerController;

@protocol APPagerDataSource <NSObject>
@required

- (NSUInteger)numberOfPagesForPager:(APPagerController *)source;
- (UIViewController *)pageControllerForPager:(APPagerController *)source atIndex:(NSUInteger)index;
- (UIView *)titleViewForPager:(APPagerController *)source atIndex:(NSUInteger)index;
- (CGFloat)titleViewWidthForPager:(APPagerController *)source atIndex:(NSUInteger)index;

@optional

@end
