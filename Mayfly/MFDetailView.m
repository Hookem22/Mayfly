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
@property (nonatomic, strong) UIScrollView *peopleView;
@property (nonatomic, strong) UILabel *goingLabel;

@end

@implementation MFDetailView

-(id)init:(NSString *)eventId
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self setup:eventId];
    }
    return self;
}

-(void)setup:(NSString *)eventId
{
    [Event get:eventId completion:^(Event *event)
    {
        self.event = event;

        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;

        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];


        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, wd - 150, 20)];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = event.name;
        [self addSubview:headerLabel];

        if(appDelegate.facebookId != nil && [event.going rangeOfString:appDelegate.facebookId].location == 0 && event.isPrivate)
        {
            float headerWd = [headerLabel.text boundingRectWithSize:headerLabel.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:headerLabel.font } context:nil].size.width;
            float totalWd = [[NSString stringWithFormat:@"%@ - Edit", headerLabel.text] boundingRectWithSize:headerLabel.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:headerLabel.font } context:nil].size.width;
            
            CGRect editFrame = CGRectMake(wd / 2 - 15, 40, 30, 20);
            NSString *editTitle = @"Edit";
            if(totalWd > 0) {
                headerLabel.frame = CGRectMake((wd - totalWd) / 2, 20, headerWd, 20);
                editFrame = CGRectMake(((wd - totalWd) / 2) + headerWd, 20, totalWd - headerWd, 20);
                editTitle = @" - Edit";
            }

            UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [editButton setTitle:editTitle forState:UIControlStateNormal];
            [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            editButton.frame = editFrame;
            [self addSubview:editButton];
        }

        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelButton setTitle:@"Done" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.frame = CGRectMake(15, 10, 80, 40);
        [cancelButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:cancelButton];

        UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 60, 15, 35, 30)];
        [messageButton setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [messageButton addTarget:self action:@selector(messageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:messageButton];

        UIScrollView *detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 40)];
        [self addSubview:detailView];

        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, wd - 60, 20)];
        descriptionLabel.text = event.eventDescription;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [descriptionLabel sizeToFit];
        [detailView addSubview:descriptionLabel];

        int descHt = descriptionLabel.frame.size.height;

        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10 + descHt, wd - 60, 20)];
        locationLabel.text = [NSString stringWithFormat:@"Location: %@", event.location.name];
        [detailView addSubview:locationLabel];

        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"h:mm a"];

        UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 40 + descHt, wd - 60, 20)];
        startLabel.text = [NSString stringWithFormat:@"Start Time: %@", [outputFormatter stringFromDate:event.startTime]];
        [detailView addSubview:startLabel];

        UILabel *cutoffLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 70 + descHt, wd - 60, 20)];
        cutoffLabel.text = [NSString stringWithFormat:@"Join By: %@", [outputFormatter stringFromDate:event.cutoffTime]];
        [detailView addSubview:cutoffLabel];

        UILabel *goingLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 100 + descHt, wd - 60, 20)];
        goingLabel.textAlignment = NSTextAlignmentCenter;
        self.goingLabel = goingLabel;
        [detailView addSubview:goingLabel];

        self.peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 130 + descHt, wd - 60, 80)];
        [detailView addSubview:self.peopleView];
        [self refreshGoing];

        UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addFriendsButton setTitle:@"Invite Friends" forState:UIControlStateNormal];
        [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        addFriendsButton.frame = CGRectMake(30, 205 + descHt, wd-60, 30);
        [detailView addSubview:addFriendsButton];

        MFMapView *map = [[MFMapView alloc] initWithFrame:CGRectMake(30, 250 + descHt, wd - 60, ht - (380 + descHt))];
        [map loadMap:self.event.location];
        [detailView addSubview:map];

        NSString *title = @"Join Event";
        if(appDelegate.facebookId != nil && [event.going rangeOfString:appDelegate.facebookId].location != NSNotFound)
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
    
    }];
    
}

