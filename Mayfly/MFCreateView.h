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
#import "MFLoginView.h"
#import "MFAddressBook.h"
#import "Event.h"

@interface MFCreateView : UIScrollView <UITextViewDelegate>

-(void)create;
-(void)invite:(NSArray *)contactsList;

@end
