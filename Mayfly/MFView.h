//
//  MFView.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MFEventsView.h"
#import "MFCreateView.h"
#import "MFLoginView.h"
#import "MFNotificationView.h"
#import "MFHelpers.h"
#import "MFGroupView.h"

@interface MFView : UIView <UIWebViewDelegate>

-(void)setup;
-(void)refreshEvents;
-(void)openEvent:(NSString *)eventId toMessaging:(BOOL)toMessaging;



//-(void)loadWebsite;
//-(void)returnAddressList:(NSString *)params;
//-(void)goToEvent:(NSUInteger)referenceId;
//-(void)sendLatLngToWeb;

@end