-(void)refreshGoing
{
    NSArray *going = [self.event.going componentsSeparatedByString:@"|"];
    if([self.event.going length] == 0)
        going = [[NSArray alloc] init];
    
    NSString *goingText = [NSString stringWithFormat:@"Going: %lu", (unsigned long)[going count]];
    if(self.event.maxParticipants > 0)
        goingText = [NSString stringWithFormat:@"%@ (min: %lu, max: %lu)", goingText, (unsigned long)self.event.minParticipants, (unsigned long)self.event.maxParticipants];
    else if (self.event.minParticipants > 1)
        goingText = [NSString stringWithFormat:@"%@ (min: %lu)", goingText, (unsigned long)self.event.minParticipants];
    
    self.goingLabel.text = goingText;
    
    for(UIView *subview in self.peopleView.subviews)
        [subview removeFromSuperview];
    
    for(int i = 0; i < [going count]; i++)
    {
        NSArray *info = [[going objectAtIndex:i] componentsSeparatedByString:@":"];
        if([info count] != 2)
            continue;
        
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(i * 60, 0, 60, 80)];
        
        NSString *facebookId = [info objectAtIndex:0];
        MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) facebookId:facebookId];
        [personView addSubview:pic];
        
        UIView *picBackground = [[UIView alloc] initWithFrame:CGRectMake(35, 32, 20, 20)];
        picBackground.backgroundColor = [UIColor whiteColor];
        picBackground.layer.cornerRadius = 10;
        picBackground.layer.borderColor = [UIColor colorWithRed:7.0/255.0 green:149.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor;
        picBackground.layer.borderWidth = 1;
        [personView addSubview:picBackground];
        
        UIImageView *checkPic = [[UIImageView alloc] initWithFrame:CGRectMake(39, 37, 12, 12)];
        [checkPic setImage:[UIImage imageNamed:@"greenCheck"]];
        [personView addSubview:checkPic];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
        label.text = [info objectAtIndex:1];
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [self.peopleView addSubview:personView];
        self.peopleView.contentSize = CGSizeMake((i + 1) * 60, 80);
    }
    NSMutableArray *invited = [[self.event.invited componentsSeparatedByString:@"|"] mutableCopy];
    if([self.event.invited length] == 0)
    {
        invited = [[NSMutableArray alloc] init];
    }
    else
    {
        for(int i = 0; i < [going count]; i++) {
            NSArray *info = [[going objectAtIndex:i] componentsSeparatedByString:@":"];
            if([info count] != 2)
                continue;
            
            NSString *goingId = [info objectAtIndex:0];
            for(int j = (int)[invited count] - 1; j >= 0; j--) {
                NSString *invitedId = [invited objectAtIndex:j];
                if([invitedId rangeOfString:goingId].location != NSNotFound) {
                    [invited removeObject:invitedId];
                }
            }
        }

    }
    for(int i = 0; i < [invited count]; i++)
    {
        NSArray *info = [[invited objectAtIndex:i] componentsSeparatedByString:@":"];
        if([info count] != 2)
            continue;
        
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(([going count] + i) * 60, 0, 60, 80)];
        
        NSString *facebookId = [info objectAtIndex:0];
        MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) facebookId:facebookId];
        [personView addSubview:pic];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = CGRectMake(0, 0, 50, 50);
        blurEffectView.alpha = .6;
        blurEffectView.layer.cornerRadius = 25;
        blurEffectView.clipsToBounds = YES;
        [blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [personView addSubview:blurEffectView];
        
        UIView *picBackground = [[UIView alloc] initWithFrame:CGRectMake(35, 32, 20, 20)];
        picBackground.backgroundColor = [UIColor whiteColor];
        picBackground.layer.cornerRadius = 10;
        picBackground.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
        picBackground.layer.borderWidth = 1;
        [personView addSubview:picBackground];
        
        UIImageView *invitePic = [[UIImageView alloc] initWithFrame:CGRectMake(37, 34, 16, 15)];
        [invitePic setImage:[UIImage imageNamed:@"invited"]];
        [personView addSubview:invitePic];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
        label.text = [info objectAtIndex:1];
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [self.peopleView addSubview:personView];
        self.peopleView.contentSize = CGSizeMake(([going count] + i + 1) * 60, 80);
    }
    for(int i = (int)[going count]; i < self.event.maxParticipants; i++)
    {
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(([invited count] + i) * 60, 0, 60, 80)];
        
        UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -5, 60, 60)];
        int faceNumber = (arc4random() % 8);
        [pic setImage:[UIImage imageNamed:[NSString stringWithFormat:@"grayface%d", faceNumber]]];
        [personView addSubview:pic];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
        label.text = @"Open";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
        [personView addSubview:label];
        
        [self.peopleView addSubview:personView];
        self.peopleView.contentSize = CGSizeMake(([invited count] + i + 1) * 60, 80);
    }
}

-(void)editButtonClick:(id)sender
{
    MFCreateView *detailView = [[MFCreateView alloc] init:self.event];
    [MFHelpers open:detailView onView:self];
}

-(void)messageButtonClick:(id)sender
{
    MFMessageView *messageView = [[MFMessageView alloc] init:self.event];
    [MFHelpers openFromRight:messageView onView:self];
}

-(void)joinButtonClick:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Notification *notification = [[Notification alloc] init];
    notification.eventId = self.event.eventId;
    notification.facebookId = appDelegate.facebookId;
    
    UIButton *button = (UIButton *)sender;
    if([button.titleLabel.text isEqualToString:@"Join Event"])
    {
        [button setTitle:@"Unjoin Event" forState:UIControlStateNormal];
        
        [self.event addGoing];
        [self refreshGoing];
        
        notification.message = [NSString stringWithFormat:@"Joined: %@", self.event.name];
    }
    else
    {
        
        [button setTitle:@"Join Event" forState:UIControlStateNormal];
        
        [self.event removeGoing];
        [self refreshGoing];
        
        notification.message = [NSString stringWithFormat:@"Unjoined: %@", self.event.name];
    }
    
    [notification save:^(Notification *notification) { }];
    
}
-(void)addFriendsButtonClick:(id)sender
{
    MFAddressBook *addressBook = [[MFAddressBook alloc] init:[NSArray arrayWithObjects:self.event, nil]];
    [MFHelpers open:addressBook onView:self];
}

-(void)cancelButtonClick:(id)sender
{
    if([[self superview] isMemberOfClass:[MFView class]])
    {
        MFView *mfView = (MFView *)[self superview];
        [mfView refreshEvents];
    }
    [MFHelpers close:self];
}

@end
