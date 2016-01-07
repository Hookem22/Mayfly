//
//  MFGroupDetailView.m
//  Pow Wow
//
//  Created by Will Parks on 12/29/15.
//  Copyright © 2015 Mayfly. All rights reserved.
//

#import "MFGroupDetailView.h"

@interface MFGroupDetailView ()

@property (nonatomic, strong) Group *group;
@property (nonatomic, strong) UILabel *detailsLabel;

@end

@implementation MFGroupDetailView

-(id)init:(NSString *)groupId
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [self addGestureRecognizer:recognizer];
        
        [self setup:groupId];
    }
    return self;
}

-(void)setup:(NSString *)groupId
{
    [Group get:groupId completion:^(Group *group)
     {
         self.group = group;
         
         NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
         NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
         
         [MFHelpers addTitleBar:self titleText:group.name];
         
         UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
         [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
         [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
         [self addSubview:cancelButton];
         
         UIScrollView *detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, wd, ht - 80)];
         [self addSubview:detailView];
         
         School *school = (School *)[Session sessionVariables][@"currentSchool"];
         
         UILabel *detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, wd - 60, 20)];
         detailsLabel.text = [NSString stringWithFormat:@"%i Members - %@", group.members.count, school.name];
         detailsLabel.textAlignment = NSTextAlignmentCenter;
         self.detailsLabel = detailsLabel;
         [detailView addSubview:detailsLabel];
         
         UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
         [joinButton.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
         [joinButton addTarget:self action:@selector(joinButtonClick:) forControlEvents:UIControlEventTouchUpInside];
         joinButton.frame = CGRectMake(30, 40, wd - 60, 40);
         joinButton.layer.cornerRadius = 4.0f;
         joinButton.layer.borderWidth = 2.0f;
         [detailView addSubview:joinButton];
         
         if(![group isMember])
         {
             [joinButton setTitle:@"+ JOIN GROUP" forState:UIControlStateNormal];
             [joinButton setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
             joinButton.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
             joinButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
         }
         else
         {
             [joinButton setTitle:@"MEMBER" forState:UIControlStateNormal];
             [joinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             joinButton.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
             joinButton.layer.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
         }
         
         UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 90, wd - 60, 20)];
         descriptionLabel.text = group.description;
         descriptionLabel.numberOfLines = 0;
         descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
         [descriptionLabel sizeToFit];
         [detailView addSubview:descriptionLabel];
         
         int descHt = descriptionLabel.frame.size.height;
         
         UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, descHt + 100, wd, 1)];
         bottomBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
         [detailView addSubview:bottomBorder];
     }];
}

-(void)refreshGroup
{
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    self.detailsLabel.text = [NSString stringWithFormat:@"%luu Members - %@",(unsigned long)self.group.members.count, school.name];
}

-(void)joinButtonClick:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    UIButton *button = (UIButton *)sender;
    if([button.titleLabel.text isEqualToString:@"+ JOIN GROUP"])
    {
        [button setTitle:@"MEMBER" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        button.layer.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:189.0/255.0 blue:43.0/255.0 alpha:1.0].CGColor;
        
        [self.group addMember:appDelegate.userId isAdmin:NO];
        
        GroupUsers *person = [[GroupUsers alloc] init];
        person.firstName = appDelegate.firstName;
        person.facebookId = appDelegate.facebookId;
        person.userId = appDelegate.userId;
        NSMutableArray *members = [[NSMutableArray alloc] initWithArray:self.group.members];
        [members addObject:person];
        self.group.members = [[NSArray alloc] initWithArray:members];
        
        [self refreshGroup];
    }
    else
    {
        
        [button setTitle:@"+ JOIN GROUP" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
        button.layer.backgroundColor = [UIColor whiteColor].CGColor;
        
        [self.group removeMember:appDelegate.userId];
        
        NSMutableArray *members = [[NSMutableArray alloc] init];
        for(GroupUsers *member in self.group.members)
        {
            if(![member.userId isEqualToString:appDelegate.userId])
                [members addObject:member];
        }
        self.group.members = [[NSArray alloc] initWithArray:members];
        
        [self refreshGroup];
    }
    
}

-(void)cancelButtonClick:(id)sender
{
    [MFHelpers closeRight:self];
}

@end
