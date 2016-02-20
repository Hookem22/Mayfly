//
//  MFCreateView.m
//  Mayfly
//
//  Created by Will Parks on 5/20/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFCreateView.h"

@interface MFCreateView()

@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) UIScrollView *createView;
@property (nonatomic, strong) NSArray *groupsList;
@property (nonatomic, strong) NSArray *contactsList;
@property (nonatomic, strong) UITextField *nameText;
@property (nonatomic, strong) UITextView *descText;
@property (nonatomic, strong) MFLocationView *locationView;
@property (nonatomic, strong) MFPillButton *publicButton;
@property (nonatomic, strong) UITextField *minText;
@property (nonatomic, strong) UITextField *maxText;
@property (nonatomic, strong) MFClockView *startText;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) NSArray *eventIcons;
@property (nonatomic, strong) UIView *selectedView;
@property (nonatomic, strong) NSString *selectedImage;
@property (nonatomic, strong) UIView *primaryGroupView;
@property (nonatomic, strong) NSString *primaryGroupId;

@end

@implementation MFCreateView

-(id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

-(id)init:(Event *)event
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.event = event;
        [self setup];
    }
    return self;
}

-(void)setup
{   
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *recognizer1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nothing:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer1];
    
    NSString *headerLabel = self.event ? @"Edit Event" : @"Create Event";
    [MFHelpers addTitleBar:self titleText:headerLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"whitebackarrow"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UIScrollView *createView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, wd, ht - 60)];
    self.createView = createView;
    [self addSubview:createView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
    [createView addGestureRecognizer:singleTap];
    
    UITextField *nameText = [[UITextField alloc] initWithFrame:CGRectMake(30, 20, wd - 60, 30)];
    nameText.borderStyle = UITextBorderStyleRoundedRect;
    nameText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
    nameText.font = [UIFont systemFontOfSize:15];
    nameText.placeholder = @"What do you want to do?";
    [nameText setReturnKeyType:UIReturnKeyDone];
    nameText.delegate = self;
    self.nameText = nameText;
    [createView addSubview:nameText];
    
    self.startText = [[MFClockView alloc] initWithFrame:CGRectMake(30, 60, wd - 60, 30) placeHolder:@"Start Time"];
    [createView addSubview:self.startText];
    
    UITextView *descText = [[UITextView alloc] initWithFrame:CGRectMake(30, 100, wd - 60, 80)];
    [descText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor]];
    [descText.layer setBorderWidth:1.0];
    [descText.layer setBackgroundColor:[[[UIColor grayColor] colorWithAlphaComponent:0.1] CGColor]];
    descText.font = [UIFont systemFontOfSize:15];
    descText.layer.cornerRadius = 5;
    descText.clipsToBounds = YES;
    
    descText.delegate = self;
    descText.text = @"Location & Details";
    descText.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    self.descText = descText;
    [createView addSubview:descText];
    
    UIView *topBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, createView.frame.size.height - 180, wd, 1)];
    topBorder1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [createView addSubview:topBorder1];
    
    UIView *middle1 = [[UIView alloc] initWithFrame:CGRectMake(0, createView.frame.size.height - 179, wd, 10)];
    middle1.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [createView addSubview:middle1];
    
    UIView *bottomBorder1 = [[UIView alloc] initWithFrame:CGRectMake(0, createView.frame.size.height - 170, wd, 1)];
    bottomBorder1.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [createView addSubview:bottomBorder1];
    
    if(self.event)
    {
        nameText.text = self.event.name;
        if([self.event.description length]) {
            descText.text = self.event.description;
            descText.textColor = [UIColor blackColor];
        }
        [self.startText setTime:self.event.startTime];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteButton setTitle:@"Delete Event" forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.frame = CGRectMake(20, createView.frame.size.height - 162, wd-40, 20);
        [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
        [createView addSubview:deleteButton];
        
        if(self.event.groupId.length > 0) {
            [self populateGroups];
        }
        
    }
    else
    {
        UIButton *addFriendsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [addFriendsButton setTitle:@"Invite Friends or Interests" forState:UIControlStateNormal];
        [addFriendsButton addTarget:self action:@selector(addFriendsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        addFriendsButton.frame = CGRectMake(20, createView.frame.size.height - 162, wd-40, 20);
        [addFriendsButton.titleLabel setFont:[UIFont systemFontOfSize:20.f]];
        [createView addSubview:addFriendsButton];
        
//        UIView *topBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, 310, wd, 1)];
//        topBorder2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
//        [createView addSubview:topBorder2];
//        
//        UIView *middle2 = [[UIView alloc] initWithFrame:CGRectMake(0, 311, wd, 8)];
//        middle2.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
//        [createView addSubview:middle2];
//        
//        UIView *bottomBorder2 = [[UIView alloc] initWithFrame:CGRectMake(0, 319, wd, 1)];
//        bottomBorder2.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
//        [createView addSubview:bottomBorder2];
    }
    
    [self populateIcons];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, createView.frame.size.height - 60, wd, 2)];
    topBorder.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    [createView addSubview:topBorder];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(20, createView.frame.size.height - 45, wd - 40, 40)];
    NSString *saveButtonTitle = self.event ? @"Save" : @"Create";
    [saveButton setTitle:saveButtonTitle forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    saveButton.layer.cornerRadius = 20;
    saveButton.layer.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1.0].CGColor;
    self.saveButton = saveButton;
    [createView addSubview:saveButton];
}

