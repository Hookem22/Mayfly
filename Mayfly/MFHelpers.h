//
//  MFHelpers.h
//  Mayfly
//
//  Created by Will Parks on 6/12/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MFProgressView.h"
#import "Event.h"
#import "User.h"
#import "Session.h"
#import "PushMessage.h"
#import "Notification.h"
#import "Message.h"
#import "Branch-SDK/Branch.h"

@interface MFHelpers : UIView

+(void)showProgressView:(UIView *)view;
+(void)hideProgressView:(UIView *)view;
+(void)open:(UIView *)view onView:(UIView *)onView;
+(void)openFromRight:(UIView *)view onView:(UIView *)onView;
+(void)close:(UIView *)view;
+(void)closeRight:(UIView *)view;
+(void)remove:(UIView *)view;
+(NSString *)dateDiffByDate:(NSDate *)date;
+(NSString *)dateDiffBySeconds:(NSInteger)seconds;
//+(void)GetBranchUrl:(NSUInteger)referenceId eventName:(NSString *)eventName phone:(NSString *)phone completion:(QSCompletionBlock)completion;
+(void)GetBranchUrl:(NSUInteger)referenceId eventName:(NSString *)eventName completion:(QSCompletionBlock)completion;

@end
