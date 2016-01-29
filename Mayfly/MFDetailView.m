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
@property (nonatomic, strong) UIView *detailView;
@property (nonatomic, strong) UIScrollView *peopleView;
@property (nonatomic, strong) UILabel *goingLabel;

@end

@implementation MFDetailView

-(id)init:(NSString *)eventId
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:recognizer];
        
        UISwipeGestureRecognizer *recognizer2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
        [recognizer2 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:recognizer2];
        
        [self setup:eventId];
    }
    return self;
}

-(void)nothing:(id)sender {
    
}

-(void)reset:(NSString *)eventId {
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    [self setup:eventId];
}

-(void)setup:(NSString *)eventId
{
    [Event get:eventId completion:^(Event *event)
    {
        self.event = event;
        
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
        
        
//        self.messageButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 45, 25, 35, 30)];
//        [self.messageButton setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
//        [self.messageButton addTarget:self action:@selector(messageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.messageButton];
//
//        [Message get:self.event.eventId completion:^(NSArray *messages)
//         {
//             if([messages count] > 0)
//                 [self.messageButton setImage:[UIImage imageNamed:@"newmessage"] forState:UIControlStateNormal];
//         }];
        
        int viewY = 0;
        UIScrollView *detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
        detailView.backgroundColor = [UIColor whiteColor];
        [self addSubview:detailView];
        viewY += 20;
        
        UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 20)];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"EEE, MMM d - h:mm a"];
        detailsLabel.text = [NSString stringWithFormat:@"%@", [outputFormatter stringFromDate:event.startTime]];
        detailsLabel.textAlignment = NSTextAlignmentCenter;
        [detailView addSubview:detailsLabel];
        viewY += 40;
        
        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [joinButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
        [joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        joinButton.frame = CGRectMake(30, viewY, wd - 60, 40);
        joinButton.layer.cornerRadius = 4.0f;
        joinButton.layer.borderWidth = 2.0f;
        [detailView addSubview:joinButton];
        viewY += 50;
        
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
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 20)];
        descriptionLabel.text = [event.description stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [descriptionLabel sizeToFit];
        [detailView addSubview:descriptionLabel];
        viewY += descriptionLabel.frame.size.height;
        viewY += 20;
        
        UIView *topBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
        topBorder1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [detailView addSubview:topBorder1];
        viewY += 1;
        
        UIView *middle1 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 10)];
        middle1.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        [detailView addSubview:middle1];
        viewY += 10;
        
        UIView *bottomBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
        bottomBorder1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [detailView addSubview:bottomBorder1];
        viewY += 20;
        
        UILabel *goingLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 20)];
        goingLabel.textAlignment = NSTextAlignmentCenter;
        self.goingLabel = goingLabel;
        [detailView addSubview:goingLabel];
        viewY += 30;
        
        self.peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, viewY, wd, 80)];
        [detailView addSubview:self.peopleView];
        [self refreshGoing];
        viewY += 80;
        
        UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addFriendsButton setTitle:@"Invite Friends or Groups" forState:UIControlStateNormal];
        [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        addFriendsButton.frame = CGRectMake(30, viewY, wd-60, 30);
        [addFriendsButton.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
        [detailView addSubview:addFriendsButton];
        viewY += 40;
        
        UIView *topBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
        topBorder2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [detailView addSubview:topBorder2];
        viewY += 1;
        
        UIView *middle2 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 10)];
        middle2.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        [detailView addSubview:middle2];
        viewY += 10;
        
        UIView *bottomBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
        bottomBorder2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [detailView addSubview:bottomBorder2];
        
        UIButton *postMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd, 70)];
        [postMessageButton addTarget:self action:@selector(postMessageClick:) forControlEvents:UIControlEventTouchUpInside];
        [detailView addSubview:postMessageButton];
        viewY += 70;
        
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        MFProfilePicView *postMessagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 10, 50, 50) facebookId:currentUser.facebookId];
        [postMessageButton addSubview:postMessagePic];
        
        UILabel *postMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 25, wd - 90, 20)];
        postMessageLabel.text = @"Say something...";
        postMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        [postMessageButton addSubview:postMessageLabel];
        
         for(Message *message in event.messages) {
             UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
             topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
             [detailView addSubview:topBorder];
             viewY += 1;
             
             UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 10)];
             middle.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
             [detailView addSubview:middle];
             viewY += 10;
             
             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
             [detailView addSubview:bottomBorder];
             viewY += 1;
             
             UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 120)];
             [detailView addSubview:messageView];
             
             MFProfilePicView *messagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 10, 50, 50) facebookId:message.facebookId];
             [messageView addSubview:messagePic];
             
             UILabel *nameMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 15, wd - 90, 20)];
             nameMessageLabel.text = message.name;
             [messageView addSubview:nameMessageLabel];
             
             UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, wd - 90, 20)];
             dateMessageLabel.text = [MFHelpers dateDiffBySeconds:message.secondsSince];
             dateMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
             [messageView addSubview:dateMessageLabel];
             
             UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, wd - 60, 20)];
             messageLabel.text = message.message;
             messageLabel.numberOfLines = 0;
             messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
             [messageLabel sizeToFit];
             [messageView addSubview:messageLabel];
             
             if(messageLabel.frame.size.height + 90 > messageView.frame.size.height) {
                 messageView.frame = CGRectMake(0, viewY, wd, messageLabel.frame.size.height + 100);
             }
             viewY += messageView.frame.size.height;
         }
        
        UIView *topBorder3 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
        topBorder3.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [detailView addSubview:topBorder3];
        viewY += 1;
        
        UIView *middle3 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 300)];
        middle3.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        [detailView addSubview:middle3];
        viewY += 30;

        detailView.contentSize = CGSizeMake(wd, viewY);
        self.detailView = detailView;
        
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

    NSString *goingText = [NSString stringWithFormat:@"Going: %i | Invited: %i", self.event.going.count, self.event.invited.count];
    self.goingLabel.text = goingText;
    
    for(UIView *subview in self.peopleView.subviews)
        [subview removeFromSuperview];

    int viewX = 0;
    for(EventGoing *person in self.event.going)
    {
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(viewX, 0, 60, 80)];
        
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
        viewX += 60;
    }
    
    for(EventGoing *person in self.event.invited)
    {
        if(person.facebookId.length == 0)
            continue;
        
        BOOL isGoing = NO;
        for(EventGoing *going in self.event.going)
        {
            if([going.userId isEqualToString:person.userId]) {
                isGoing = YES;
                break;
            }
        }
        if(isGoing)
            continue;
        
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(viewX, 0, 60, 80)];
        
        NSString *facebookId = person.facebookId;
        MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) facebookId:facebookId];
        [personView addSubview:pic];
        
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
        label.text = person.firstName;
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [self.peopleView addSubview:personView];
        viewX += 60;
    }
    viewX += 40;
    
    self.peopleView.contentSize = CGSizeMake(viewX, 80);
    self.peopleView.contentOffset = CGPointMake(-30, 0);
    
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

