//
//  PushMessage.m
//  Mayfly
//
//  Created by Will Parks on 6/8/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "PushMessage.h"

@implementation PushMessage

+(void)push:(NSString *)pushToken deviceId:(NSString *)deviceId header:(NSString *)header message:(NSString *)message;
{
    QSAzureMessageService *messageService = [[QSAzureMessageService alloc] init];
    if(pushToken != nil && ![pushToken isEqualToString:@""])
    {
        BOOL isiOS = [pushToken isEqualToString:deviceId];
        [messageService send:pushToken isiOS:isiOS alert:header message:message];
    }
}

+(void)push:(NSString *)userId  message:(NSString *)message info:(NSString *)info
{
    [User get:userId completion:^(User *user) {
        [self push:user.pushDeviceToken deviceId:user.deviceId header:message message:info];
    }];
}


//+(void)pushByEvent:(Event *)event header:(NSString *)header message:(NSString *)message
//{
//    for(EventGoing *eventGoing in event.going) {
//        [User get:eventGoing.userId completion:^(User *user) {
//            
//        }];
//    }
////    for(NSString *facebookId in [event.going componentsSeparatedByString:@"|"])
////    {
////        if([facebookId rangeOfString:appDelegate.facebookId].location == NSNotFound)
////        {
////            NSString *fbId = [facebookId substringToIndex:[facebookId rangeOfString:@":"].location];
////            [User getByFacebookId:fbId completion:^(User *user)
////             {
////                 [self push:user.pushDeviceToken header:header message:message];
////             }];
////        }
////    }
//}

+(void)inviteFriend:(NSString *)pushToken deviceId:(NSString *)deviceId from:(NSString *)from event:(Event *)event;
{
    NSString *header = [NSString stringWithFormat:@"%@ invited you to %@", from, event.name];
    NSString *message = [NSString stringWithFormat:@"Invitation|%@", event.eventId];
    
    [self push:pushToken deviceId:deviceId header:header message:message];

}



@end
