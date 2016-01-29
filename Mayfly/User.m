//
//  User.m
//  Mayfly
//
//  Created by Will Parks on 6/1/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userId = _userId;
@synthesize deviceId = _deviceId;
@synthesize name = _name;
@synthesize firstName = _firstName;
@synthesize pushDeviceToken = _pushDeviceToken;
@synthesize facebookId = _facebookId;
@synthesize lastSignedIn = _lastSignedIn;
@synthesize isiOS = _isiOS;

- (id)init {
    self = [super init];
    if (self) {
        self.userId = @"";
        self.deviceId = @"";
        self.name = @"";
        self.firstName = @"";
        self.pushDeviceToken = @"";
        self.facebookId = @"";
        self.lastSignedIn = [NSDate date];
    }
    return self;
}

- (id)init:(NSDictionary *)user {
    self = [super init];
    if (self) {
        self.userId = [user objectForKey:@"id"];
        self.deviceId = [[user objectForKey:@"deviceid"] isMemberOfClass:[NSNull class]] ? @"" : [user objectForKey:@"deviceid"];
        self.name = [[user objectForKey:@"name"] isMemberOfClass:[NSNull class]] ? @"" : [user objectForKey:@"name"];
        self.firstName = [[user objectForKey:@"firstname"] isMemberOfClass:[NSNull class]] ? @"" : [user objectForKey:@"firstname"];
        self.pushDeviceToken = [[user objectForKey:@"pushdevicetoken"] isMemberOfClass:[NSNull class]] ? @"" : [user objectForKey:@"pushdevicetoken"];
        self.facebookId = [[user objectForKey:@"facebookid"] isMemberOfClass:[NSNull class]] ? @"" : [user objectForKey:@"facebookid"];
        self.email = [[user objectForKey:@"email"] isMemberOfClass:[NSNull class]] ? @"" : [user objectForKey:@"email"];
        self.lastSignedIn = [user objectForKey:@"lastsignedin"];
        self.isiOS = [[user objectForKey:@"isios"] isMemberOfClass:[NSNull class]] ? YES : [[user objectForKey:@"isios"] boolValue];
    }
    return self;
}

+(void)login:(User *)loginUser completion:(QSCompletionBlock)completion
{

    if([loginUser isKindOfClass:[NSNull class]] || [loginUser.facebookId isKindOfClass:[NSNull class]] || loginUser.facebookId.length <= 0)
        return;
    
    [self getByFacebookId:loginUser.facebookId completion:^(User *deviceUser) {
        if((!deviceUser || !deviceUser.deviceId || deviceUser.deviceId.length <= 0 || [deviceUser.name isEqualToString:@""] || [deviceUser.pushDeviceToken isEqualToString:@""] || ![deviceUser.pushDeviceToken isEqualToString:loginUser.pushDeviceToken])) {
            
            User *newUser = deviceUser == nil ? [[User alloc] init] : deviceUser;
            newUser.deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            
            newUser.pushDeviceToken = loginUser.pushDeviceToken ? loginUser.pushDeviceToken : @"";
            newUser.name = loginUser.name ? loginUser.name : @"";
            newUser.firstName = loginUser.firstName ? loginUser.firstName : @"";
            newUser.facebookId = loginUser.facebookId ? loginUser.facebookId : @"";
            newUser.email = loginUser.email ? loginUser.email : @"";
            newUser.isiOS = YES;
            
            /*Always update info
            if(!newUser.pushDeviceToken || [newUser.pushDeviceToken isEqualToString:@""])
                newUser.pushDeviceToken = appDelegate.deviceToken ? appDelegate.deviceToken : @"";
            if(!newUser.name || [newUser.name isEqualToString:@""])
                newUser.name = appDelegate.name ? appDelegate.name : @"";
            if(!newUser.facebookId || [newUser.facebookId isEqualToString:@""])
                newUser.facebookId = appDelegate.facebookId ? appDelegate.facebookId : @"";
            if(!newUser.email || [newUser.email isEqualToString:@""])
                newUser.email = appDelegate.email ? appDelegate.email : @"";
            */
            [newUser save:^(User *addedUser) {
                [addedUser getUserValues:^(User *finishedUser) {
                    completion(finishedUser);
                }];
            }];

        }
        else {
            [deviceUser getUserValues:^(User *finishedUser) {
                completion(finishedUser);
            }];
        }
    }];
}

