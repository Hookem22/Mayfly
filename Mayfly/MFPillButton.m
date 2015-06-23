//
//  MFPillButton.m
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFPillButton.h"


@interface MFPillButton()

@property (nonatomic, strong) UIButton *yesButton;
@property (nonatomic, strong) UILabel *yesLabel;
@property (nonatomic, strong) UILabel *noLabel;

@end

@implementation MFPillButton

- (id)initWithFrame:(CGRect)frame yesText:(NSString *)yesText noText:(NSString *)noText
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIButton *backgroundButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [backgroundButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        backgroundButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
        backgroundButton.layer.cornerRadius = frame.size.height / 2;
        backgroundButton.layer.borderWidth = 1.0f;
        backgroundButton.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
        [self addSubview:backgroundButton];
        
        UIButton *yesButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 2, frame.size.width / 2, frame.size.height - 4)];
        [yesButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        yesButton.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
        yesButton.layer.cornerRadius = (frame.size.height - 4) / 2;
        yesButton.tag = 1;
        self.yesButton = yesButton;
        [self addSubview:yesButton];
        
        UILabel *yesLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 10, frame.size.width / 2, 20)];
        yesLabel.text = @"Public";
        yesLabel.textAlignment = NSTextAlignmentCenter;
        yesLabel.textColor = [UIColor whiteColor];
        self.yesLabel = yesLabel;
        [self addSubview:yesLabel];
        
        UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 2, 10, frame.size.width / 2, 20)];
        noLabel.text = @"Private";
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        self.noLabel = noLabel;
        [self addSubview:noLabel];
        
    }
    return self;
}

-(void)switchButton
{
    if(self.yesButton.tag == 1)
    {
        self.yesButton.frame = CGRectMake(self.frame.size.width / 2 - 2, 2, self.frame.size.width / 2, self.frame.size.height - 4);
        self.yesButton.tag = 2;
        self.yesLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        self.noLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        self.yesButton.frame = CGRectMake(2, 2, self.frame.size.width / 2, self.frame.size.height - 4);
        self.yesButton.tag = 1;
        self.yesLabel.textColor = [UIColor whiteColor];
        self.noLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    }
}

-(void)buttonClick:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Public Events"
                                                    message:@"Pow Wow currently does not have enough members near you to create public events. Invite your friends to enable public events."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    /*
    if(self.yesButton.tag == 1)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.yesButton.frame = CGRectMake(self.frame.size.width / 2 - 2, 2, self.frame.size.width / 2, self.frame.size.height - 4);
                         }
                         completion:^(BOOL finished){
                             self.yesButton.tag = 2;
                             self.yesLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
                             self.noLabel.textColor = [UIColor whiteColor];
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.yesButton.frame = CGRectMake(2, 2, self.frame.size.width / 2, self.frame.size.height - 4);
                         }
                         completion:^(BOOL finished){
                             self.yesButton.tag = 1;
                             self.yesLabel.textColor = [UIColor whiteColor];
                             self.noLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
                         }];
    }
    */
}

-(BOOL)isYes
{
    return self.yesButton.tag == 1;
}

@end
