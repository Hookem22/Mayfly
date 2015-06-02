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
    NSString *pushDeviceToken = appDelegate.deviceToken == nil ? @"" : appDelegate.deviceToken;
    NSString *referralId = appDelegate.queryValue;
    
    [self get:deviceId pushDeviceToken:pushDeviceToken completion:^(User *deviceUser) {
        //0 Users
        if((deviceUser == nil || deviceUser.deviceId.length <= 0) && [referralId length] <= 0) {
            User *newUser = [[User alloc] init];
            newUser.deviceId = deviceId;
            newUser.pushDeviceToken = pushDeviceToken;
            newUser.name = appDelegate.name;
            newUser.facebookId = appDelegate.facebookId;
            
            [newUser add:^(User *addedUser) {
                [[Session sessionVariables] setObject:addedUser forKey:@"currentUser"];
                completion(addedUser);
            }];
        }
    }];
}

+(void)get:(id)deviceId pushDeviceToken:(NSString *)pushDeviceToken completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Users"];
    NSString *whereStatement = @"";
    if([pushDeviceToken length] > 0)
        whereStatement = [NSString stringWithFormat:@"deviceid = '%@' OR pushdevicetoken = '%@'", deviceId, pushDeviceToken];
    else
        whereStatement = [NSString stringWithFormat:@"deviceid = '%@'", deviceId];
    
    [service getByWhere:whereStatement completion:^(NSArray *results) {
        for(id item in results) {
            User *user = [[User alloc] init:item];
            completion(user);
            return;
        }
        completion(nil);
    }];
}

-(void)add:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Users"];
    
    NSDictionary *user = @{@"deviceid" : self.deviceId, @"name" : self.name, @"pushdevicetoken" : self.pushDeviceToken, @"facebookid" : self.facebookId /*, @"lastsignedin" : self.lastSignedIn */};
    [service addItem:user completion:^(NSDictionary *item)
     {
         User *user = [[User alloc] init:item];
         completion(user);
     }];
}

@end
