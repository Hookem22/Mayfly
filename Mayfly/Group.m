//
//  Group.m
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize groupId = _groupId;
@synthesize name = _name;
@synthesize description = _description;
@synthesize pictureUrl = _pictureUrl;
@synthesize schoolId = _schoolId;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize city = _city;
@synthesize isPublic = _isPublic;
@synthesize password = _password;
@synthesize locations = _locations;
@synthesize orderBy = _orderBy;

-(id)init:(NSDictionary *)group {
    self = [super init];
    if (self) {
        self.groupId = [group valueForKey:@"id"];
        self.name = [group objectForKey:@"name"];
        self.description = [group objectForKey:@"description"];
        self.pictureUrl = [group objectForKey:@"pictureurl"];
        self.schoolId = [group objectForKey:@"schoolid"];
        self.latitude = [[group objectForKey:@"latitude"] isMemberOfClass:[NSNull class]] ? 0 : [[group objectForKey:@"latitude"] doubleValue];
        self.longitude = [[group objectForKey:@"longitude"] isMemberOfClass:[NSNull class]] ? 0 : [[group objectForKey:@"longitude"] doubleValue];
        self.city = [group objectForKey:@"city"];
        self.isPublic = [[group objectForKey:@"ispublic"] isMemberOfClass:[NSNull class]] ? TRUE : [[group objectForKey:@"ispublic"] boolValue];
        self.password = [group valueForKey:@"password"];
        self.orderBy = [[group objectForKey:@"orderby"] isMemberOfClass:[NSNull class]] ? 0 : [[group objectForKey:@"orderby"] intValue];
        self.isInvitedtoEvent = NO;
    }
    return self;
}

+(void)get:(NSString *)groupId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Group"];

    [service get:groupId completion:^(NSDictionary *item) {
        Group *group = [[Group alloc] init:item];
        [group getMembers:^(NSArray *users) {
            group.members = [NSArray arrayWithArray:users];
            completion(group);
        }];
    }];
}

+(void)getBySchool:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Group"];
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", school.schoolId] forKey:@"schoolid"];

    [service getByProc:@"getgroupsbyschool" params:params completion:^(NSArray *results) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for(id item in results) {
            Group *group = [[Group alloc] init:item];
            [list addObject:group];
        }
        completion(list);
    }];
}

+(void)getByUser:(NSString *)userId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Group"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", userId] forKey:@"userid"];
    
    [service getByProc:@"getgroupsbyuser" params:params completion:^(NSArray *results) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for(id item in results) {
            Group *group = [[Group alloc] init:item];
            [list addObject:group];
        }
        completion(list);
    }];
}

-(void)getMembers:(QSCompletionBlock)completion
{
    [GroupUsers getByGroupId:self.groupId completion:^(NSArray *results) {
        completion(results);
    }];
}

-(void)isAdmin:(QSCompletionBlock)completion {
    QSAzureService *service = [QSAzureService defaultService:@"GroupUsers"];
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSString *whereStatement = [NSString stringWithFormat:@"userid = '%@' AND groupid = '%@'", currentUser.userId, self.groupId];
    
    [service getByWhere:whereStatement completion:^(NSArray *results) {
        for(id item in results) {
            GroupUsers *groupUser = [[GroupUsers alloc] init:item];
            completion(groupUser);
            return;
        }
        GroupUsers *groupUser = [[GroupUsers alloc] init];
        groupUser.isAdmin = false;
        completion(groupUser);
    }];
}

-(void)addMember:(NSString *)userId isAdmin:(BOOL)isAdmin
{
    [GroupUsers joinGroup:self.groupId userId:userId isAdmin:isAdmin];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    [groups addObject:self];
    for(Group *group in currentUser.groups)
    {
        [groups addObject:group];
    }
    currentUser.groups = [groups mutableCopy];
}

-(void)removeMember:(NSString *)userId
{
    QSAzureService *service = [QSAzureService defaultService:@"GroupUsers"];
    
    [self getMembers:^(NSArray *members) {
        for(GroupUsers *user in members)
        {
            if([user.userId isEqualToString:userId])
            {
                [service deleteItem:user.groupUserId completion:^(NSDictionary *item) {   }];
            }
        }
    }];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    for(Group *group in currentUser.groups)
    {
        if(![group.groupId isEqualToString:self.groupId])
            [groups addObject:group];
    }
    currentUser.groups = [groups mutableCopy];
}

-(BOOL)isMember
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if(currentUser == nil || currentUser.userId == nil)
        return NO;
    
    for(Group *group in currentUser.groups) {
        if([group.groupId isEqualToString:self.groupId]) {
            return YES;
        }
    }
    
    return NO;
}

