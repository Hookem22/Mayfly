//
//  MFHelpers.h
//  Mayfly
//
//  Created by Will Parks on 6/12/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFProgressView.h"

@interface MFHelpers : UIView

+(void)showProgressView:(UIView *)view;
+(void)hideProgressView:(UIView *)view;
+(void)open:(UIView *)view onView:(UIView *)onView;
+(void)openFromRight:(UIView *)view onView:(UIView *)onView;
+(void)close:(UIView *)view;
+(void)closeRight:(UIView *)view;
+(void)remove:(UIView *)view;


@end
