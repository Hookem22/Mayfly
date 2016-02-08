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
#import "MFInstructionsView.h"
#import "MFAddButtonView.h"

@interface MFView : UIView <UIWebViewDelegate>

@property (nonatomic, strong) UIView *addView;

-(void)setup;
-(void)refreshEvents;
-(void)scrollUp;
-(void)scrollDown;
-(void)eventsButtonClick;
-(void)interestsButtonClick;

@end
