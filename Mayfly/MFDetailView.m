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
@property (nonatomic, strong) UIScrollView *detailView;
@property (nonatomic, strong) UIScrollView *peopleView;
@property (nonatomic, strong) UILabel *goingLabel;
@property (nonatomic, assign) int initialHeight;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *messagesView;
@property (nonatomic, strong) NSMutableDictionary *messageImageViews;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIImageView *muteImage;

@end

@implementation MFDetailView

-(id)init:(Event *)event
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
        
        [self initialSetup:event refresh:YES];
    }
    return self;
}

-(void)nothing:(id)sender {
    
}

-(void)initialSetup:(Event *)event refresh:(BOOL)refresh {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    [MFHelpers addTitleBar:self titleText:event.name];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    int viewY = 0;
    UIScrollView *detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    detailView.backgroundColor = [UIColor whiteColor];
    [self addSubview:detailView];
    self.detailView = detailView;
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
    
    self.initialHeight = viewY;
    if(refresh)
        [self loadEvent:event.eventId];
    else
        [self populate:event];
    
}

-(void)loadEvent:(NSString *)eventId
{
    [Event get:eventId completion:^(Event *event)
    {
        [self populate:event];
    }];
}

-(void)populate:(Event *)event {
    self.event = event;

    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    

    self.menuButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 30, 28, 25, 25)];
    [self.menuButton setImage:[UIImage imageNamed:@"smallmenu"] forState:UIControlStateNormal];
    [self.menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.menuButton];
    
    self.muteImage = [[UIImageView alloc] initWithFrame:CGRectMake(wd - 45, 20, 20, 20)];
    [self.muteImage setImage:[UIImage imageNamed:@"mute"]];
    [self.detailView addSubview:self.muteImage];
    [self updateIsMuted];

    UIScrollView *detailView = self.detailView;
    int viewY = self.initialHeight;
    
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
    [addFriendsButton setTitle:@"Invite Friends or Interests" forState:UIControlStateNormal];
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
    
    UIView *topBorder3 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 1)];
    topBorder3.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [detailView addSubview:topBorder3];
    
    UIView *middle3 = [[UIView alloc] initWithFrame:CGRectMake(0, viewY + 1, wd, 300)];
    middle3.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [detailView addSubview:middle3];
    
    self.detailView = detailView;
    
    self.initialHeight = viewY;
    self.messagesView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 0)];
    [detailView addSubview:self.messagesView];
    [self populateMessages];
    [self loadMessageImages];
}

-(void)loadMessageImages {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    self.messageImageViews = [[NSMutableDictionary alloc] init];
    
    for(Message *message in self.event.messages) {
        if(message.hasImage) {
            NSString *url = [NSString stringWithFormat:@"https://mayflyapp.blob.core.windows.net/messages/%@.jpeg", message.messageId];
            UIImageView *imageView = [[UIImageView alloc] init];
            dispatch_queue_t queue = dispatch_queue_create("Image Queue", NULL);

            dispatch_async(queue, ^{
                NSURL *nsurl = [NSURL URLWithString:url];
                NSData *data = [NSData dataWithContentsOfURL:nsurl];
                UIImage *img = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(img == nil)
                        return;
                    [imageView setImage:img];
                    float imgWd = wd - 60;
                    float imgHt = (imgWd / img.size.width) * img.size.height;
                    imageView.frame = CGRectMake(30, 0, imgWd, imgHt);
                    [self.messageImageViews setObject:imageView forKey:message.messageId];
                    [self refreshMessageImages];
                });
            });
        }
    }
}