-(void)populateGroups {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    UIScrollView *peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.createView.frame.size.height - 137, wd, 80)];
    peopleView.tag = 2;
    [self.createView addSubview:peopleView];
    
    self.groupsList = [[NSArray alloc] init];
    NSArray *groupIds = [self.event.groupId componentsSeparatedByString: @"|"];
    for (NSString *groupId in groupIds) {
        [Group get:groupId completion:^(Group *group) {
            NSMutableArray *groups = [NSMutableArray arrayWithArray:self.groupsList];
            [groups addObject:group];
            self.groupsList = groups;
            if(groups.count == groupIds.count) {
                [self addGroups:self.event.primaryGroupId];
                self.primaryGroupId = self.event.primaryGroupId;
            }
        }];
    }
}

-(void)populateIcons {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger top = 187;
    NSUInteger bottom = self.createView.frame.size.height - 177;
    NSUInteger height = bottom - top;
    NSUInteger iconHeight = (height - 10) / 3;
    NSUInteger imgHeight = (iconHeight * 85) / 100;
    
    UIScrollView *iconView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, wd, height)];
    [self.createView addSubview:iconView];
    
    NSArray *icons = @[@"Sunny", @"Lightning", @"Sunglasses", @"Castle", @"Firework", @"Spaceship", @"Hammock", @"Tent", @"Flipflops", @"Pool", @"Jetski", @"Canoe", @"Cloudy", @"Snow", @"Storm", @"WindmillPaper", @"OldCar", @"Motorbike", @"Segway", @"Hat", @"Boots", @"Books", @"Science", @"MovieEvent", @"MovieSlate", @"Television", @"Ticket", @"Money", @"VideoCamera", @"Microphone", @"Guitar", @"Cassette", @"Dj", @"RecordPlayer", @"Speaker", @"Trumpet", @"Astronaut", @"CaptainShield", @"Darth-Vader", @"Minion", @"Pacman", @"PacmanGhost", @"WallE", @"PirateFlag", @"Xbox", @"Joystick", @"Cards", @"Chessboard", @"PingPong", @"Bowling", @"Snooker", @"Telescope", @"MagicBunny", @"Crown", @"Flag", @"Podium", @"PrizeCup", @"Football", @"Helmet", @"Backboard", @"Baseball", @"Soccer", @"SoccerField", @"Tennis", @"Karate", @"Dumbbell", @"Rollerblade", @"Bottle", @"Beer", @"Beermug", @"Champagne", @"Cocktail", @"Whiskey", @"Wine", @"Coffee", @"Watermelon", @"TableSet", @"Sushi", @"Pizza", @"Noodles", @"FrenchFries", @"ChickenWing", @"Grill", @"BirthdayCake", @"Candycane", @"Cupcake", @"Icecream"];
    self.eventIcons = icons;
    
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgHeight + 10, imgHeight + 10)];
    selectedView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    selectedView.layer.borderColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0].CGColor;
    selectedView.layer.borderWidth = 3.0;
    selectedView.layer.cornerRadius = 5.0;
    self.selectedView = selectedView;
    [iconView addSubview:selectedView];
    
    int selected = 0;
    if(self.event != nil && self.event.groupPictureUrl != nil && ![self.event.groupPictureUrl isEqualToString:@""]) {
        for(int i = 0; i < icons.count; i++) {
            if([icons[i] isEqualToString:self.event.groupPictureUrl]) {
                selected = i;
                break;
            }
        }
    }
    [self selectIcon:selected];
    
    int viewX = 5;
    int i = 0;
    for(NSString *icon in icons) {
        UIButton *iconButton = [[UIButton alloc] init];
        [iconButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        [iconButton addTarget:self action:@selector(iconButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        iconButton.tag = i;
        [iconView addSubview:iconButton];
        
        if(i % 3 == 0) {
            iconButton.frame = CGRectMake(viewX, 5, imgHeight, imgHeight);
        }
        else if(i % 3 == 1) {
            iconButton.frame = CGRectMake(viewX, iconHeight + 5, imgHeight, imgHeight);
        }
        if(i % 3 == 2) {
            iconButton.frame = CGRectMake(viewX, (iconHeight * 2) + 5, imgHeight, imgHeight);
            viewX += iconHeight;
        }
        i++;
    }
    iconView.contentSize = CGSizeMake(viewX, height);
    int offset = ((int)iconHeight * (selected / 3)) - 30;
    if(offset > viewX - (int)wd)
        offset = viewX - (int)wd;
    iconView.contentOffset = CGPointMake(offset, 0);
}

-(void)iconButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self selectIcon:(int)button.tag];
}