-(void)getUserValues:(QSCompletionBlock)completion {
    [self getUserGroups:^(NSArray *groups) {
        self.groups = [groups mutableCopy];
        [self getUserGoing:^(NSArray *going) {
            self.goingEventIds = [going mutableCopy];
            [self getUserInvited:^(NSArray *invited) {
                self.invitedEventIds = [invited mutableCopy];
                [[Session sessionVariables] setObject:self forKey:@"currentUser"];
                completion(self);
            }];
        }];
    }];
}

-(void)getUserGroups:(QSCompletionBlock)completion {
    [Group getByUser:self.userId completion:^(NSArray *groups) {
        completion(groups);
    }];
}

-(void)getUserGoing:(QSCompletionBlock)completion {
    [Event getGoingByUserId:self.userId completion:^(NSArray *going) {
        completion(going);
    }];
}

-(void)getUserInvited:(QSCompletionBlock)completion {
    [Event getInvitedByUserId:self.userId completion:^(NSArray *invited) {
        completion(invited);
    }];
}

+(void)addReferralEvent:(User *)user completion:(QSCompletionBlock)completion
{
    NSString *referenceId = (NSString *)[Session sessionVariables][@"referenceId"];
    
    [Event getByReferenceId:referenceId completion:^(Event *event)
     {
         NSString *firstName = user.name;
         if([firstName rangeOfString:@" "].location != NSNotFound)
             firstName = [firstName substringToIndex:[firstName rangeOfString:@" "].location];
         
         [event addInvited:user.facebookId firstName:firstName];
         if(user.facebookId == nil || [user.facebookId isEqualToString:@""])
             return;
         
         Notification *notification = [[Notification alloc] init: @{@"facebookid": user.facebookId, @"eventid": event.eventId, @"message": [NSString stringWithFormat:@"Invited: %@", event.name] }];
         [notification save:^(Notification *notification) {
             completion(nil);
         }];
     }];
}

+(void)get:(NSString *)userId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Users"];
    
    [service get:userId completion:^(NSDictionary *item) {
        User *user = [[User alloc] init:item];
        completion(user);
    }];
}

+(void)getByDeviceId:(id)deviceId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Users"];
    NSString *whereStatement = [NSString stringWithFormat:@"deviceid = '%@'", deviceId];
    
    [service getByWhere:whereStatement completion:^(NSArray *results) {
        for(id item in results) {
            User *user = [[User alloc] init:item];
            completion(user);
            return;
        }
        completion(nil);
    }];
}

+(void)getByFacebookId:(NSString *)facebookId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Users"];
    NSString *whereStatement = [NSString stringWithFormat:@"facebookid = '%@'", facebookId];

    [service getByWhere:whereStatement completion:^(NSArray *results) {
        for(id item in results) {
            User *user = [[User alloc] init:item];
            completion(user);
            return;
        }
        completion(nil);
    }];
}

-(void)save:(QSCompletionBlock)completion
{
    
    QSAzureService *service = [QSAzureService defaultService:@"Users"];
    
    NSDictionary *user = @{@"deviceid" : self.deviceId, @"name" : self.name, @"firstname" : self.firstName, @"pushdevicetoken" : self.pushDeviceToken, @"facebookid" : self.facebookId, @"email" : self.email, @"isios": [NSNumber numberWithBool:self.isiOS] /*, @"lastsignedin" : self.lastSignedIn */};
    
    if([self.userId length] <= 0)
    {
        [service addItem:user completion:^(NSDictionary *item)
         {
             User *user = [[User alloc] init:item];
             completion(user);
         }];
    }
    else
    {
        NSMutableDictionary *mutableUser = [user mutableCopy];
        [mutableUser setObject:self.userId forKey:@"id"];
        [service updateItem:[mutableUser copy] completion:^(NSDictionary *item) {
            User *user = [[User alloc] init:item];
            completion(user);
        }];
    }
}

@end