-(void)populateMessages {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    for(UIView *subview in self.messagesView.subviews) {
        [subview removeFromSuperview];
    }

    int viewY = 0;
    for(Message *message in self.event.messages) {
        UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 120)];
        messageView.backgroundColor = [UIColor whiteColor];
        [self.messagesView addSubview:messageView];
        
        UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, 1)];
        topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [messageView addSubview:topBorder];
        
        UIView *middle = [[UIView alloc] initWithFrame:CGRectMake(0, 1, wd, 10)];
        middle.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        [messageView addSubview:middle];
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 11, wd, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [messageView addSubview:bottomBorder];
        
        MFProfilePicView *messagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 22, 50, 50) facebookId:message.facebookId];
        [messageView addSubview:messagePic];
        
        UILabel *nameMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 27, wd - 90, 20)];
        nameMessageLabel.text = message.name;
        [messageView addSubview:nameMessageLabel];
        
        UILabel *dateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 52, wd - 90, 20)];
        dateMessageLabel.text = [MFHelpers dateDiffBySeconds:message.secondsSince];
        dateMessageLabel.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        [messageView addSubview:dateMessageLabel];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 92, wd - 60, 20)];
        messageLabel.text = message.message;
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.tag = 1;
        [messageLabel sizeToFit];
        [messageView addSubview:messageLabel];
        
        int imgHt = 0;
        if(message.hasImage) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(60, messageLabel.frame.size.height + 102, 80, 80);
            [imageView setImage:[UIImage imageNamed:@"portrait"]];
            [messageView addSubview:imageView];
            imageView.tag = 2;
            imgHt = imageView.frame.size.height + 10;
        }
        
        if(messageLabel.frame.size.height + imgHt + 102 > messageView.frame.size.height) {
            messageView.frame = CGRectMake(0, viewY, wd, messageLabel.frame.size.height + imgHt + 112);
        }
        //Bottom border
        Message *lastMessage = self.event.messages[self.event.messages.count - 1];
        if([message.messageId isEqualToString:lastMessage.messageId] && !message.hasImage) {
            UIView *topBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, messageView.frame.size.height, wd, 1)];
            topBorder2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            [messageView addSubview:topBorder2];
            
            UIView *middle2 = [[UIView alloc] initWithFrame:CGRectMake(0, messageView.frame.size.height + 1, wd, 300)];
            middle2.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
            [messageView addSubview:middle2];
            messageView.frame = CGRectMake(messageView.frame.origin.x, messageView.frame.origin.y, messageView.frame.size.width, messageView.frame.size.height + 40);
        }
        
        viewY += messageView.frame.size.height;
        
        [message markViewed];
    }
    
    self.detailView.contentSize = CGSizeMake(wd, self.initialHeight + viewY);
    self.messagesView.frame = CGRectMake(0, self.messagesView.frame.origin.y, self.messagesView.frame.size.width, viewY);
}

-(void)refreshMessageImages {
    int viewY = 0;
    int i = 0;
    for(UIView *messageView in self.messagesView.subviews) {
        Message *message = self.event.messages[i];
        messageView.frame = CGRectMake(0, viewY, messageView.frame.size.width, messageView.frame.size.height);
        if(message.hasImage) {
            int messageLabelHt = 0;
            for(UIView *subview in messageView.subviews) {
                if(subview.tag == 1) {
                    messageLabelHt = subview.frame.size.height;
                }
            }
            int imgHt = 0;
            for(UIView *subview in messageView.subviews) {
                if ([subview isMemberOfClass:[UIImageView class]] && subview.tag == 2) {
                    UIImageView *imageView = (UIImageView *)subview;
                    UIImageView *imageViewWithPic = (UIImageView *)[self.messageImageViews objectForKey:message.messageId];
                    if(imageViewWithPic != nil) {
                        [imageView setImage:imageViewWithPic.image];
                        imageView.frame = CGRectMake(30, messageLabelHt + 102, imageViewWithPic.frame.size.width, imageViewWithPic.frame.size.height);
                        
                        imgHt = imageView.frame.size.height + 20;
                    }
                }
            }
            
            if(messageLabelHt + imgHt + 102 > messageView.frame.size.height) {
                messageView.frame = CGRectMake(0, viewY, messageView.frame.size.width, messageLabelHt + imgHt + 112);
            }
        }
        viewY += messageView.frame.size.height;
        i++;
    }
    
    self.detailView.contentSize = CGSizeMake(self.detailView.frame.size.width, self.initialHeight + viewY);
    self.messagesView.frame = CGRectMake(0, self.messagesView.frame.origin.y, self.messagesView.frame.size.width, viewY);
}