-(void)selectIcon:(int)tag
{
    self.selectedImage = self.eventIcons[tag];
    
    NSUInteger top = 187;
    NSUInteger bottom = self.createView.frame.size.height - 177;
    NSUInteger height = bottom - top;
    NSUInteger iconHeight = (height - 10) / 3;
    NSUInteger imgHeight = (iconHeight * 85) / 100;
    
    int row = tag % 3;
    int col = tag / 3;
    
    self.selectedView.frame = CGRectMake(col * iconHeight, row * iconHeight, imgHeight + 10, imgHeight + 10);
    [self dismissKeyboard:nil];
}

-(void)addFriendsButtonClick:(id)sender
{
    MFAddressBook *addressBook = [[MFAddressBook alloc] init:self.contactsList];
    [MFHelpers open:addressBook onView:self];
    [self dismissKeyboard:nil];
}
-(void)invite:(NSArray *)contactsList
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    
    for(UIView *subview in self.createView.subviews)
    {
        if([subview isMemberOfClass:[UIScrollView class]] && subview.tag == 2)
            [subview removeFromSuperview];
    }
    
    UIScrollView *peopleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.createView.frame.size.height - 137, wd, 80)];
    peopleView.tag = 2;
    [self.createView addSubview:peopleView];
    
    //Groups
    User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
    
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    int viewX = 0;
    for (Group *group in currentUser.groups) {
        if(group.isInvitedtoEvent) {
            [groups addObject:group];
            viewX += 60;
        }
    }
    self.groupsList = groups;
    if(groups.count > 0) {
        [self addGroups:nil];
        [self selectPrimaryGroup];
    }
    
    //Contacts
    self.contactsList = contactsList;
    for(NSDictionary *contact in contactsList)
    {
        UIView *personView = [[UIView alloc] initWithFrame:CGRectMake(viewX, 0, 60, 80)];
        
        NSString *facebookId = [contact objectForKey:@"id"];
        if(facebookId != nil)
        {
            MFProfilePicView *pic = [[MFProfilePicView alloc] initWithFrame:CGRectMake(5, 5, 50, 50) facebookId:facebookId];
            [personView addSubview:pic];
        }
        else
        {
            UIImageView *pic = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
            int faceNumber = (arc4random() % 8);
            [pic setImage:[UIImage imageNamed:[NSString stringWithFormat:@"face%d", faceNumber]]];
            [personView addSubview:pic];
        }

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-2, 55, 62, 20)];
        label.text = [contact objectForKey:@"firstName"];
        label.textAlignment = NSTextAlignmentCenter;
        [personView addSubview:label];
        
        [peopleView addSubview:personView];
        viewX += 60;
    }
    viewX += 30;
    peopleView.contentSize = CGSizeMake(viewX, 80);
    peopleView.contentOffset = CGPointMake(-30, 0);
}

