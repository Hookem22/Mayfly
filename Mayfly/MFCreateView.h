//
//  MFCreateView.h
//  Mayfly
//
//  Created by Will Parks on 5/20/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ViewController.h"
#import "MFView.h"
#import "MFLoginView.h"
#import "MFLocationView.h"
#import "Event.h"
#import "PushMessage.h"
#import "MFPillButton.h"
#import "MFClockView.h"
#import "MFInviteFriendsView.h"
#import "MFAddressBook.h"
#import "MFHelpers.h"

@interface MFCreateView : UIView <UITextViewDelegate>

-(id)init:(Event *)event;
-(void)invite:(NSArray *)contactsList;

@end
