//
//  Notification.h
//  Mayfly
//
//  Created by Will Parks on 6/16/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"

@interface Notification : NSObject

@property (nonatomic, copy) NSString *notificationId;
@property (nonatomic, copy) NSString *facebookId;
@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSDate *createdDate;

-(id)init:(NSDictionary *)notification;
+(void)get:(NSString *)facebookId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

@end
