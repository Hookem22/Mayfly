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
#import "MFDetailView.h"
#import "MFLoginView.h"
#import "Event.h"

@interface MFEventsView : UIScrollView


-(void)loadEvents;

@end