-(void)addGroups:(NSString *)primaryGroupId {
    for(UIView *subview in self.createView.subviews)
    {
        if([subview isMemberOfClass:[UIScrollView class]] && subview.tag == 2) {
            UIScrollView *peopleView = (UIScrollView *)subview;
            int viewX = 0;
            for (Group *group in self.groupsList) {
                UIButton *groupButton = [[UIButton alloc] initWithFrame:CGRectMake(viewX, 0, 60, 76)];
                [groupButton addTarget:self action:@selector(selectPrimaryGroup) forControlEvents:UIControlEventTouchUpInside];
                groupButton.layer.cornerRadius = 5.0;
                
                if([group.pictureUrl isKindOfClass:[NSNull class]] || group.pictureUrl.length <= 0) {
                    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
                    [icon setImage:[UIImage imageNamed:@"group"]];
                    [groupButton addSubview:icon];
                }
                else {
                    MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(5, 5, 50, 50) url:group.pictureUrl];
                    [groupButton addSubview:pic];
                }
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-2, 55, 62, 20)];
                label.text = group.name;
                label.textAlignment = NSTextAlignmentCenter;
                [groupButton addSubview:label];
                
                if(primaryGroupId.length > 0 && [primaryGroupId isEqualToString:group.groupId]) {
                    groupButton.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
                    label.textColor = [UIColor whiteColor];
                }
                
                [peopleView addSubview:groupButton];
                viewX += 60;
            }
            peopleView.contentSize = CGSizeMake(viewX, 80);
            peopleView.contentOffset = CGPointMake(-30, 0);
        }
    }
}

-(void)selectPrimaryGroup {
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    NSArray *groups = self.groupsList;
    
    self.primaryGroupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wd, ht)];
    self.primaryGroupView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.primaryGroupView];
    
    UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePrimaryGroup)];
    [self.primaryGroupView addGestureRecognizer:singleTap];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(20, ht - (groups.count * 50) - 105, wd - 40, (groups.count * 50) + 40)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 5.0;
    [self.primaryGroupView addSubview:backgroundView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, backgroundView.frame.size.width - 20, 20)];
    titleLabel.text = @"SELECT PRIMARY INTEREST";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backgroundView addSubview:titleLabel];
    
    UIButton *questionButton = [[UIButton alloc] initWithFrame:CGRectMake(backgroundView.frame.size.width - 25, 10, 20, 20)];
    [questionButton setImage:[UIImage imageNamed:@"questionmark"] forState:UIControlStateNormal];
    [questionButton addTarget:self action:@selector(questionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:questionButton];
    
    int viewY = 40;
    for (int i = 0; i < groups.count; i++) {
        Group *group = [groups objectAtIndex:i];
        UIView *groupView = [[UIView alloc] initWithFrame:CGRectMake(5, viewY, backgroundView.frame.size.width - 10, 50)];
        
        if([group.pictureUrl isKindOfClass:[NSNull class]] || group.pictureUrl.length <= 0) {
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 40, 40)];
            [icon setImage:[UIImage imageNamed:@"group"]];
            [groupView addSubview:icon];
        }
        else {
            MFProfilePicView *pic = [[MFProfilePicView alloc] initWithUrl:CGRectMake(0, 5, 40, 40) url:group.pictureUrl];
            [groupView addSubview:pic];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(60, 0, backgroundView.frame.size.width - 60, 50);
        [button addTarget:self action:@selector(primaryGroupSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:group.name forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
        button.tag = i;
        [groupView addSubview:button];
        
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, backgroundView.frame.size.width, 1)];
        border.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        [groupView addSubview:border];
        
        [backgroundView addSubview:groupView];
        viewY += 50;
    }
    
    UIButton *noneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    noneButton.frame = CGRectMake(20, ht - 60, wd - 40, 50);
    [noneButton addTarget:self action:@selector(noneSelected:) forControlEvents:UIControlEventTouchUpInside];
    [noneButton setTitle:@"None" forState:UIControlStateNormal];
    noneButton.backgroundColor = [UIColor whiteColor];
    [noneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
    noneButton.layer.cornerRadius = 5.0;
    [self.primaryGroupView addSubview:noneButton];
    
}

-(void)primaryGroupSelected:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self clearPrimaryGroupSelected];
    [self setPrimaryGroup:button.tag];
    [self closePrimaryGroup];
}

