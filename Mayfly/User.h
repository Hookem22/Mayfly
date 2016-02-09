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
#import "Notification.h"
#import "Group.h"

@interface User : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *pushDeviceToken;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *schoolId;
@property (nonatomic, copy) NSDate *lastSignedIn;
@property (nonatomic, assign) BOOL isiOS;
@property (nonatomic, assign) int addToCalendar;

@property (nonatomic, copy) NSMutableArray *goingEventIds;
@property (nonatomic, copy) NSMutableArray *invitedEventIds;
@property (nonatomic, copy) NSMutableArray *groups;

+(void)login:(User *)loginUser completion:(QSCompletionBlock)completion;
+(void)get:(NSString *)userId completion:(QSCompletionBlock)completion;
+(void)getByFacebookId:(NSString *)facebookId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

@end
