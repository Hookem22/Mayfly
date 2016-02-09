//
//  MFAddToCalendar.h
//  Pow Wow
//
//  Created by Will Parks on 2/9/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFHelpers.h"

@import EventKit;

@interface MFCalendarAccess : UIView <UIAlertViewDelegate>

-(void)addToCalendar:(Event *)event;

@end
