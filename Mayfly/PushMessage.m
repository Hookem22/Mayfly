//
//  PushMessage.m
//  Mayfly
//
//  Created by Will Parks on 6/8/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "PushMessage.h"

@implementation PushMessage

+(void)push:(NSString *)deviceToken  header:(NSString *)header message:(NSString *)message
{
    QSAzureMessageService *messageService = [[QSAzureMessageService alloc] init];
    
    [messageService send:deviceToken alert:header message:message];
}

+(void)pushByEvent:(Event *)event header:(NSString *)header message:(NSString *)message
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    for(NSString *facebookId in [event.going componentsSeparatedByString:@"|"])
//    {
//        if([facebookId rangeOfString:appDelegate.facebookId].location == NSNotFound)
//        {
//            NSString *fbId = [facebookId substringToIndex:[facebookId rangeOfString:@":"].location];
//            [User getByFacebookId:fbId completion:^(User *user)
//             {
//                 [self push:user.pushDeviceToken header:header message:message];
//             }];
//        }
//    }
}

+(void)inviteFriends:(NSArray *)facebookIds from:(NSString *)from event:(Event *)event
{
    QSAzureMessageService *messageService = [[QSAzureMessageService alloc] init];
    for(NSString *facebookId in facebookIds)
    {
        [User getByFacebookId:facebookId completion:^(User* user)
         {
             Notification *notification = [[Notification alloc] init: @{ @"facebookid": facebookId, @"eventid": event.eventId, @"message": [NSString stringWithFormat:@"Invited: %@", event.name] }];
             [notification save:^(Notification *notification) { }];
            
            if(user.pushDeviceToken != nil && ![user.pushDeviceToken isEqualToString:@""])
            {
                [messageService send:user.pushDeviceToken alert:[NSString stringWithFormat:@"%@ invited you to %@", from, event.name] message:[NSString stringWithFormat:@"Invitation|%@", event.eventId]];
            }
        }];
    }
}


@end
