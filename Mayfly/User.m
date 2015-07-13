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
                completion(addedUser);
                
                if(appDelegate.referenceId != nil)
                {
                    [self addReferralEvent:addedUser];
                }
            }];
        }
        else if(appDelegate.referenceId != nil)
        {
            [self addReferralEvent:deviceUser];
        }
    }];
}

+(void)addReferralEvent:(User *)user
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [Event getByReferenceId:appDelegate.referenceId completion:^(Event *event)
     {
         [event addInvited:user.facebookId];
         
         Notification *notification = [[Notification alloc] init: @{@"facebookid": user.facebookId, @"eventid": event.eventId, @"message": [NSString stringWithFormat:@"Invited: %@", event.name] }];
         [notification save:^(Notification *notification) { }];
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
