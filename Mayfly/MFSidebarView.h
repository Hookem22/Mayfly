//
//  MFRightSideView.h
//  Mayfly
//
//  Created by Will Parks on 6/16/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDetailView.h"
#import "MFSettingsView.h"
#import "MFNotificationsView.h"
#import "MFHelpers.h"

@interface MFSidebarView : UIView

-(id)init;
-(void)setup;
-(void)loadUserPoints;

@end
