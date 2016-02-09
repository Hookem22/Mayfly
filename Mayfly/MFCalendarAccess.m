//
//  MFAddToCalendar.m
//  Pow Wow
//
//  Created by Will Parks on 2/9/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFCalendarAccess.h"

@interface MFCalendarAccess ()

// The database with calendar events and reminders
@property (strong, nonatomic) EKEventStore *eventStore;
@property (strong, nonatomic) Event *event;

@end

@implementation MFCalendarAccess

-(void)addToCalendar:(Event *)event
{
    self.event = event;
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    if(currentUser.addToCalendar == 0 || currentUser.addToCalendar == 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Add %@ to calendar?", event.name]
                                                        message: @"You can change your calendar preferences in the app settings."
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else if(currentUser.addToCalendar == 1) {
        if([self updateAuthorizationStatusToAccessEventStore]) {
            [self permissionGrantedAddToCalendar];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            break;
        case 1: //"Yes" pressed
            if([self updateAuthorizationStatusToAccessEventStore]) {
                [self permissionGrantedAddToCalendar];
            }
            break;
    }
}

-(void)permissionGrantedAddToCalendar {
    EKEvent *ekEvent = [EKEvent eventWithEventStore:self.eventStore];
    
    ekEvent.title = self.event.name;
    ekEvent.startDate = self.event.startTime;    
    // duration = 1 h
    ekEvent.endDate = [self.event.startTime dateByAddingTimeInterval:3600];
    
    // set the calendar of the event. - here default calendar
    [ekEvent setCalendar:[self.eventStore defaultCalendarForNewEvents]];
    
    // store the event
    NSError *err;
    BOOL success = [self.eventStore saveEvent:ekEvent span:EKSpanThisEvent error:&err];
    if(!success) {
        
    }
    [self removeFromSuperview];
}

- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (BOOL)updateAuthorizationStatusToAccessEventStore {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                                message:@"This app doesn't have access to your Calendar. To add events, change this in your settings." delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return NO;
            break;
        }
            
        case EKAuthorizationStatusAuthorized:
            return YES;
            break;
            
        case EKAuthorizationStatusNotDetermined: {
            [self.eventStore requestAccessToEntityType:EKEntityTypeEvent
                                            completion:^(BOOL granted, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    if(granted) {
                                                        [self permissionGrantedAddToCalendar];
                                                    }
                                                });
                                            }];
            return NO;
            break;
        }
    }
}


@end
