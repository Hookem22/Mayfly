//
//  Event.h
//  Mayfly
//
//  Created by Will Parks on 5/19/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
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
@property (nonatomic, assign) NSUInteger referenceId;

-(id)init:(NSDictionary *)event;
-(id)initFromUrl:(NSString *)url;
+(void)get:(QSCompletionBlock)completion;
+(void)get:(NSString *)eventId completion:(QSCompletionBlock)completion;
+(void)getByReferenceId:(NSString *)referenceId completion:(QSCompletionBlock)completion;
-(void)save:(QSCompletionBlock)completion;

-(void)addGoing;
-(void)removeGoing;
-(void)addInvited:(NSString *)facebookId firstName:(NSString *)firstName;
-(BOOL)isGoing;
-(BOOL)isInvited;

@end
