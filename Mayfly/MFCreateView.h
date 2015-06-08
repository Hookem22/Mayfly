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
#import "MFAddressBook.h"
#import "MFLocationSelectView.h"
#import "MFMapView.h"
#import "Event.h"
#import "PushMessage.h"

@interface MFCreateView : UIScrollView <UITextViewDelegate>

-(void)create;
-(void)invite:(NSArray *)contactsList;
-(void)locationReturn:(Location *)location;

@end