-(void)setPrimaryGroup:(NSUInteger)idx {
    Group *group = [self.groupsList objectAtIndex:idx];
    self.primaryGroupId = group.groupId;

    for(UIView *peopleView in self.createView.subviews)
    {
        if([peopleView isMemberOfClass:[UIScrollView class]] && peopleView.tag == 2) {
            int i = 0;
            for(UIView *subview in peopleView.subviews) {
                if([subview isMemberOfClass:[UIButton class]] && i == (int)idx) {
                    UIButton *selectedButton = (UIButton *)subview;
                    selectedButton.backgroundColor = [UIColor colorWithRed:66.0/255.0 green:133.0/255.0 blue:244.0/255.0 alpha:1.0];
                    for(UIView *labelView in selectedButton.subviews) {
                        if([labelView isMemberOfClass:[UILabel class]]) {
                            UILabel *label = (UILabel *)labelView;
                            label.textColor = [UIColor whiteColor];
                        }
                    }
                    
                }
                i++;
            }
        }
    }
}

-(void)clearPrimaryGroupSelected {
    for(UIView *peopleView in self.createView.subviews)
    {
        if([peopleView isMemberOfClass:[UIScrollView class]] && peopleView.tag == 2) {
            for(UIView *subview in peopleView.subviews) {
                if([subview isMemberOfClass:[UIButton class]]) {
                    UIButton *selectedButton = (UIButton *)subview;
                    selectedButton.backgroundColor = [UIColor whiteColor];
                    for(UIView *labelView in selectedButton.subviews) {
                        if([labelView isMemberOfClass:[UILabel class]]) {
                            UILabel *label = (UILabel *)labelView;
                            label.textColor = [UIColor blackColor];
                        }
                    }
                    
                }
            }
        }
    }
}

-(void)noneSelected:(id)sender {
    self.primaryGroupId = @"";
    [self clearPrimaryGroupSelected];
    [self closePrimaryGroup];
}

-(void)closePrimaryGroup {
    [self.primaryGroupView removeFromSuperview];
}

-(void)questionButtonClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Primary Interest"
                                                    message:@"If there is a group or club throwing this event, select it as the primary interest."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)cancelButtonClick:(id)sender
{
    [Group clearIsInvitedToEvent];
    [MFHelpers closeRight:self];
}
-(void)saveButtonClick:(id)sender
{
    //Validation
    self.nameText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.locationView.locationText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.startText.timeText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    self.minText.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor];
    
    BOOL error = false;
    if([self.nameText.text isEqualToString:@""])
    {
        self.nameText.layer.borderColor=[[UIColor redColor] CGColor];
        self.nameText.layer.cornerRadius=8.0f;
        self.nameText.layer.borderWidth= 1.0f;
        error = true;
    }
    if([self.startText.timeText.text isEqualToString:@""])
    {
        self.startText.timeText.layer.borderColor=[[UIColor redColor] CGColor];
        self.startText.timeText.layer.cornerRadius=8.0f;
        self.startText.timeText.layer.borderWidth= 1.0f;
        error = true;
    }
    if(error)
        return;
    
    
    Event *event = self.event == nil ? [[Event alloc] init] : self.event;
    event.name = self.nameText.text;
    event.description = [self.descText.text isEqualToString:@"Location & Details"] ? @"" : self.descText.text;
    event.location = self.locationView.location != nil ? self.locationView.location : [[Location alloc] init];
    event.minParticipants = [self.minText.text integerValue];
    event.maxParticipants = [self.maxText.text integerValue];
    
    School *school = (School *)[Session sessionVariables][@"currentSchool"];
    event.location = [[Location alloc] init: @{ @"name": school.name, @"address": @"", @"latitude": [NSNumber numberWithInt:(int)school.latitude], @"longitude": [NSNumber numberWithInt:(int)school.longitude] }];
    event.schoolId = school.schoolId;
    
    event.startTime = self.startText.getTime;
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"c"];
    NSString *weekday = [dayFormatter stringFromDate:event.startTime];
    event.dayOfWeek = ([weekday intValue] + 6) % 7;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    event.localTime = [timeFormatter stringFromDate:event.startTime];
    
    //Don't schedule time earlier than now
    if ([event.startTime compare:[NSDate date]] == NSOrderedAscending) {
        self.startText.timeText.layer.borderColor=[[UIColor redColor] CGColor];
        self.startText.timeText.layer.cornerRadius=8.0f;
        self.startText.timeText.layer.borderWidth= 1.0f;
        return;
    }
    
    event.groupId = self.event == nil ? @"" : event.groupId;
    event.groupName = self.event == nil ? @"" : event.groupName;
    event.groupPictureUrl = self.selectedImage;
    event.groupIsPublic = YES;
    event.primaryGroupId = self.primaryGroupId == nil ? @"" : self.primaryGroupId;
    for(Group *group in self.groupsList) {
        if(self.event == nil) {
            event.groupId = event.groupId.length == 0 ? group.groupId : [NSString stringWithFormat:@"%@|%@", event.groupId, group.groupId];
            event.groupName = event.groupName.length == 0 ? group.name : [NSString stringWithFormat:@"%@|%@", event.groupName, group.name];
        }
        if([group.groupId isEqualToString:self.primaryGroupId]) {
            event.groupIsPublic = group.isPublic;
        }
    }
    
    [self save:event];
    [Group clearIsInvitedToEvent];
}

