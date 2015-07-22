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
@synthesize pushDeviceToken = _pushDeviceToken;
@synthesize facebookId = _facebookId;
@synthesize lastSignedIn = _lastSignedIn;

- (id)init {
    self = [super init];
    if (self) {
        self.userId = @"";
        self.deviceId = @"";
        self.name = @"";
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
        self.deviceId = [user objectForKey:@"deviceid"];
        self.name = [user objectForKey:@"name"];
        self.pushDeviceToken = [user objectForKey:@"pushdevicetoken"];
        self.facebookId = [user objectForKey:@"facebookid"];
        self.lastSignedIn = [user objectForKey:@"lastsignedin"];
    }
    return self;
}

+(void)login:(QSCompletionBlock)completion
{
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    [self get:deviceId completion:^(User *deviceUser) {
        if((deviceUser == nil || deviceUser.deviceId.length <= 0 || [deviceUser.name isEqualToString:@""] || [deviceUser.pushDeviceToken isEqualToString:@""])) {
            User *newUser = deviceUser == nil ? [[User alloc] init] : deviceUser;
            newUser.deviceId = deviceId;
            if(!newUser.pushDeviceToken || [newUser.pushDeviceToken isEqualToString:@""])
                newUser.pushDeviceToken = appDelegate.deviceToken ? appDelegate.deviceToken : @"";
            if(!newUser.name || [newUser.name isEqualToString:@""])
                newUser.name = appDelegate.name ? appDelegate.name : @"";
            if(!newUser.facebookId || [newUser.facebookId isEqualToString:@""])
                newUser.facebookId = appDelegate.facebookId ? appDelegate.facebookId : @"";
            
            [newUser save:^(User *addedUser) {
                if((NSString *)[Session sessionVariables][@"referenceId"] != nil)
                {
                    [self addReferralEvent:addedUser completion:^(void) {
                        completion(addedUser);
                    }];
                }
                else {
                    completion(addedUser);
                }
            }];
        }
        else if([FBSDKAccessToken currentAccessToken] && (NSString *)[Session sessionVariables][@"referenceId"] != nil)
        {
            [self addReferralEvent:deviceUser completion:^(void) {
                completion(deviceUser);
            }];
        }
        else {
            completion(deviceUser);
        }
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

+(void)get:(id)deviceId completion:(QSCompletionBlock)completion
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
    
    NSDictionary *user = @{@"deviceid" : self.deviceId, @"name" : self.name, @"pushdevicetoken" : self.pushDeviceToken, @"facebookid" : self.facebookId /*, @"lastsignedin" : self.lastSignedIn */};
    
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
