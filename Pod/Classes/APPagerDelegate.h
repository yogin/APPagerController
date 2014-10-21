//
//  APPagerDelegate.h
//  Pods
//
//  Created by Anthony Powles on 10/17/14.
//
//

#import <Foundation/Foundation.h>

@class APPagerController;

@protocol APPagerDelegate <NSObject>
@required

@optional

// Get page changes notifications
- (void)pagerController:(APPagerController *)pager didSelectPageAtIndex:(NSUInteger)index;
- (void)pagerController:(APPagerController *)pager didDeselectPageAtIndex:(NSUInteger)index;

// Allow further customization of the initial layout without having to subclass the controller
- (void)customizeLayoutForPagerController:(APPagerController *)pager;

@end
