//
//  User.h
//  Mayfly
//
//  Created by Will Parks on 6/1/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"
#import "Session.h"
#import "Event.h"
#import "AppDelegate.h"

@interface User : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *pushDeviceToken;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSDate *lastSignedIn;

+(void)login:(QSCompletionBlock)completion;
+(void)getByFacebookId:(NSString *)facebookId completion:(QSCompletionBlock)completion;

@end
