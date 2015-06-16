//
//  PushMessage.m
//  Mayfly
//
//  Created by Will Parks on 6/8/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "PushMessage.h"

@implementation PushMessage

@synthesize messageId = _messageId;
@synthesize eventId = _eventId;
@synthesize facebookId = _facebookId;
@synthesize name = _name;
@synthesize message = _message;
@synthesize sentDate = _sentDate;

-(id)init:(NSDictionary *)pushMessage
{
    self = [super init];
    if (self) {
        self.messageId = [pushMessage valueForKey:@"id"];
        self.eventId = [pushMessage objectForKey:@"eventid"];
        self.facebookId = [pushMessage objectForKey:@"facebookid"];
        self.name = [pushMessage objectForKey:@"name"];
        self.message = [pushMessage objectForKey:@"message"];
        self.sentDate = [pushMessage objectForKey:@"sentdate"];
    }
    return self;
}

+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Message"];
    NSString *whereStatement = [NSString stringWithFormat:@"eventid = '%@'", eventId];
    
    [service getByWhere:whereStatement completion:^(NSArray *results) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(id item in results) {
            PushMessage *pushMessage = [[PushMessage alloc] init:item];
            [array addObject:pushMessage];
        }
        [array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sentDate" ascending:NO]]];
        completion(array);
    }];
}

-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Message"];
    
    NSDictionary *dict = @{@"eventid": self.eventId, @"facebookid":self.facebookId, @"name": self.name, @"message": self.message, @"sentDate": self.sentDate };
    
    if([self.messageId length] > 0) { //Update
        NSMutableDictionary *mutableEvent = [dict mutableCopy];
        [mutableEvent setObject:self.messageId forKey:@"id"];
        [service updateItem:mutableEvent completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:dict completion:^(NSDictionary *item)
         {
             self.messageId = [item objectForKey:@"id"];
             completion(self);
         }];
    }
    
}

+(void)push:(NSString *)deviceToken  header:(NSString *)header message:(NSString *)message
{
    QSAzureService *service = [QSAzureService defaultService:@""];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:deviceToken forKey:@"devicetoken"];
    [params setValue:header forKey:@"header"];
    [params setValue:message forKey:@"message"];
    
    [service sendPushMessage:params];
}

+(void)pushByEvent:(Event *)event header:(NSString *)header message:(NSString *)message
{
    for(NSString *fbId in [event.going componentsSeparatedByString:@"|"])
    {
        [User getByFacebookId:fbId completion:^(User *user)
         {
             [self push:fbId header:header message:message];
         }];
    }
}

+(void)inviteFriends:(NSArray *)facebookIds from:(NSString *)from event:(Event *)event
{
    for(NSString *facebookId in facebookIds)
    {
        [User getByFacebookId:facebookId completion:^(User* user)
         {
             Notification *notification = [[Notification alloc] init: @{ @"facebookid": facebookId, @"eventid": event.eventId, @"message": [NSString stringWithFormat:@"Invited: %@", event.name] }];
             [notification save:^(Notification *notification) { }];
            if(user.pushDeviceToken != nil && ![user.pushDeviceToken isEqualToString:@""])
            {
                [PushMessage push:user.pushDeviceToken header:[NSString stringWithFormat:@"%@ invited you to an Event", from] message:event.name];
            }
        }];
    }
}

@end
