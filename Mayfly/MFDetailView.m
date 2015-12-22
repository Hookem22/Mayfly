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
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) UIScrollView *peopleView;
@property (nonatomic, strong) UILabel *goingLabel;

@end

@implementation MFDetailView

-(id)init:(NSString *)eventId
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:recognizer];
        
        [self setup:eventId];
    }
    return self;
}

-(void)setup:(NSString *)eventId
{
    [Event get:eventId completion:^(Event *event)
    {
        self.event = event;

        [EventGoing getByEventId:event.eventId completion:^(NSArray *goings) {
            event.going = goings;
            NSLog(@"%@", event);
        }];
        
        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
        
//        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//
//
//        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, wd - 150, 20)];
//        headerLabel.textAlignment = NSTextAlignmentCenter;
//        headerLabel.text = event.name;
//        [self addSubview:headerLabel];
//
//        //if(appDelegate.facebookId != nil && [event.going rangeOfString:appDelegate.facebookId].location == 0 && event.isPrivate)
//        {
//            float headerWd = [headerLabel.text boundingRectWithSize:headerLabel.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:headerLabel.font } context:nil].size.width;
//            float totalWd = [[NSString stringWithFormat:@"%@ - Edit", headerLabel.text] boundingRectWithSize:headerLabel.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:headerLabel.font } context:nil].size.width;
//            
//            CGRect editFrame = CGRectMake(wd / 2 - 15, 40, 30, 20);
//            NSString *editTitle = @"Edit";
//            if(totalWd > 0) {
//                headerLabel.frame = CGRectMake((wd - totalWd) / 2, 20, headerWd, 20);
//                editFrame = CGRectMake(((wd - totalWd) / 2) + headerWd, 20, totalWd - headerWd, 20);
//                editTitle = @" - Edit";
//            }
//
//            UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [editButton setTitle:editTitle forState:UIControlStateNormal];
//            [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            editButton.frame = editFrame;
//            [self addSubview:editButton];
//        }
//
//        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [cancelButton setTitle:@"Done" forState:UIControlStateNormal];
//        [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        cancelButton.frame = CGRectMake(15, 10, 80, 40);
//        [cancelButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
//        [self addSubview:cancelButton];
        
        [MFHelpers addTitleBar:self titleText:event.name];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
        [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelButton];
        
        
        self.messageButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 45, 25, 35, 30)];
        [self.messageButton setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [self.messageButton addTarget:self action:@selector(messageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.messageButton];

        [Message get:self.event.eventId completion:^(NSArray *messages)
         {
             if([messages count] > 0)
                 [self.messageButton setImage:[UIImage imageNamed:@"newmessage"] forState:UIControlStateNormal];
         }];
        
        UIScrollView *detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, wd, ht - 80)];
        [self addSubview:detailView];

        UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, wd - 60, 20)];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"EEE h:mm a"];
        detailsLabel.text = [NSString stringWithFormat:@"%@ - %@", [outputFormatter stringFromDate:event.startTime], event.location.name];
        detailsLabel.textAlignment = NSTextAlignmentCenter;
        [detailView addSubview:detailsLabel];
        
        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [joinButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
        [joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        joinButton.frame = CGRectMake(30, 40, wd - 60, 40);
        joinButton.layer.cornerRadius = 4.0f;
        joinButton.layer.borderWidth = 2.0f;
        [detailView addSubview:joinButton];
        
        if(![event isGoing])
        {
            [joinButton setTitle:@"+ JOIN EVENT" forState:UIControlStateNormal];
            [joinButton setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            joinButton.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
            joinButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
        }
        else
        {
            [joinButton setTitle:@"GOING" forState:UIControlStateNormal];
            [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            joinButton.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
            joinButton.layer.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        }
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 90, wd - 60, 20)];
        descriptionLabel.text = event.description;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [descriptionLabel sizeToFit];
        [detailView addSubview:descriptionLabel];

        int descHt = descriptionLabel.frame.size.height;
        
        NSString *goingText = [NSString stringWithFormat:@"Going %i", [event.going count]];
        if(event.minParticipants > 0 && event.maxParticipants > 0)
            goingText = [NSString stringWithFormat:@"%@ (Min: %i Max: %i)", goingText, event.minParticipants, event.maxParticipants];
        else if(event.minParticipants > 0)
            goingText = [NSString stringWithFormat:@"%@ (Min: %i)", goingText, event.minParticipants];
        else if(event.maxParticipants > 0)
            goingText = [NSString stringWithFormat:@"%@ (Max: %i)", goingText, event.maxParticipants];
        
        UILabel *goingLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 110 + descHt, wd - 60, 20)];
        goingLabel.textAlignment = NSTextAlignmentCenter;
        goingLabel.text = goingText;
        self.goingLabel = goingLabel;
        [detailView addSubview:goingLabel];

        self.peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(30, 140 + descHt, wd - 60, 80)];
        [detailView addSubview:self.peopleView];
        [self refreshGoing];

        UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addFriendsButton setTitle:@"Invite Friends or Groups" forState:UIControlStateNormal];
        [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        addFriendsButton.frame = CGRectMake(30, 225 + descHt, wd-60, 30);
        [addFriendsButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
        [detailView addSubview:addFriendsButton];


//        NSString *title = @"Join Event";
        //if(appDelegate.facebookId != nil && [event.going rangeOfString:appDelegate.facebookId].location != NSNotFound)
        //    title = @"Unjoin Event";
            
//        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [joinButton setTitle:title forState:UIControlStateNormal];
//        [joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        joinButton.frame = CGRectMake(0, ht - 60, wd, 60);
//        [self addSubview:joinButton];

//        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 1.0f, wd, 1)];
//        topBorder.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
//        [joinButton addSubview:topBorder];


        if(![FBSDKAccessToken currentAccessToken])
        {
            MFLoginView *loginView = [[MFLoginView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
            [self addSubview:loginView];
        }
    
    }];
    
}

-(void)refreshGoing
{
    NSArray *going = self.event.going;
    if(going.count == 0)
        going = [[NSArray alloc] init];

    NSString *goingText = [NSString stringWithFormat:@"Going: %lu", (unsigned long)[going count]];
    if(self.event.maxParticipants > 0 && self.event.minParticipants > 1)
        goingText = [NSString stringWithFormat:@"%@ (Min: %lu, Max: %lu)", goingText, (unsigned long)self.event.minParticipants, (unsigned long)self.event.maxParticipants];
    else if (self.event.minParticipants > 1)
        goingText = [NSString stringWithFormat:@"%@ (Min: %lu)", goingText, (unsigned long)self.event.minParticipants];
    else if(self.event.maxParticipants > 0)
        goingText = [NSString stringWithFormat:@"%@ (Max: %lu)", goingText, (unsigned long)self.event.maxParticipants];

    
    self.goingLabel.text = goingText;
    
    for(UIView *subview in self.peopleView.subviews)
        [subview removeFromSuperview];

    for(int i = 0; i < [going count]; i++)
    {
        EventGoing *person = [going objectAtIndex:i];
        
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(i * 60, 0, 60, 80)];
        
        NSString *facebookId = person.facebookId;
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
        label.text = person.firstName;
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [self.peopleView addSubview:personView];
        self.peopleView.contentSize = CGSizeMake((i + 1) * 60, 80);
    }
//    NSMutableArray *invited = [[self.event.invited componentsSeparatedByString:@"|"] mutableCopy];
//    if([self.event.invited length] == 0)
//    {
//        invited = [[NSMutableArray alloc] init];
//    }
//    else
//    {
//        for(int i = 0; i < [going count]; i++) {
//            NSArray *info = [[going objectAtIndex:i] componentsSeparatedByString:@":"];
//            if([info count] != 2)
//                continue;
//            
//            NSString *goingId = [info objectAtIndex:0];
//            for(int j = (int)[invited count] - 1; j >= 0; j--) {
//                NSString *invitedId = [invited objectAtIndex:j];
//                if([invitedId rangeOfString:goingId].location != NSNotFound) {
//                    [invited removeObject:invitedId];
//                }
//            }
//        }
//
//    }
//    for(int i = 0; i < [invited count]; i++)
//    {
//        NSArray *info = [[invited objectAtIndex:i] componentsSeparatedByString:@":"];
//        if([info count] != 2)
//            continue;
//        
//        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(([going count] + i) * 60, 0, 60, 80)];
//        
//        NSString *facebookId = [info objectAtIndex:0];
//        MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) facebookId:facebookId];
//        [personView addSubview:pic];
//        
//        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        blurEffectView.frame = CGRectMake(0, 0, 50, 50);
//        blurEffectView.alpha = .6;
//        blurEffectView.layer.cornerRadius = 25;
//        blurEffectView.clipsToBounds = YES;
//        [blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [personView addSubview:blurEffectView];
//        
//        UIView *picBackground = [[UIView alloc] initWithFrame:CGRectMake(35, 32, 20, 20)];
//        picBackground.backgroundColor = [UIColor whiteColor];
//        picBackground.layer.cornerRadius = 10;
//        picBackground.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
//        picBackground.layer.borderWidth = 1;
//        [personView addSubview:picBackground];
//        
//        UIImageView *invitePic = [[UIImageView alloc] initWithFrame:CGRectMake(37, 34, 16, 15)];
//        [invitePic setImage:[UIImage imageNamed:@"invited"]];
//        [personView addSubview:invitePic];
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
//        label.text = [info objectAtIndex:1];
//        label.textAlignment = NSTextAlignmentCenter;
//        [personView addSubview:label];
//        
//        [self.peopleView addSubview:personView];
//        self.peopleView.contentSize = CGSizeMake(([going count] + i + 1) * 60, 80);
//    }
//    for(int i = (int)[going count]; i < self.event.maxParticipants; i++)
//    {
//        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(([invited count] + i) * 60, 0, 60, 80)];
//        
//        UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -5, 60, 60)];
//        int faceNumber = (arc4random() % 8);
//        [pic setImage:[UIImage imageNamed:[NSString stringWithFormat:@"grayface%d", faceNumber]]];
//        [personView addSubview:pic];
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-6, 50, 62, 20)];
//        label.text = @"Open";
//        label.textAlignment = NSTextAlignmentCenter;
//        label.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];
//        [personView addSubview:label];
//        
//        [self.peopleView addSubview:personView];
//        self.peopleView.contentSize = CGSizeMake(([invited count] + i + 1) * 60, 80);
//    }
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
    [self.messageButton setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
}

