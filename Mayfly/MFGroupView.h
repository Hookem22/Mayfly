//
//  MFGroupsView.h
//  Pow Wow
//
//  Created by Will Parks on 12/28/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFCreateGroupView.h"
#import "MFGroupDetailView.h"
#import "MFHelpers.h"
#import "Group.h"

@interface MFGroupView : UIScrollView <UIScrollViewDelegate>


-(void)loadGroups;
-(void)populateAllInterests;
-(void)populateMyInterests;


@end
