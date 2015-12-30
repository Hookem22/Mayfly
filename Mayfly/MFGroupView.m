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
    }
    return self;
}

-(void)loadGroups
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    for(UIView *subview in self.subviews)
        [subview removeFromSuperview];
    
    
    UIControl *createGroupView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, wd, 69)];
    [createGroupView addTarget:self action:@selector(createGroupClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:createGroupView];
    
    UIImageView *createGroupImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 31, 31)];
    [createGroupImg setImage:[UIImage imageNamed:@"grayadd"]];
    [createGroupView addSubview:createGroupImg];
    
    UILabel *createGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 18, wd - 100, 40)];
    [createGroupLabel setText:@"Create Group"];
    createGroupLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
    [createGroupLabel setFont:[UIFont boldSystemFontOfSize:24]];
    [createGroupView addSubview:createGroupLabel];
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    
    UIView *schoolLabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 70, wd, 40)];
    schoolLabelView.backgroundColor = [UIColor colorWithRed:67.0/255.0 green:74.0/255.0 blue:94.0/255.0 alpha:1.0];
    [self addSubview:schoolLabelView];
    
    UILabel *schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, wd - 25, 30)];
    [schoolLabel setText:[NSString stringWithFormat:@"%@ GROUPS", [school.name uppercaseString]]];
    schoolLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:164.0/255.0 blue:179.0/255.0 alpha:1.0];
    [schoolLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self addSubview:schoolLabel];
    
    
    [Group getBySchool:^(NSArray *groups)
     {
         self.Groups = [[NSMutableArray alloc] initWithArray:groups];
         for(int i = 0; i < groups.count; i++)
         {
             Group *group = [groups objectAtIndex:i];
             
             UIButton *groupView = [[UIButton alloc] initWithFrame:CGRectMake(0, (i * 50) + 110, wd, 50)];
             [groupView addTarget:self action:@selector(groupClicked:) forControlEvents:UIControlEventTouchUpInside];
             groupView.tag = i;
             [self addSubview:groupView];
             
             UIImageView *groupImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
             NSString *imgName = [group.pictureUrl length] == 0 ? @"group" : group.pictureUrl;
             [groupImg setImage:[UIImage imageNamed:imgName]];
             [groupView addSubview:groupImg];
             
             UILabel *groupLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, wd - 60, 50)];
             [groupLabel setText:[NSString stringWithFormat:@"%@", group.name]];
             groupLabel.textColor = [UIColor whiteColor];
             [groupLabel setFont:[UIFont boldSystemFontOfSize:16]];
             [groupView addSubview:groupLabel];
             
             UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, groupView.frame.size.height - 1.0f, groupView.frame.size.width, 1)];
             bottomBorder.backgroundColor = [UIColor colorWithRed:63.0/255.0 green:69.0/255.0 blue:82.0/255.0 alpha:1.0];
             [groupView addSubview:bottomBorder];
         }
         
     }];
}

-(void)createGroupClicked:(id)sender
{
    MFCreateGroupView *view = [[MFCreateGroupView alloc] init];
    [MFHelpers open:view onView:self.superview];
}

-(void)groupClicked:(id)sender
{
    UIControl *button = (UIControl *)sender;
    long tagId = button.tag;
    
    Group *group = (Group *)[self.Groups objectAtIndex:tagId];

    MFGroupDetailView *detailView = [[MFGroupDetailView alloc] init:group.groupId];
    [MFHelpers open:detailView onView:self.superview];
}

-(void)closeGroups:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(wd, 60, wd, ht- 60);
                     }
                     completion:^(BOOL finished){ }];
}


@end