-(void)joinButtonClick:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    Notification *notification = [[Notification alloc] init];
    notification.eventId = self.event.eventId;
    notification.facebookId = appDelegate.facebookId;
    
    UIButton *button = (UIButton *)sender;
    if([button.titleLabel.text isEqualToString:@"+ JOIN EVENT"])
    {
        [button setTitle:@"GOING" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        button.layer.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        
        [self.event addGoing:appDelegate.userId isAdmin:NO];
        
        EventGoing *person = [[EventGoing alloc] init];
        person.firstName = appDelegate.firstName;
        person.facebookId = appDelegate.facebookId;
        person.userId = appDelegate.userId;
        NSMutableArray *going = [[NSMutableArray alloc] initWithArray:self.event.going];
        [going addObject:person];
        self.event.going = [[NSArray alloc] initWithArray:going];
        
        [self refreshGoing];
        
        notification.message = [NSString stringWithFormat:@"Joined: %@", self.event.name];
    }
    else
    {
        
        [button setTitle:@"+ JOIN EVENT" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
        button.layer.backgroundColor = [UIColor whiteColor].CGColor;
        
        [self.event removeGoing:appDelegate.userId];
        
        NSMutableArray *going = [[NSMutableArray alloc] init];
        for(EventGoing *eventGoing in self.event.going)
        {
            if(![eventGoing.userId isEqualToString:appDelegate.userId])
                [going addObject:eventGoing];
        }
        self.event.going = [[NSArray alloc] initWithArray:going];
        
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
    [MFHelpers closeRight:self];
}

@end