//-(void)messageButtonClick:(id)sender
//{
//    MFMessageView *messageView = [[MFMessageView alloc] init:self.event];
//    [MFHelpers openFromRight:messageView onView:self];
//    [self.messageButton setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
//}

-(void)joinButtonClick:(id)sender
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    Notification *notification = [[Notification alloc] init];
    notification.eventId = self.event.eventId;
    notification.facebookId = currentUser.facebookId;
    
    UIButton *button = (UIButton *)sender;
    if([button.titleLabel.text isEqualToString:@"+ JOIN EVENT"])
    {
        [button setTitle:@"GOING" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        button.layer.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        
        [self.event addGoing:currentUser.userId isAdmin:NO];
        
        EventGoing *person = [[EventGoing alloc] init];
        person.firstName = currentUser.firstName;
        person.facebookId = currentUser.facebookId;
        person.userId = currentUser.userId;
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
        
        [self.event removeGoing:currentUser.userId];
        
        NSMutableArray *going = [[NSMutableArray alloc] init];
        for(EventGoing *eventGoing in self.event.going)
        {
            if(![eventGoing.userId isEqualToString:currentUser.userId])
                [going addObject:eventGoing];
        }
        self.event.going = [[NSArray alloc] initWithArray:going];
        
        [self refreshGoing];
        
        notification.message = [NSString stringWithFormat:@"Unjoined: %@", self.event.name];
    }
    
    [notification save:^(Notification *notification) {
        [self refreshEventsScreen];
    }];
    
}
-(void)addFriendsButtonClick:(id)sender
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    for(NSString *groupId in [self.event.groupId componentsSeparatedByString: @"|"]) {
        for(Group *group in currentUser.groups) {
            if([groupId isEqualToString:group.groupId]) {
                group.isInvitedtoEvent = true;
                break;
            }
        }
    }
    
    MFAddressBook *addressBook = [[MFAddressBook alloc] init:[NSArray arrayWithObjects:self.event, nil]];
    [MFHelpers open:addressBook onView:self];
}

-(void)postMessageClick:(id)sender {
    MFPostMessageView *view = [[MFPostMessageView alloc] init:self.event];
    [MFHelpers open:view onView:self];
}

-(void)addGroupsToEvent:(NSArray *)groups {
    NSMutableArray *newGroups = [[NSMutableArray alloc] init];
    for (Group *group in groups) {
        if([self.event.groupId rangeOfString:group.groupId].location == NSNotFound) {
            [newGroups addObject:group];
        }
    }
    
    for(Group *group in newGroups) {
        self.event.groupId = self.event.groupId.length == 0 ? group.groupId : [NSString stringWithFormat:@"%@|%@", self.event.groupId, group.groupId];
        self.event.groupName = self.event.groupName.length == 0 ? group.name : [NSString stringWithFormat:@"%@|%@", self.event.groupName, group.name];
        if(self.event.groupPictureUrl.length == 0 && group.pictureUrl.length > 0)
            self.event.groupPictureUrl = group.pictureUrl;
        if(group.isPublic == true)
            self.event.groupIsPublic = true;
        
        NSString *msg = [NSString stringWithFormat:@"New event in %@", group.name];
        NSString *info = [NSString stringWithFormat:@"Invitation|%@", self.event.eventId];
        [group sendMessageToGroup:msg info:info];
    }

    [self.event save:^(Event *event)
     {
         [self refreshEventsScreen];
     }];
}

-(void)refreshEventsScreen {
    if([[self superview] isMemberOfClass:[MFView class]])
    {
        MFView *mfView = (MFView *)[self superview];
        [mfView refreshEvents];
    }
}

-(void)cancelButtonClick:(id)sender
{
    [Group clearIsInvitedToEvent];
    [MFHelpers closeRight:self];
}

@end
