//
//  GroupUsers.m
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "GroupUsers.h"

@implementation GroupUsers

@synthesize groupUserId = _groupUserId;
@synthesize groupId = _groupId;
@synthesize userId = _userId;
@synthesize isAdmin = _isAdmin;
@synthesize firstName = _firstName;
@synthesize facebookId = _facebookId;

-(id)init:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.groupUserId = [dict valueForKey:@"id"];
        self.groupId = [dict objectForKey:@"groupid"];
        self.userId = [dict objectForKey:@"userid"];
        self.isAdmin = [[dict objectForKey:@"isadmin"] isMemberOfClass:[NSNull class]] ? 0 : [[dict objectForKey:@"isadmin"] boolValue];
        self.firstName = [dict objectForKey:@"firstname"];
        self.facebookId = [dict objectForKey:@"facebookid"];
    }
    return self;
}

+(void)getByGroupId:(NSString *)groupId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"GroupUsers"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", groupId] forKey:@"groupid"];
    
    [service getByProc:@"getgroupusers" params:params completion:^(NSArray *results) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for(id item in results) {
            GroupUsers *user = [[GroupUsers alloc] init:item];
            [list addObject:user];
        }
        completion(list);
    }];
}

+(void)getByUserId:(NSString *)userId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"GroupUsers"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", userId] forKey:@"userid"];
    
    [service getByProc:@"getgroupsbyuser" params:params completion:^(NSArray *results) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for(id item in results) {
            GroupUsers *user = [[GroupUsers alloc] init:item];
            [list addObject:user];
        }
        completion(list);
    }];
}

+(void)joinGroup:(NSString *)groupId userId:(NSString *)userId isAdmin:(BOOL)isAdmin
{
    QSAzureService *service = [QSAzureService defaultService:@"GroupUsers"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", groupId] forKey:@"groupid"];
    [params setValue:[NSString stringWithFormat:@"%@", userId] forKey:@"userid"];
    
    [service getByProc:@"getgroupusersdeleted" params:params completion:^(NSArray *results) {
        if(results.count > 0) {
            [service getByProc:@"undeletegroupusers" params:params completion:^(NSArray *results) {
                
            }];
        }
        else
        {
            NSDictionary *going = @{@"groupid": groupId, @"userid": userId, @"isadmin": [NSNumber numberWithBool:isAdmin] };
            [service addItem:going completion:^(NSDictionary *item)
             {
                 
             }];
        }
    }];    
}


@end