-(void)save:(Event *)event
{
    [MFHelpers showProgressView:self];
    
    [event save:^(Event *event)
    {
         if(self.event)
         {
             if([self.superview isMemberOfClass:[MFDetailView class]])
             {
                 MFDetailView *detailView = (MFDetailView *)self.superview;
                 [detailView initialSetup:event refresh:YES];
                 
                 if([self.superview.superview isMemberOfClass:[MFView class]])
                 {
                     MFView *view = (MFView *)self.superview.superview;
                     [view refreshEvents];
                 }
             }

             [MFHelpers close:self];
             return;
        }
        
        User *currentUser = (User *)[Session sessionVariables][@"currentUser"];
        [event addGoing:currentUser.userId isAdmin:YES];
        [MFHelpers hideProgressView:self];
        
        MFCalendarAccess *addToCalendar = [[MFCalendarAccess alloc] init];
        [self.superview addSubview:addToCalendar];
        [addToCalendar addToCalendar:event];
        
        if(self.groupsList != nil && self.groupsList.count > 0) {
            [Group inviteGroups:self.groupsList event:event completion:^(NSDictionary *item) {}];
        }
//         for(Group *group in self.groupsList) {
//            NSString *msg = [NSString stringWithFormat:@"New event in %@", group.name];
//            NSString *info = [NSString stringWithFormat:@"Invitation|%@", self.event.eventId];
//            [group sendMessageToGroup:msg info:info];
//         }
        
         Notification *notification = [[Notification alloc] init];
         notification.eventId = event.eventId;
         notification.userId = currentUser.userId;
         notification.message = [NSString stringWithFormat:@"Created: %@", event.name];
         [notification save:^(Notification *notification) { }];
        
         NSMutableArray *firstNames = [[NSMutableArray alloc] init];
         NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
         for(NSDictionary *contact in self.contactsList)
         {
             NSString *facebookId = [contact valueForKey:@"id"];
             NSString *phone = [contact valueForKey:@"Phone"];
             NSString *firstName = [contact valueForKey:@"firstName"];
             if(facebookId != nil) {
                 [event addInvite:facebookId name:firstName completion:^(EventGoing *eventGoing) {
                     
                 }];
             }
             if(phone != nil) {
                 [phoneNumbers addObject:phone];
                 [firstNames addObject:firstName];
             }
         }
        
         if([phoneNumbers count] > 0) {
             [[Session sessionVariables] setObject:event forKey:@"currentEvent"];
             [[Session sessionVariables] setObject:firstNames forKey:@"currentInvites"];
             
             [MFHelpers GetBranchUrl:event.referenceId eventName:event.name completion:^(NSString *url) {
                 ViewController *vc = (ViewController *)self.window.rootViewController;
                 [vc sendTextMessage:phoneNumbers message:url];
             }];
         }
         else
         {
             if([self.superview isMemberOfClass:[MFView class]])
             {
                 MFView *view = (MFView *)self.superview;
                 [view refreshEvents];
             }
             [MFHelpers close:self];
         }
     }];
}

-(void)deleteButtonClick:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Event"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", self.event.name]
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //self.event.isPrivate = YES;
            break;
        case 1: //"Yes" pressed
            [self deleteEvent];
            break;
    }
}

-(void)deleteEvent{
    
    [MFHelpers showProgressView:self];
    [self.event deleteEvent:^(NSDictionary *item) {
        if([self.superview.superview isMemberOfClass:[MFView class]])
        {
            MFView *view = (MFView *)self.superview.superview;
            [view refreshEvents];
        }
        if([self.superview isMemberOfClass:[MFDetailView class]])
        {
            [self.superview removeFromSuperview];
        }
        
        [MFHelpers hideProgressView:self];
        [self cancelButtonClick:nil];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard:(id)sender
{
    [self endEditing:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Location & Details"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Location & Details";
        textView.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    }
    [textView resignFirstResponder];
}

-(void)nothing:(id)sender {
    
}




@end
