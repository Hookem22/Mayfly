//
//  AppDelegate.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *facebookId;
@property (strong, nonatomic) NSString *referenceId;

@end

