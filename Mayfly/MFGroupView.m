//
//  MFGroupsView.m
//  Pow Wow
//
//  Created by Will Parks on 12/28/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "MFGroupView.h"

@interface MFGroupView ()

@property (nonatomic, strong) NSMutableArray *Groups;
@property (nonatomic, assign) long currentIndex;

@end

@implementation MFGroupView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:57.0/255.0 blue:74.0/255.0 alpha:1.0];
        self.delegate = self;
        self.Groups = [[NSMutableArray alloc] init];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeGroups:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:recognizer];
        
        UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
        [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:recognizer1];
    }
    return self;
}

-(void)loadGroups
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    int viewY = 0;
    UIControl *createGroupView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 69)];
    [createGroupView addTarget:self action:@selector(createGroupClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:createGroupView];
    viewY += 70;
    
    UIImageView *createGroupImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 31, 31)];
    [createGroupImg setImage:[UIImage imageNamed:@"grayadd"]];
    [createGroupView addSubview:createGroupImg];
    
    UILabel *createGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 18, wd - 100, 40)];
    [createGroupLabel setText:@"Add Interest"];
    createGroupLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
    [createGroupLabel setFont:[UIFont boldSystemFontOfSize:24]];
    [createGroupView addSubview:createGroupLabel];
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    UIView *schoolLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 40)];
    schoolLabelView.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:74.0/255.0 blue:94.0/255.0 alpha:1.0];
    [self addSubview:schoolLabelView];
    viewY += 5;
    
    UILabel *schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, viewY, wd - 25, 30)];
    [schoolLabel setText:[NSString stringWithFormat:@"%@ INTERESTS", [school.name uppercaseString]]];
    schoolLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
    [schoolLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self addSubview:schoolLabel];
    viewY += 35;
    
    [Group getBySchool:^(NSArray *groups)
     {
         int newViewY = viewY;
         self.Groups = [[NSMutableArray alloc] initWithArray:groups];
         for(int i = 0; i < groups.count; i++)
         {
             Group *group = [groups objectAtIndex:i];
             
             UIButton *groupView = [[UIButton alloc] initWithFrame:CGRectMake(0, newViewY, wd, 50)];
             [groupView addTarget:self action:@selector(groupClicked:) forControlEvents:UIControlEventTouchUpInside];
             groupView.tag = i;
             [self addSubview:groupView];
             
             if([group.pictureUrl length] > 0)
             {
                 MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(5, 5, 40, 40) url:group.pictureUrl];
                 [groupView addSubview:pic];
             }
             else {
                 UIImageView *groupImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
                 [groupImg setImage:[UIImage imageNamed:@"group"]];
                 [groupView addSubview:groupImg];
             }
             
             UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, wd - 60, 50)];
             [groupLabel setText:[NSString stringWithFormat:@"%@", group.name]];
             groupLabel.textColor = [UIColor whiteColor];
             [groupLabel setFont:[UIFont boldSystemFontOfSize:16]];
             [groupView addSubview:groupLabel];
             
             if(group.isPublic == false) {
                 UIImageView *privateImg = [[UIImageView alloc] initWithFrame:CGRectMake(wd - 40, 12, 25, 25)];
                 [privateImg setImage:[UIImage imageNamed:@"whitelock"]];
                 [groupView addSubview:privateImg];
             }
             
             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, groupView.frame.size.height - 1.0f, groupView.frame.size.width, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:63.0/255.0 green:69.0/255.0 blue:82.0/255.0 alpha:1.0];
             [groupView addSubview:bottomBorder];
             newViewY += 50;
         }
         self.contentSize = CGSizeMake(wd, newViewY + 20);
         
     }];
}

-(void)createGroupClicked:(id)sender
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        return;
    }
    
    MFCreateGroupView *view = [[MFCreateGroupView alloc] init];
    [MFHelpers open:view onView:self.superview];
}

-(void)groupClicked:(id)sender
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        MFLoginView *loginView = [[MFLoginView alloc] init];
        [MFHelpers open:loginView onView:self.superview];
        return;
    }
    
    UIControl *button = (UIControl *)sender;
    long tagId = button.tag;
    
    Group *group = (Group *)[self.Groups objectAtIndex:tagId];
    if(group.isPublic == false && group.isMember == false) {
        
        self.currentIndex = tagId;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ is private", group.name]
                                            message:@"Enter Password"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    }
    else {
        [self openGroup:group];
    }

}

-(void)openGroup:(Group *)group {
    MFGroupDetailView *detailView = [[MFGroupDetailView alloc] init:group];
    [MFHelpers openFromRight:detailView onView:self.superview];
}

-(void)closeGroups:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;

    MFEventsView *eventsView;
    for(UIView *subview in self.superview.subviews)
    {
        if([subview isMemberOfClass:[MFEventsView class]])
            eventsView = (MFEventsView *)subview;
    }
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(wd, 60, wd, ht- 60);
                         eventsView.frame = CGRectMake(0, 60, wd, ht - 60);
                     }
                     completion:^(BOOL finished){ }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        NSString *password = [alertView textFieldAtIndex:0].text;
        Group *group = self.Groups[self.currentIndex];
        if([password isEqualToString:group.password]) {
            [self openGroup:group];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect password"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)nothing:(id)sender {
    
}

@end
