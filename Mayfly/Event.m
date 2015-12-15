//
//  Event.m
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "Event.h"
#import "PushMessage.h"

@implementation Event

@synthesize eventId = _eventId;
@synthesize name = _name;
@synthesize eventDescription = _eventDescription;
@synthesize location = _location;
@synthesize isPrivate = _isPrivate;
@synthesize minParticipants = _minParticipants;
@synthesize maxParticipants = _maxParticipants;
@synthesize startTime = _startTime;
@synthesize cutoffTime = _cutoffTime;
@synthesize invited = _invited;
@synthesize going = _going;
@synthesize referenceId = _referenceId;
@synthesize dayOfWeek = _dayOfWeek;

-(id)init:(NSDictionary *)event {
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
        self.invited = [event objectForKey:@"invited"];
        self.going = [event objectForKey:@"going"];
        self.referenceId = [[event objectForKey:@"referenceid"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"referenceid"] intValue];
        self.dayOfWeek = [[event objectForKey:@"dayofweek"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"dayofweek"] intValue];
    }
    return self;
}

-(id)initFromUrl:(NSString *)url
{
    NSError* error;
    url = [url stringByRemovingPercentEncoding];
    NSLog(@"%@", url);
    NSData* data = [url dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for(int i = 0; i < [[dJSON allKeys] count]; i++)
    {
        NSString *key = [dJSON allKeys][i];
        NSString *newKey = [key lowercaseString];
        [dict setObject:[dJSON objectForKey:key] forKeyedSubscript:newKey];
    }
    
    return [[Event alloc] init:dict];
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
    
    Location *location = (Location *)[Session sessionVariables][@"currentLocation"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"latitude"];
    [params setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"longitude"];
    //[params setValue:[NSString stringWithFormat:@"%@", [NSDate date]] forKey:@"now"];
    
    [service getByProc:@"getevents" params:params completion:^(NSArray *results) {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for(id item in results) {
            Event *event = [[Event alloc] init:item];
            [events addObject:event];
        }
        completion(events);
    }];
}

+(void)getByReferenceId:(NSString *)referenceId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    NSString *whereStatement = [NSString stringWithFormat:@"referenceid = '%@'", referenceId];
    
    [service getByWhere:whereStatement completion:^(NSArray *results) {
        for(id item in results) {
            Event *event = [[Event alloc] init:item];
            completion(event);
            return;
        }
        completion(nil);
    }];
}

-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
       
    NSDictionary *event = @{@"name": self.name, @"eventdescription": self.eventDescription, @"locationname": self.location.name, @"locationaddress": self.location.address, @"locationlatitude": [NSNumber numberWithDouble:self.location.latitude], @"locationlongitude": [NSNumber numberWithDouble:self.location.longitude],  @"isprivate": [NSNumber numberWithBool:self.isPrivate], @"minparticipants": [NSNumber numberWithInt:(int)self.minParticipants], @"maxparticipants": [NSNumber numberWithInt:(int)self.maxParticipants], @"starttime": self.startTime, @"cutofftime": self.cutoffTime, @"invited": self.invited, @"going": self.going, @"referenceid": [NSNumber numberWithInt:(int)self.referenceId] };
    
    if([self.eventId length] > 0) { //Update
        NSMutableDictionary *mutableEvent = [event mutableCopy];
        [mutableEvent setObject:self.eventId forKey:@"id"];
        [service updateItem:mutableEvent completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:event completion:^(NSDictionary *item)
         {
             self.eventId = [item objectForKey:@"id"];
             self.referenceId = [[item objectForKey:@"referenceid"] isMemberOfClass:[NSNull class]] ? 0 : [[item objectForKey:@"referenceid"] intValue];
             completion(self);
         }];
    }

}

-(void)addGoing
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *person = [NSString stringWithFormat:@"%@:%@", appDelegate.facebookId, appDelegate.firstName];
    if(self.going == nil || [self.going isEqualToString:@""])
        self.going = person;
    else
        self.going = [NSString stringWithFormat:@"%@|%@", self.going, person];
    
    [self save:^(Event *event)
     {
         if([event.going rangeOfString:@":"].location != NSNotFound)
         {
             NSString *ownerFbId = [event.going substringToIndex:[event.going rangeOfString:@":"].location];
             if(![ownerFbId isEqualToString:appDelegate.facebookId])
             {
                 [User getByFacebookId:ownerFbId completion:^(User *user) {
                     NSString *header = [NSString stringWithFormat:@"%@ joined %@", appDelegate.firstName, self.name];
                     [PushMessage push:user.pushDeviceToken header:header message:@""];
                 }];
             }
         }
     }];
}

-(void)removeGoing
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSMutableArray *list = [self stringToList:self.going];
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    self.going = @"";
    for(int i = 0; i < [list count]; i++)
    {
        NSString *person = (NSString *)[list objectAtIndex:i];
        if([person rangeOfString:appDelegate.facebookId].location != NSNotFound)
            continue;
        
        if([newList count] == 0)
            self.going = person;
        else
            self.going = [NSString stringWithFormat:@"%@|%@", self.going, person];
    }
    
    [self save:^(Event *event)
     {
         
     }];
}

-(void)addInvited:(NSString *)facebookId firstName:(NSString *)firstName
{
    [Event get:self.eventId completion:^(Event *event)
     {
         if(![facebookId isEqualToString:@""] && [self.invited rangeOfString:facebookId].location == NSNotFound)
         {
             NSString *person = [NSString stringWithFormat:@"%@:%@", facebookId, firstName];
             event.invited = [event.invited length] <= 0 ? person : [NSString stringWithFormat:@"%@|%@", event.invited, person];
             [event save:^(Event *event)
              {
                  
              }];
         }
     }];
}

-(BOOL)isGoing
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate == nil || appDelegate.facebookId == nil)
        return false;
    
    return [self.going rangeOfString:appDelegate.facebookId].location != NSNotFound;
}
-(BOOL)isInvited
{
    NSString *referenceId = (NSString *)[Session sessionVariables][@"referenceId"];
    if(referenceId != nil && self.referenceId == [referenceId intValue])
        return true;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if(appDelegate == nil || appDelegate.facebookId == nil)
        return false;
    
    return [self.invited rangeOfString:appDelegate.facebookId].location != NSNotFound;
}

-(NSString *)listToString:(NSMutableArray *)list
{
    NSString *string = @"";
    for(int i = 0; i < [list count]; i++)
    {
        if(i > 0)
            string = [NSString stringWithFormat:@"%@|", string];
        
        NSString *item = (NSString *)[list objectAtIndex:i];
        string = [NSString stringWithFormat:@"%@%@", string, item];
    }
    return string;
}

-(NSMutableArray *)stringToList:(NSString *)string
{
    NSArray *list = [string componentsSeparatedByString:@"|"];
    return [list mutableCopy];
}


@end
