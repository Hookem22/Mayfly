//
//  Event.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "Event.h"

@implementation Event

@synthesize eventId;
@synthesize name;
@synthesize eventDescription;
@synthesize location;
@synthesize isPrivate;
@synthesize minParticipants;
@synthesize maxParticipants;
@synthesize startTime;
@synthesize cutoffTime;

- (id)init:(NSDictionary *)event {
    self = [super init];
    if (self) {
        self.eventId = [event valueForKey:@"id"];
        self.name = [event objectForKey:@"name"];
        self.eventDescription = [event objectForKey:@"eventdescription"];
        
        self.location = [[Location alloc] init];
        self.location.name = [event objectForKey:@"locationname"];
        self.location.address = [event objectForKey:@"locationaddress"];
        self.location.latitude = [[event objectForKey:@"locationlatitude"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"locationlatitude"] doubleValue];
        self.location.longitude = [[event objectForKey:@"locationlongitude"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"locationlongitude"] doubleValue];
        
        self.isPrivate = [[event objectForKey:@"isprivate"] isMemberOfClass:[NSNull class]] ? YES : [[event objectForKey:@"isprivate"] boolValue];
        self.minParticipants = [[event objectForKey:@"minparticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"minparticipants"] intValue];
        self.maxParticipants = [[event objectForKey:@"maxparticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"maxparticipants"] intValue];
        self.startTime = [event objectForKey:@"starttime"];
        self.cutoffTime = [event objectForKey:@"cutofftime"];
    }
    return self;
}

+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    NSString *whereStatement = [NSString stringWithFormat:@"id = '%@'", eventId];
    
    [service getByWhere:whereStatement completion:^(NSArray *results) {
        for(id item in results) {
            Event *event = [[Event alloc] init:item];
            completion(event);
            return;
        }
        completion(nil);
    }];
}

+(void)get:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    
    //CLLocation *location = (CLLocation *)[Session sessionVariables][@"location"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSString stringWithFormat:@"%f", 30.2] forKey:@"latitude"];
    [params setValue:[NSString stringWithFormat:@"%f", -97.8] forKey:@"longitude"];
    
    [service getByProc:@"getevents" params:params completion:^(NSArray *results) {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for(id item in results) {
            Event *event = [[Event alloc] init:item];
            [events addObject:event];
        }
        completion(events);
    }];
}

-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    NSDictionary *event = @{@"name": self.name, @"eventdescription": self.eventDescription, @"locationname": self.location.name, @"locationaddress": self.location.address, @"locationlatitude": [NSNumber numberWithDouble:self.location.latitude], @"locationlongitude": [NSNumber numberWithDouble:self.location.longitude],  @"isprivate": [NSNumber numberWithBool:self.isPrivate], @"minparticipants": [NSNumber numberWithInt:self.minParticipants], @"maxparticipants": [NSNumber numberWithInt:self.maxParticipants], @"starttime": self.startTime, @"cutofftime": self.cutoffTime };
    
    if([self.eventId length] > 0) { //Update
        [event setValue:self.eventId forKey:@"id"];
        [service updateItem:event completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:event completion:^(NSDictionary *item)
         {
             self.eventId = [item objectForKey:@"id"];
             completion(self);
         }];
    }

}




@end
