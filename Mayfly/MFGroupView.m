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
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation MFGroupView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        //self.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:57.0/255.0 blue:74.0/255.0 alpha:1.0];
        self.delegate = self;
        self.Groups = [[NSMutableArray alloc] init];
        
//        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeGroups:)];
//        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//        [self addGestureRecognizer:recognizer];
        
        UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
        [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self addGestureRecognizer:recognizer1];
    }
    return self;
}

-(void)loadGroups
{
    
//    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
//    int viewY = 0;
//    UIControl *createGroupView = [[UIControl alloc] initWithFrame:CGRectMake(0, viewY, wd, 69)];
//    [createGroupView addTarget:self action:@selector(createGroupClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:createGroupView];
//    viewY += 70;
//    
//    UIImageView *createGroupImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 31, 31)];
//    [createGroupImg setImage:[UIImage imageNamed:@"grayadd"]];
//    [createGroupView addSubview:createGroupImg];
//    
//    UILabel *createGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 18, wd - 100, 40)];
//    [createGroupLabel setText:@"Add Interest"];
//    createGroupLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
//    [createGroupLabel setFont:[UIFont boldSystemFontOfSize:24]];
//    [createGroupView addSubview:createGroupLabel];
    
//    School *school = (School *)[Session sessionVariables][@"currentSchool"];
//    
//    UIView *schoolLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, wd, 40)];
//    schoolLabelView.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:74.0/255.0 blue:94.0/255.0 alpha:1.0];
//    [self addSubview:schoolLabelView];
//    viewY += 5;
//    
//    UILabel *schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 65, wd - 25, 30)];
//    [schoolLabel setText:[NSString stringWithFormat:@"%@ INTERESTS", [school.name uppercaseString]]];
//    schoolLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
//    [schoolLabel setFont:[UIFont boldSystemFontOfSize:18]];
//    schoolLabel.textAlignment = NSTextAlignmentCenter;
//    [self addSubview:schoolLabel];
//    viewY += 35;
    
    [Group getBySchool:^(NSArray *groups)
     {
         self.Groups = [NSMutableArray arrayWithArray: groups];
         [self populateInterests:groups];
     }];
}

-(void)populateAllInterests {
    [self populateInterests:self.Groups];
}

-(void)populateMyInterests {
    NSMutableArray *myGroups = [[NSMutableArray alloc] init];
    for(Group *group in self.Groups) {
        if(group.isMember) {
            [myGroups addObject:group];
        }
    }
    [self populateInterests:myGroups];
}

-(void)populateInterests:(NSArray *)groups {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    int viewY = 0;
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    UIView *schoolLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, wd, 40)];
    schoolLabelView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self addSubview:schoolLabelView];
    viewY += 5;
    
    UILabel *schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, viewY, wd - 25, 30)];
    [schoolLabel setText:[NSString stringWithFormat:@"%@ INTERESTS", [school.name uppercaseString]]];
    schoolLabel.textColor = [UIColor colorWithRed:68.0/255.0 green:68.0/255.0 blue:68.0/255.0 alpha:1.0];
    [schoolLabel setFont:[UIFont boldSystemFontOfSize:18]];
    schoolLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:schoolLabel];
    viewY += 35;
    
    NSArray *events = (NSArray *)[Session sessionVariables][@"currentEvents"];
    for(Group *group in groups)
    {
        UIButton *groupView = [[UIButton alloc] initWithFrame:CGRectMake(0, viewY, wd, 50)];
        [groupView addTarget:self action:@selector(groupClicked:) forControlEvents:UIControlEventTouchUpInside];
        groupView.tag = group.tagId;
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
        //groupLabel.textColor = [UIColor whiteColor];
        [groupLabel setFont:[UIFont systemFontOfSize:16]];
        [groupView addSubview:groupLabel];

        int eventCt = 0;
        for(Event *event in events) {
            if([event.groupId rangeOfString:group.groupId].location != NSNotFound) {
                eventCt++;
            }
        }
        if (eventCt > 0) {
            groupLabel.frame = CGRectMake(60, 0, wd - 60, 32);
            
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 26, wd - 60, 20)];
            NSString *eventText = eventCt == 1 ? @"1 upcoming event" : [NSString stringWithFormat:@"%i upcoming events", eventCt];
            [eventLabel setText:eventText];
            eventLabel.textColor = [UIColor colorWithRed:119.0/255.0 green:119.0/255.0 blue:119.0/255.0 alpha:1.0];
            [eventLabel setFont:[UIFont boldSystemFontOfSize:12]];
            [groupView addSubview:eventLabel];
        }
        
        if(group.isPublic == false) {
            UIImageView *privateImg = [[UIImageView alloc] initWithFrame:CGRectMake(wd - 40, 12, 25, 25)];
            [privateImg setImage:[UIImage imageNamed:@"solidgraylock"]];
            [groupView addSubview:privateImg];
        }
        
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(10, groupView.frame.size.height - 1.0f, groupView.frame.size.width - 25, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [groupView addSubview:bottomBorder];
        viewY += 50;
    }
    self.contentSize = CGSizeMake(wd, viewY + 70);
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
//    if([self.superview isMemberOfClass:[MFView class]])
//    {
//        MFView *view = (MFView *)self.superview;
//        [view eventsButtonClick:sender];
//    }
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.superview isMemberOfClass:[MFView class]])
    {
        MFView *view = (MFView *)self.superview;
        if (self.lastContentOffset > scrollView.contentOffset.y || scrollView.contentOffset.y < 30)
            [view scrollUp];
        else if (self.lastContentOffset < scrollView.contentOffset.y)
            [view scrollDown];
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}

-(void)nothing:(id)sender {
    
}

@end
