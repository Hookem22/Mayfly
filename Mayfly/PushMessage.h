//
//  PushMessage.h
//  Mayfly
//
//  Created by Will Parks on 6/8/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureMessageService.h"
#import "User.h"

@interface PushMessage : NSObject

+(void)push:(NSString *)userId  message:(NSString *)message info:(NSString *)info;
+(void)pushByEvent:(Event *)event header:(NSString *)header message:(NSString *)message;
+(void)inviteFriends:(NSArray *)facebookIds from:(NSString *)from event:(Event *)event;

@end
