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
@synthesize description = _description;
@synthesize groupId = _groupId;
@synthesize groupName = _groupName;
@synthesize groupPictureUrl = _groupPictureUrl;
@synthesize groupIsPublic = _groupIsPublic;
@synthesize referenceId = _referenceId;
@synthesize location = _location;
@synthesize minParticipants = _minParticipants;
@synthesize maxParticipants = _maxParticipants;
@synthesize startTime = _startTime;
@synthesize dayOfWeek = _dayOfWeek;
@synthesize localTime = _localTime;
@synthesize schoolId = _schoolId;
@synthesize going = _going;
@synthesize invited = _invited;
@synthesize messages = _messages;
@synthesize tagId = _tagId;
@synthesize primaryGroupId = _primaryGroupId;

-(id)init:(NSDictionary *)event {
    self = [super init];
    if (self) {
        self.eventId = [event valueForKey:@"id"];
        self.name = [event objectForKey:@"name"];
        self.description = [event objectForKey:@"description"];
        self.groupId = [event objectForKey:@"groupid"];
        self.groupName = [event objectForKey:@"groupname"];
        self.groupPictureUrl = [event objectForKey:@"grouppictureurl"];
        self.groupIsPublic = [[event objectForKey:@"groupispublic"] isMemberOfClass:[NSNull class]] ? YES : [[event objectForKey:@"groupispublic"] boolValue];
        self.referenceId = [[event objectForKey:@"referenceid"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"referenceid"] intValue];
        self.location = [[Location alloc] init];
        self.location.name = [event objectForKey:@"locationname"];
        self.location.address = [event objectForKey:@"locationaddress"];
        self.location.latitude = [[event objectForKey:@"locationlatitude"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"locationlatitude"] doubleValue];
        self.location.longitude = [[event objectForKey:@"locationlongitude"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"locationlongitude"] doubleValue];
        self.minParticipants = [[event objectForKey:@"minparticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"minparticipants"] intValue];
        self.maxParticipants = [[event objectForKey:@"maxparticipants"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"maxparticipants"] intValue];
        self.startTime = [event objectForKey:@"starttime"];
        self.dayOfWeek = [[event objectForKey:@"dayofweek"] isMemberOfClass:[NSNull class]] ? 0 : [[event objectForKey:@"dayofweek"] intValue];
        self.localTime = [event objectForKey:@"localtime"];
        //self.schoolId = [[event objectForKey:@"schoolid"] isMemberOfClass:[NSNull class]] ? @"" : [event objectForKey:@"schoolid"];
        self.schoolId = [event objectForKey:@"schoolid"];
        self.primaryGroupId = [[event objectForKey:@"primarygroupid"] isMemberOfClass:[NSNull class]] ? @"" : [event objectForKey:@"primarygroupid"];
    }
    return self;
}

-(id)initFromUrl:(NSString *)url
{
    NSError* error;
    url = [url stringByRemovingPercentEncoding];

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
    //NSString *whereStatement = [NSString stringWithFormat:@"id = '%@'", eventId];
    
    [service get:eventId completion:^(NSDictionary *item) {
        Event *event = [[Event alloc] init:item];
        [event getCompleted:^(Event *event) {
            completion(event);
        }];
    }];
}

-(void)getCompleted:(QSCompletionBlock)completion {
    [self getEventGoing:^(NSArray *goings) {
        self.going = [NSArray arrayWithArray:goings];
        self.isAdmin = NO;
        self.isMuted = NO;
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        for(EventGoing *going in goings) {
            if([going.userId isEqualToString:currentUser.userId]) {
                self.isAdmin = going.isAdmin;
                self.isMuted = going.isMuted;
            }
        }
        [self getEventInvited:^(NSArray *invited) {
            self.invited = [NSArray arrayWithArray:invited];
            [self getMessages:^(NSArray *messages) {
                self.messages = [NSArray arrayWithArray:messages];
                completion(self);
            }];
        }];
    }];
}

-(void)getEventGoing:(QSCompletionBlock)completion
{
    [EventGoing getByEventId:self.eventId completion:^(NSArray *goings) {
        completion(goings);
    }];
}

-(void)getEventInvited:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", self.eventId] forKey:@"eventid"];
    
    [service getByProc:@"getinvitedbyevent" params:params completion:^(NSArray *results) {
        NSMutableArray *invited = [[NSMutableArray alloc] init];
        for(id item in results) {
            EventGoing *ev = [[EventGoing alloc] init:item];
            [invited addObject:ev];
        }
        completion(invited);
    }];
}

-(void)getMessages:(QSCompletionBlock)completion
{
    [Message get:self.eventId completion:^(NSArray *messages)
     {
         completion(messages);
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

+(void)getBySchool:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", school.schoolId] forKey:@"schoolid"];

    [service getByProc:@"geteventsbyschoolid" params:params completion:^(NSArray *results) {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for(id item in results) {
            Event *event = [[Event alloc] init:item];
            [event getCompleted:^(Event *event) {
                [events addObject:event];
                if(events.count == results.count) {
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:TRUE];
                    [events sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    for(int i = 0; i < events.count; i++) {
                        Event *event = [events objectAtIndex:i];
                        event.tagId = i;
                    }
                    
                    [[Session sessionVariables] setObject:events forKey:@"currentEvents"];
                    completion(events);
                }
            }];
        }
        if(results.count == 0) {
            completion(events);
        }
    }];
}

+(void)getByUserId:(NSString *)userId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", userId] forKey:@"userid"];
    
    [service getByProc:@"getgoingbyuser" params:params completion:^(NSArray *results) {
        NSMutableArray *events = [[NSMutableArray alloc] init];
        for(id item in results) {
            [events addObject:[[Event alloc] init:item]];
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
       
    NSDictionary *event = @{@"name": self.name, @"description": self.description, @"groupid": self.groupId, @"groupname": self.groupName, @"grouppictureurl": self.groupPictureUrl, @"groupispublic": [NSNumber numberWithBool:self.groupIsPublic], @"referenceid": [NSNumber numberWithInt:(int)self.referenceId], @"locationname": self.location.name, @"locationaddress": self.location.address, @"locationlatitude": [NSNumber numberWithDouble:self.location.latitude], @"locationlongitude": [NSNumber numberWithDouble:self.location.longitude], @"minparticipants": [NSNumber numberWithInt:(int)self.minParticipants], @"maxparticipants": [NSNumber numberWithInt:(int)self.maxParticipants], @"starttime": self.startTime, @"dayofweek": [NSNumber numberWithInt:(int)self.dayOfWeek], @"localtime": self.localTime, @"schoolid": self.schoolId, @"primarygroupid": self.primaryGroupId };
    
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

-(void)addGoing:(NSString *)userId isAdmin:(BOOL)isAdmin
{
    [EventGoing joinEvent:self.eventId userId:userId isAdmin:isAdmin completion:^(NSDictionary *eventGoing) {
        [self getEventGoing:^(NSArray *goings) {
            self.going = goings;
        }];
    }];
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSMutableArray *goingIds = [[NSMutableArray alloc] init];
    [goingIds addObject:self.eventId];
    for(NSString *eventId in currentUser.goingEventIds)
    {
        [goingIds addObject:eventId];
    }
    currentUser.goingEventIds = [goingIds mutableCopy];
}

-(void)removeGoing:(NSString *)userId
{
    QSAzureService *service = [QSAzureService defaultService:@"EventGoing"];
    
    NSString *eventGoingId = @"";
    for(EventGoing *eg in self.going)
    {
        if([eg.userId isEqualToString:userId])
        {
            eventGoingId = eg.eventGoingId;
            break;
        }
    }
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSMutableArray *goingIds = [[NSMutableArray alloc] init];
    for(NSString *eventId in currentUser.goingEventIds)
    {
        if(![eventId isEqualToString:self.eventId]) {
            [goingIds addObject:eventId];
        }
    }
    currentUser.goingEventIds = [goingIds mutableCopy];

    [service deleteItem:eventGoingId completion:^(NSDictionary *item)
     {
     }];
}

-(BOOL)isGoing
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if(currentUser == nil || currentUser.facebookId == nil)
        return NO;
    
    for(NSString *eventId in currentUser.goingEventIds)
    {       
        if([self.eventId isEqualToString:eventId])
            return YES;
    }
    
    return NO;
}

+(void)getInvitedByUserId:(NSString *)facebookId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", facebookId] forKey:@"userid"];
    
    [service getByProc:@"getinvitedbyuserid" params:params completion:^(NSArray *results) {
        NSMutableArray *invitedEventIds = [[NSMutableArray alloc] init];
        for(id item in results) {
            [invitedEventIds addObject:[item objectForKey:@"eventid"]];
        }
        completion(invitedEventIds);
    }];
}

-(void)addInvite:(NSString *)facebookId name:(NSString *)name completion:(QSCompletionBlock)completion
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if(facebookId == nil) {
        QSAzureService *service = [QSAzureService defaultService:@"EventInvited"];
        NSDictionary *eventInvited = @{@"eventid": self.eventId, @"facebookid": @"", @"name":name, @"invitedby": currentUser.userId, @"userid": @"" };
        
        [service addItem:eventInvited completion:^(NSDictionary *item)
         {
             EventGoing *eventGoing = [[EventGoing alloc] init:item];
             
             NSMutableArray *invites = [[NSMutableArray alloc] init];
             [invites addObject:eventGoing];
             for(EventGoing *invite in self.invited){
                 [invites addObject:invite];
             }
             self.invited = [NSArray arrayWithArray:invites];
             completion(item);
         }];
    }
    else
    {
        [User getByFacebookId:facebookId completion:^(User * user)
         {
             if(user == nil)
                 return;
             
             BOOL alreadyInvited = NO;
             for(EventGoing *invited in self.invited){
                 if([user.userId isEqualToString:invited.userId]) {
                     alreadyInvited = YES;
                     break;
                 }
             }
             
             if(!alreadyInvited) {
                 QSAzureService *service = [QSAzureService defaultService:@"EventInvited"];
                 NSDictionary *eventInvited = @{@"eventid": self.eventId, @"facebookid": user.facebookId, @"name":user.firstName, @"invitedby": currentUser.userId, @"userid": user.userId };
                 
                 [service addItem:eventInvited completion:^(NSDictionary *item)
                  {
                      EventGoing *eventGoing = [[EventGoing alloc] init:item];
                      NSMutableArray *invites = [[NSMutableArray alloc] init];
                      [invites addObject:eventGoing];
                      for(EventGoing *invite in self.invited){
                          [invites addObject:invite];
                      }
                      self.invited = [NSArray arrayWithArray:invites];
                      completion(eventGoing);
                      
                      [PushMessage inviteFriend:user.pushDeviceToken deviceId:user.deviceId from:currentUser.firstName event:self];
                  }];
             }
         }];
    }
    
    Notification *notification = [[Notification alloc] init: @{ @"userid": currentUser.userId, @"eventid": self.eventId, @"message": [NSString stringWithFormat:@"Invited %@ to %@", name, self.name] }];
    [notification save:^(Notification *notification) { }];

}

-(BOOL)isInvited
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if(currentUser == nil || currentUser.facebookId == nil)
        return NO;
    
    for(NSString *eventId in currentUser.invitedEventIds)
    {
        if([self.eventId isEqualToString:eventId])
            return YES;
    }
    
    return NO;
}

//-(void)getGoing:(QSCompletionBlock)completion {
//    QSAzureService *service = [QSAzureService defaultService:@"EventGoing"];
//    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
//    NSString *whereStatement = [NSString stringWithFormat:@"userid = '%@' AND eventid = '%@'", currentUser.userId, self.eventId];
//    
//    [service getByWhere:whereStatement completion:^(NSArray *results) {
//        for(id item in results) {
//            EventGoing *eventGoing = [[EventGoing alloc] init:item];
//            completion(eventGoing);
//            return;
//        }
//        EventGoing *eventGoing = [[EventGoing alloc] init];
//        eventGoing.isAdmin = NO;
//        eventGoing.isMuted = NO;
//        completion(eventGoing);
//    }];
//}

-(void)sendMessageToEvent:(NSString *)message info:(NSString *)info
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    for(EventGoing *eg in self.going) {
        if(![eg.userId isEqualToString:currentUser.userId]) {
            if(eg.isMuted == NO) {
                [PushMessage push:eg.userId message:message info:info];
            }
            Notification *notification = [[Notification alloc] init: @{ @"userid": eg.userId, @"eventid": eg.eventId, @"message": message }];
            [notification save:^(Notification *notification) { }];
        }
    }
}

-(void)deleteEvent:(QSCompletionBlock)completion {
    QSAzureService *service = [QSAzureService defaultService:@"Event"];
    [service deleteItem:self.eventId completion:^(NSDictionary *item)
     {
         completion(item);
     }];
}

-(BOOL)isPrivate {
    if(self.groupIsPublic == false && self.isGoing == false && self.isInvited == false) {
        BOOL isMember = NO;
        NSArray *groups = [self.groupId componentsSeparatedByString: @"|"];
        for (NSString *groupId in groups) {
            Group *group = [[Group alloc] init];
            group.groupId = groupId;
            if(group.isMember == YES) {
                isMember = YES;
                break;
            }
        }
        
        if(!isMember ) {
            return YES;
        }
    }
    return NO;
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
