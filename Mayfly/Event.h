//
//  Event.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QSAzureService.h"
#import "Location.h"
#import "Session.h"

@interface Event : NSObject

@property (nonatomic, copy) NSString *eventId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *eventDescription;
@property (nonatomic, strong) Location *location;
@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) NSUInteger minParticipants;
@property (nonatomic, assign) NSUInteger maxParticipants;
@property (nonatomic, copy) NSDate *startTime;
@property (nonatomic, copy) NSDate *cutoffTime;
@property (nonatomic, copy) NSString *invited;
@property (nonatomic, copy) NSString *going;

-(id)init:(NSDictionary *)event;
+(void)get:(QSCompletionBlock)completion;
+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

-(void)addGoing:(NSString *)facebookId;
-(void)removeGoing:(NSString *)facebookId;

@end
