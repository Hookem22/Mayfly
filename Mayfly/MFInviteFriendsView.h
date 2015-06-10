//
//  MFInviteFriendsView.h
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFAddressBook.h"
#import "MFProfilePicView.h"

@interface MFInviteFriendsView : UIView

-(void)invite:(NSArray *)contactsList;

@property (nonatomic, strong) NSArray *ContactsList;

@end