+(void)clearIsInvitedToEvent {
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    for(Group *group in currentUser.groups) {
        group.isInvitedtoEvent = NO;
    }
}

-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Group"];
    
    NSDictionary *group = @{@"name": self.name, @"description": self.description, @"pictureurl": self.pictureUrl, @"schoolid": self.schoolId, @"latitude": [NSNumber numberWithDouble:self.latitude], @"longitude": [NSNumber numberWithDouble:self.longitude], @"ispublic": [NSNumber numberWithBool:self.isPublic], @"password": self.password, @"orderBy": [NSNumber numberWithInt:self.orderBy] };
    
    if([self.groupId length] > 0) { //Update
        NSMutableDictionary *mutableEvent = [group mutableCopy];
        [mutableEvent setObject:self.groupId forKey:@"id"];
        [service updateItem:mutableEvent completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:group completion:^(NSDictionary *item)
         {
             self.groupId = [item objectForKey:@"id"];
             completion(self);
         }];
    }
    
}

+(void)inviteGroups:(NSArray *)groups event:(Event *)event completion:(QSCompletionBlock)completion
{
    [Group getfilteredMembers:groups event:event completion:^(NSArray *users) {
        for(EventGoing *going in users) {
            [User get:going.userId completion:^(User *user) {
               if(user == nil || user.userId == nil || user.firstName == nil)
                   return;
                
                BOOL alreadyInvited = NO;
                for(EventGoing *invited in event.invited){
                    if([user.userId isEqualToString:invited.userId]) {
                        alreadyInvited = YES;
                        break;
                    }
                }
                
                if(!alreadyInvited) {
                    QSAzureService *service = [QSAzureService defaultService:@"EventInvited"];
                    NSDictionary *eventInvited = @{@"eventid": event.eventId, @"facebookid": user.facebookId, @"name":user.firstName, @"invitedby": @"", @"userid": user.userId };
                    
                    [service addItem:eventInvited completion:^(NSDictionary *item)
                     {
                         EventGoing *eventGoing = [[EventGoing alloc] init:item];
                         NSMutableArray *invites = [[NSMutableArray alloc] init];
                         [invites addObject:eventGoing];
                         for(EventGoing *invite in event.invited){
                             [invites addObject:invite];
                         }
                         event.invited = [NSArray arrayWithArray:invites];
                         completion(event);
                         
                         NSString *msg = [NSString stringWithFormat:@"New Event: %@", event.name];
                         NSString *info = [NSString stringWithFormat:@"Invitation|%@", event.eventId];
                         [PushMessage push:user.userId message:msg info:info];
                     }];
                }
                
                Notification *notification = [[Notification alloc] init: @{ @"userid": user.userId, @"eventid": event.eventId, @"message": [NSString stringWithFormat:@"New Event: %@", event.name] }];
                [notification save:^(Notification *notification) { }];
            }];
        }
        

    }];

}

+(void)getfilteredMembers:(NSArray *)groups event:(Event *)event completion:(QSCompletionBlock)completion
{
    [Group getGroupsMembers:groups completion:^(NSArray *groupUsers) {
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for(GroupUsers *groupUser in groupUsers) {
            BOOL isInGroup = NO;
            for(EventGoing *going in users) {
                if([going.userId isEqualToString:groupUser.userId]) {
                    isInGroup = YES;
                    break;
                }
            }
            if(!isInGroup && ![groupUser.userId isEqualToString:currentUser.userId]) {
                EventGoing *add = [[EventGoing alloc] init];
                add.userId = groupUser.userId;
                add.eventId = event.eventId;
                add.firstName = groupUser.firstName;
                [users addObject:add];
            }
        }
        completion(users);
    }];

    
}

+(void)getGroupsMembers:(NSArray *)groups completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"GroupUsers"];
    NSString *groupText = @"";
    for(Group *group in groups) {
        groupText = [groupText isEqualToString:@""] ? [NSString stringWithFormat:@"groupid == '%@'", group.groupId] : [NSString stringWithFormat:@"%@ OR groupid == '%@'", groupText, group.groupId];
    }
    NSString *whereStatement = groupText;
    
    [service getByWhere:whereStatement completion:^(NSArray *results) {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for(id item in results) {
            GroupUsers *groupUser = [[GroupUsers alloc] init:item];
            [users addObject:groupUser];
        }
        completion(users);
    }];
}

-(void)sendMessageToGroup:(NSString *)message info:(NSString *)info  {
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    [self getMembers:^(NSArray *members) {
        for(GroupUsers *member in members) {
            if(![member.userId isEqualToString:currentUser.userId]) {
                
                [PushMessage push:member.userId message:message info:info];
            }
        }
    }];
}

@end
