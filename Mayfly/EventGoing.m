//
//  EventGoing.m
//  Pow Wow
//
//  Created by Will Parks on 12/17/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "EventGoing.h"

@implementation EventGoing

@synthesize eventGoingId = _eventGoingId;
@synthesize eventId = _eventId;
@synthesize userId = _userId;
@synthesize isAdmin = _isAdmin;
@synthesize firstName = _firstName;
@synthesize facebookId = _facebookId;

-(id)init:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.eventGoingId = [dict valueForKey:@"id"];
        self.eventId = [dict objectForKey:@"eventid"];
        self.userId = [dict objectForKey:@"userid"];
        self.isAdmin = [[dict objectForKey:@"isadmin"] isMemberOfClass:[NSNull class]] ? 0 : [[dict objectForKey:@"isadmin"] boolValue];
        self.firstName = [dict objectForKey:@"firstname"];
        self.facebookId = [dict objectForKey:@"facebookid"];
    }
    return self;
}

+(void)getByEventId:(NSString *)eventId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", eventId] forKey:@"eventid"];
    
    [service getByProc:@"getgoingbyevent" params:params completion:^(NSArray *results) {
        NSMutableArray *goings = [[NSMutableArray alloc] init];
        for(id item in results) {
            NSLog(@"%@", item);
            EventGoing *evgoing = [[EventGoing alloc] init:item];
            [goings addObject:evgoing];
        }
        completion(goings);
    }];
}

+(void)getByUserId:(NSString *)userId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", userId] forKey:@"userid"];
    
    [service getByProc:@"getgoingbyuser" params:params completion:^(NSArray *results) {
        NSMutableArray *goings = [[NSMutableArray alloc] init];
        for(id item in results) {
            EventGoing *going = [[EventGoing alloc] init:item];
            [goings addObject:going];
        }
        completion(goings);
    }];
}

+(void)joinEvent:(NSString *)eventId userId:(NSString *)userId isAdmin:(BOOL)isAdmin
{
    QSAzureService *service = [QSAzureService defaultService:@"EventGoing"];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", eventId] forKey:@"eventid"];
    [params setValue:[NSString stringWithFormat:@"%@", userId] forKey:@"userid"];
    
    [service getByProc:@"getgoingdeleted" params:params completion:^(NSArray *results) {
        if(results.count > 0) {
            [service getByProc:@"undeletegoing" params:params completion:^(NSArray *results) {

            }];
        }
        else
        {
            NSDictionary *going = @{@"eventid": eventId, @"userid": userId, @"isadmin": [NSNumber numberWithBool:isAdmin] };
            [service addItem:going completion:^(NSDictionary *item)
             {

             }];
        }
    }];
}



@end
