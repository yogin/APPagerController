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

- (void)pagerController:(APPagerController *)pager didSelectPageAtIndex:(NSUInteger)index;
- (void)pagerController:(APPagerController *)pager didDeselectPageAtIndex:(NSUInteger)index;

@end
