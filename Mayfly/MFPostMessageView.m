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
@property (atomic, strong) UITextView *messageText;

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
    
    [MFHelpers addTitleBar:self titleText:self.event.name];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeRight:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    MFProfilePicView *postMessagePic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(30, 80, 50, 50) facebookId:currentUser.facebookId];
    [self addSubview:postMessagePic];
    
    UILabel *postMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 95, wd - 90, 20)];
    postMessageLabel.text = currentUser.firstName;
    [self addSubview:postMessageLabel];
    
    UITextView *messageText = [[UITextView alloc] initWithFrame:CGRectMake(30, 150, wd - 60, 120)];
    [messageText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [messageText.layer setBorderWidth:1.0];
    [messageText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    messageText.font = [UIFont systemFontOfSize:15];
    messageText.layer.cornerRadius = 5;
    messageText.clipsToBounds = YES;
    self.messageText = messageText;
    [self addSubview:messageText];
    [messageText becomeFirstResponder];
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 280, wd - 60, 40)];
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(postButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [postButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    postButton.layer.cornerRadius = 20;
    postButton.layer.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor;
    [self addSubview:postButton];
}

-(void)postButtonClick:(id)sender
{
    if([self.messageText.text length] > 0)
    {
        [MFHelpers showProgressView:self];
        
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        
        Message *message = [[Message alloc] init];
        message.eventId = self.event.eventId;
        message.userId = currentUser.userId;
        message.facebookId = currentUser.facebookId;
        message.name = currentUser.firstName;
        message.message = self.messageText.text;
        message.viewedBy = currentUser.userId;
        message.sentDate = [NSDate date];
        
        [message save:^(Message *newMessage)
         {
             MFDetailView *detailView = (MFDetailView *)self.superview;
             [detailView initialSetup:self.event];

             [MFHelpers hideProgressView:self];
             [MFHelpers close:self];
             
              [self.event sendMessageToEvent:[NSString stringWithFormat:@"%@: %@", currentUser.firstName, message.message] info:[NSString stringWithFormat: @"New Message|%@", message.eventId]];
         }];
    }
    
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
