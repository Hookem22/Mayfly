//
//  MFPostMessageView.m
//  Pow Wow
//
//  Created by Will Parks on 1/27/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "MFPostMessageView.h"

@interface MFPostMessageView ()

@property (atomic, strong) Event *event;
@property (atomic, strong) UIScrollView *contentView;
@property (atomic, strong) UITextView *messageText;
@property (atomic, strong) UIImageView *imageView;

@end

@implementation MFPostMessageView

-(id)init:(Event *)event
{
    self = [super init];
    if (self) {
        self.event = event;
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

-(void)setup {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
    [self addGestureRecognizer:singleTap];
    
    self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, wd, ht - 60)];
    [self addSubview:self.contentView];
    
    [MFHelpers addTitleBar:self titleText:self.event.name];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeRight:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    int viewY = 20;
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    MFProfilePicView *postMessagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, viewY, 50, 50) facebookId:currentUser.facebookId];
    [self.contentView addSubview:postMessagePic];
    viewY += 15;
    
    UILabel *postMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, viewY, wd - 90, 20)];
    postMessageLabel.text = currentUser.firstName;
    [self.contentView addSubview:postMessageLabel];
    
    
    UIButton *imageButton = [[UIButton alloc] initWithFrame:CGRectMake(wd - 56, viewY, 26, 20)];
    [imageButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [imageButton addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:imageButton];
    viewY += 55;
    
    UITextView *messageText = [[UITextView alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 120)];
    [messageText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [messageText.layer setBorderWidth:1.0];
    [messageText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    messageText.font = [UIFont systemFontOfSize:15];
    messageText.layer.cornerRadius = 5;
    messageText.clipsToBounds = YES;
    self.messageText = messageText;
    [self.contentView addSubview:messageText];
    [messageText becomeFirstResponder];
    viewY += 130;
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(30, viewY, wd - 60, 40)];
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [postButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    postButton.layer.cornerRadius = 20;
    postButton.layer.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor;
    [self.contentView addSubview:postButton];
}

-(void)postButtonClick:(id)sender
{
    if([self.messageText.text length] > 0 || self.imageView != nil)
    {
        [MFHelpers showDisableView:self];
        
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        
        Message *message = [[Message alloc] init];
        message.eventId = self.event.eventId;
        message.userId = currentUser.userId;
        message.facebookId = currentUser.facebookId;
        message.name = currentUser.firstName;
        message.message = self.messageText.text;
        message.viewedBy = currentUser.userId;
        message.sentDate = [NSDate date];
        message.hasImage = self.imageView != nil;
        
        [message save:^(Message *newMessage)
         {
             if(newMessage.hasImage){
                 [newMessage addImage:self.imageView.image completion:^(NSURL *url) {
                     [self refreshEvent:message];
                 }];
             }
             else {
                 [self refreshEvent:message];
             }
         }];
    }
    
    [self endEditing:YES];
}

-(void)refreshEvent:(Message *)message {
    message.secondsSince = 0;
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    [messages addObject:message];
    for(Message *m in self.event.messages) {
        [messages addObject:m];
    }
    self.event.messages = messages;
    
    for(UIView *subview in self.superview.subviews) {
        if([subview isMemberOfClass:[MFDetailView class]]) {
            MFDetailView *detailView = (MFDetailView *)subview;
            [detailView initialSetup:self.event refresh:NO];
        }
    }

    [MFHelpers close:self];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    [self.event sendMessageToEvent:[NSString stringWithFormat:@"%@: %@", currentUser.firstName, message.message] info:[NSString stringWithFormat: @"New Message|%@", message.eventId]];
}

- (void)imageButtonClick:(id)sender {
    ViewController *vc = (ViewController *)self.window.rootViewController;
    [vc selectMessagePhoto];
}

-(void)newImage:(UIImage *)img {
    [self endEditing:YES];
    
    float imgWd = self.messageText.frame.size.width;
    float imgHt = (imgWd / img.size.width) * img.size.height;
    
    self.imageView = [[UIImageView alloc] initWithImage:img];
    [self.imageView setFrame:CGRectMake(30, 330, imgWd, imgHt)];
    [self.contentView addSubview:self.imageView];
    self.contentView.contentSize = CGSizeMake(imgWd + 60, imgHt + 350);
}

-(void)dismissKeyboard:(id)sender {
    [self endEditing:YES];
}

-(void)closeRight:(id)sender
{
    [self endEditing:YES];
    [MFHelpers closeRight:self];
}

-(void)cancelButtonClick:(id)sender
{
    [self endEditing:YES];
    [MFHelpers close:self];
}

@end
