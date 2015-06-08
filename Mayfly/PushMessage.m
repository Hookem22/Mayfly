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
    QSAzureService *service = [QSAzureService defaultService:@""];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:deviceToken forKey:@"devicetoken"];
    [params setValue:header forKey:@"header"];
    [params setValue:message forKey:@"message"];
    
    [service sendPushMessage:params];
}

+(void)inviteFriends:(NSArray *)facebookIds from:(NSString *)from message:(NSString *)message
{
    for(NSString *facebookId in facebookIds)
    {
        [User getByFacebookId:facebookId completion:^(User* user)
         {
            if(user.pushDeviceToken != nil && ![user.pushDeviceToken isEqualToString:@""])
            {
                [PushMessage push:user.pushDeviceToken header:[NSString stringWithFormat:@"%@ invited you to an Event", from] message:message];
            }
        }];
    }
}

@end
