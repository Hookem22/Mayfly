//
//  MFEventsView.h
//  Mayfly
//
//  Created by Will Parks on 5/20/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "MFDetailView.h"
#import "MFLoginView.h"

@interface MFEventsView : UIScrollView <UIScrollViewDelegate>

-(void)loadEvents;
-(void)populateAllEvents;
-(void)populateMyEvents;
-(void)goToEvent:(NSString *)eventId;

@end
