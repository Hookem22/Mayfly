//
//  Notification.m
//  Mayfly
//
//  Created by Will Parks on 6/16/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "Notification.h"

@implementation Notification

@synthesize notificationId = _notificationId;
@synthesize userId = _userId;
@synthesize eventId = _eventId;
@synthesize message = _message;
@synthesize secondsSince = _secondsSince;
@synthesize createdDate = _createdDate;

-(id)init:(NSDictionary *)notification
{
    self = [super init];
    if (self) {
        self.notificationId = [notification valueForKey:@"id"];
        self.userId = [notification objectForKey:@"userid"];
        self.eventId = [notification objectForKey:@"eventid"];
        self.message = [notification objectForKey:@"message"];
        self.secondsSince = [[notification objectForKey:@"Seconds"] isMemberOfClass:[NSNull class]] ? 0 : [[notification objectForKey:@"Seconds"] intValue];
        self.createdDate = [notification objectForKey:@"__createdAt"];
    }
    return self;
}

+(void)get:(NSString *)userId completion:(QSCompletionBlock)completion
{
    QSAzureService *service = [QSAzureService defaultService:@"Notification"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:[NSString stringWithFormat:@"%@", userId] forKey:@"userid"];
    
    [service getByProc:@"getnotifications" params:params completion:^(NSArray *results) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(id item in results) {
            Notification *notification = [[Notification alloc] init:item];
            [array addObject:notification];
        }
        //[array sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]]];
        completion(array);
    }];
}

-(void)save:(QSCompletionBlock)completion
{
    if(self.userId == nil || self.eventId == nil)
        return;
    
    QSAzureService *service = [QSAzureService defaultService:@"Notification"];
    NSDictionary *dict = @{@"userid":self.userId, @"eventid": self.eventId, @"message": self.message };
    
    if([self.notificationId length] > 0) { //Update
        NSMutableDictionary *mutableEvent = [dict mutableCopy];
        [mutableEvent setObject:self.notificationId forKey:@"id"];
        [service updateItem:mutableEvent completion:^(NSDictionary *item)
         {
             completion(self);
         }];
    }
    else //Add
    {
        [service addItem:dict completion:^(NSDictionary *item)
         {
             self.notificationId = [item objectForKey:@"id"];
             completion(self);
         }];
    }
    
}

@end
