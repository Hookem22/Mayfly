//
//  Message.m
//  Pow Wow
//
//  Created by Will Parks on 6/23/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "Message.h"

@implementation Message

@synthesize messageId = _messageId;
@synthesize eventId = _eventId;
@synthesize userId = _userId;
@synthesize facebookId = _facebookId;
@synthesize name = _name;
@synthesize message = _message;
@synthesize secondsSince = _secondsSince;
@synthesize sentDate = _sentDate;

-(id)init:(NSDictionary *)message
{
    self = [super init];
    if (self) {
        self.messageId = [message valueForKey:@"id"];
        self.eventId = [message objectForKey:@"eventid"];
        self.userId = [message objectForKey:@"userid"];
        self.facebookId = [message objectForKey:@"facebookid"];
        self.name = [message objectForKey:@"name"];
        self.message = [message objectForKey:@"message"];
        self.secondsSince = [[message objectForKey:@"Seconds"] isMemberOfClass:[NSNull class]] ? 0 : [[message objectForKey:@"Seconds"] intValue];
        self.sentDate = [message objectForKey:@"__createdAt"];
    }
    return self;
}

+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Message"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:eventId forKey:@"eventid"];
    
    [service getByProc:@"getmessages" params:params completion:^(NSArray *results) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(id item in results) {
            Message *message = [[Message alloc] init:item];
            [array addObject:message];
        }
        //[array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"sentDate" ascending:NO]]];
        completion(array);
    }];
}

-(void)save:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Message"];
    
    NSDictionary *dict = @{@"eventid": self.eventId, @"userid":self.userId, @"facebookid":self.facebookId, @"name": self.name, @"message": self.message };
    
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

@end
