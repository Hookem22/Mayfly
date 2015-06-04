//
//  MFDetailView.m
//  Mayfly
//
//  Created by Will Parks on 5/21/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFDetailView.h"

@interface MFDetailView ()

@property (nonatomic, strong) Event *event;

@end

@implementation MFDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)open:(Event*)event
{
    self.event = event;
    
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, wd, 20)];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = event.name;
    [self addSubview:headerLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(25, 30, 80, 40);
    [self addSubview:cancelButton];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, wd - 60, 20)];
    descriptionLabel.text = event.eventDescription;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [descriptionLabel sizeToFit];
    [self addSubview:descriptionLabel];
    
    //TODO: Add map
    UILabel *mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 90 + descriptionLabel.frame.size.height, wd - 60, 20)];
    mapLabel.text = @"Map Here";
    [self addSubview:mapLabel];

    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 210 + descriptionLabel.frame.size.height, wd - 60, 20)];
    startLabel.text = @"Start Time:";
    [self addSubview:startLabel];
    
    UILabel *cutoffLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 240 + descriptionLabel.frame.size.height, wd - 60, 20)];
    cutoffLabel.text = @"Sign Up By:";
    [self addSubview:cutoffLabel];
    
    UILabel *participantsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 270 + descriptionLabel.frame.size.height, wd - 60, 20)];
    participantsLabel.text = @"Participants";
    participantsLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:participantsLabel];
    
    UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
    [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    addFriendsButton.frame = CGRectMake(30, 350 + descriptionLabel.frame.size.height, wd-60, 30);
    [self addSubview:addFriendsButton];
    
    User *user = (User *)[Session sessionVariables][@"currentUser"];
    NSString *title = @"Join Event";
    if([event.going rangeOfString:user.facebookId].location != NSNotFound)
        title = @"Unjoin Event";
        
    UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [joinButton setTitle:title forState:UIControlStateNormal];
    [joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    joinButton.frame = CGRectMake(0, ht - 60, wd, 60);
    [self addSubview:joinButton];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 1.0f, wd, 1)];
    topBorder.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    [joinButton addSubview:topBorder];
    
    
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
        [self addSubview:loginView];
    }    
}

-(void)joinButtonClick:(id)sender
{
    User *user = (User *)[Session sessionVariables][@"currentUser"];
    
    UIButton *button = (UIButton *)sender;
    if([button.titleLabel.text isEqualToString:@"Join Event"])
    {
        [self.event addGoing:user.facebookId];
        [button setTitle:@"Unjoin Event" forState:UIControlStateNormal];
    }
    else
    {
        [self.event removeGoing:user.facebookId];
        [button setTitle:@"Join Event" forState:UIControlStateNormal];
    }
        
}
-(void)addFriendsButtonClick:(id)sender
{
    
}

-(void)cancelButtonClick:(id)sender
{
    [self close];
}

-(void)close
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, ht, wd, ht - 60);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

@end
