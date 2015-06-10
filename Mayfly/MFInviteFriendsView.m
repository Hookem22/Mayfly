//
//  MFInviteFriendsView.m
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFInviteFriendsView.h"

@interface MFInviteFriendsView()

@property (nonatomic, strong) MFAddressBook *addressBook;

@end

@implementation MFInviteFriendsView

@synthesize ContactsList = _ContactsList;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
        [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        addFriendsButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:addFriendsButton];
        
        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
        
        self.addressBook = [[MFAddressBook alloc] initWithFrame:CGRectMake(0, ht, wd, ht) invited:self.ContactsList returnView:self];
        [self.superview.superview addSubview:self.addressBook];
    }
    return self;
}

-(void)addFriendsButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;

    [self.superview.superview bringSubviewToFront:self.addressBook];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.addressBook.frame = CGRectMake(0, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}
-(void)invite:(NSArray *)contactsList
{
    for(id subview in self.subviews)
    {
        if([subview isMemberOfClass:[UIScrollView class]])
            [subview removeFromSuperview];
    }
    
    UIScrollView *peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 80)];
    NSLog(@"%f", peopleView.contentSize.width);
    NSLog(@"%f", self.frame.size.width);
    self.ContactsList = contactsList;
    
    for(int i = 0; i < [contactsList count]; i++)
    {
        NSDictionary *contact = [contactsList objectAtIndex:i];
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(i * 60, 0, 60, 80)];
        
        NSString *facebookId = [contact objectForKey:@"id"];
        if(facebookId != nil)
        {
            MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) facebookId:facebookId];
            [personView addSubview:pic];
        }
        else
        {
            UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -5, 60, 60)];
            int faceNumber = (arc4random() % 8);
            [pic setImage:[UIImage imageNamed:[NSString stringWithFormat:@"face%d", faceNumber]]];
            [personView addSubview:pic];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
        label.text = [contact objectForKey:@"firstName"];
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [peopleView addSubview:personView];
        peopleView.contentSize = CGSizeMake((i + 1) * 60, 80);
        NSLog(@"%f", peopleView.contentSize.width);
    }
    
    [self addSubview:peopleView];
    
}


@end