-(void)refreshGoing
{
    
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
        label.text = [person.firstName isMemberOfClass:[NSNull class]] ? @"" : person.firstName;
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [self.peopleView addSubview:personView];
        viewX += 60;
    }
    
    int invitedCt = 0;
    for(EventGoing *person in self.event.invited)
    {
        if([person.facebookId isMemberOfClass:[NSNull class]] || person.facebookId.length == 0)
            continue;
        
        BOOL isGoing = NO;
        for(EventGoing *going in self.event.going)
        {
            if([going.userId isEqualToString:person.userId] || [going.facebookId isEqualToString:person.facebookId]) {
                isGoing = YES;
                break;
            }
        }
        if(isGoing)
            continue;
        
        invitedCt++;
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
    
    NSString *goingText = [NSString stringWithFormat:@"Going: %lu | Invited: %i", (unsigned long)self.event.going.count, invitedCt];
    self.goingLabel.text = goingText;
    
    if(self.event.isGoing) {
        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        self.menuButton.frame = CGRectMake(wd - 30, 28, 25, 25);
    }
    else {
        self.menuButton.frame = CGRectMake(0, 0, 0, 0);
    }
    
}

-(void)joinButtonClick:(id)sender
{
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    Notification *notification = [[Notification alloc] init];
    notification.eventId = self.event.eventId;
    notification.userId = currentUser.userId;
    
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
        
        MFCalendarAccess *addToCalendar = [[MFCalendarAccess alloc] init];
        [self addSubview:addToCalendar];
        [addToCalendar addToCalendar:self.event];
        
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
    [MFHelpers open:view onView:self.superview];
}

-(void)menuButtonClick:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
    self.menuView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.menuView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeMenu)];
    [self.menuView addGestureRecognizer:singleTap];
    
    if(self.event.isAdmin) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(20, ht - 180, wd - 40, 100)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.layer.cornerRadius = 5;
        [self.menuView addSubview:backgroundView];
        
        UIButton *muteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [muteButton addTarget:self action:@selector(muteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        muteButton.frame = CGRectMake(5, 0, backgroundView.frame.size.width - 10, 50);
        [muteButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
        self.muteButton = muteButton;
        [backgroundView addSubview:muteButton];
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [editButton setTitle:@"Edit Event" forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        editButton.frame = CGRectMake(5, 50, backgroundView.frame.size.width - 10, 50);
        [editButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
        [backgroundView addSubview:editButton];
        
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 50, backgroundView.frame.size.width, 1)];
        border.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [backgroundView addSubview:border];
    }
    else {
        UIButton *muteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [muteButton addTarget:self action:@selector(muteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        muteButton.frame = CGRectMake(20, ht - 130, wd - 40, 50);
        [muteButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
        muteButton.backgroundColor = [UIColor whiteColor];
        muteButton.layer.cornerRadius = 5.0;
        self.muteButton = muteButton;
        [self.menuView addSubview:muteButton];
    }
    
    [self updateIsMuted];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.frame = CGRectMake(20, ht - 70, wd - 40, 50);
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    cancelButton.layer.cornerRadius = 5;
    [self.menuView addSubview:cancelButton];
    
}

-(void)closeMenu
{
    [self.menuView removeFromSuperview];
}

-(void)editButtonClick:(id)sender
{
    MFCreateView *createView = [[MFCreateView alloc] init:self.event];
    [MFHelpers open:createView onView:self];
    [self closeMenu];
}

-(void)muteButtonClick:(id)sender {
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    for(EventGoing *going in self.event.going) {
        if([going.userId isEqualToString:currentUser.userId]) {
            going.isMuted = !going.isMuted;
            [going save:^(EventGoing *going) { }];
        }
    }
    
    self.event.isMuted = !self.event.isMuted;
    [self updateIsMuted];
    [self closeMenu];
}

-(void)updateIsMuted {
    NSString *muteText = self.event.isMuted ? @"Unmute Event" : @"Mute Event";
    [self.muteButton setTitle:muteText forState:UIControlStateNormal];
    
    if(self.event.isMuted) {
        NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
        self.muteImage.frame = CGRectMake(wd - 45, 20, 20, 20);
    }
    else {
        self.muteImage.frame = CGRectMake(0, 0, 0, 0);
    }
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
        
//        NSString *msg = [NSString stringWithFormat:@"New event in %@", group.name];
//        NSString *info = [NSString stringWithFormat:@"Invitation|%@", self.event.eventId];
//        [group sendMessageToGroup:msg info:info];
    }
    
    if(newGroups.count > 0) {
        [Group inviteGroups:newGroups event:self.event completion:^(Event *event) {
            //self.event.invited = [NSArray arrayWithArray:event.invited];
            [self refreshGoing];
        }];
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
        [mfView refresh];
    }
}

-(void)cancelButtonClick:(id)sender
{
    [Group clearIsInvitedToEvent];
    [MFHelpers closeRight:self];
}

@end
