//
//  PushMessage.h
//  Mayfly
//
//  Created by Will Parks on 6/8/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"
#import "User.h"

@interface PushMessage : NSObject

+(void)push:(NSString *)deviceToken  header:(NSString *)header message:(NSString *)message;
+(void)inviteFriends:(NSArray *)facebookIds from:(NSString *)from message:(NSString *)message;

@end