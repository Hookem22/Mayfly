//
//  MFDetailView.h
//  Mayfly
//
//  Created by Will Parks on 5/21/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MFLoginView.h"
#import "Event.h"
#import "User.h"
#import "Session.h"
#import "MFProfilePicView.h"
#import "MFAddressBook.h"
#import "MFMessageView.h"

@interface MFDetailView : UIView

-(id)init:(Event *)event;

@end
