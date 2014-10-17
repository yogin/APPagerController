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

@property (nonatomic, weak) id<APPagerDataSource> dataSource;
@property (nonatomic, weak) id<APPagerDelegate> delegate;

@end
