//
//  MFLocationView.m
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFLocationView.h"

@interface MFLocationView()

@property (nonatomic, strong) UITextField *locationText;
@property (nonatomic, assign) CGRect mapFrame;

@end

@implementation MFLocationView

@synthesize location = _location;

-(id)initWithFrame:(CGRect)frame mapFrame:(CGRect)mapFrame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mapFrame = mapFrame;
        
        //UITextField *locationText = [[UITextField alloc] initWithFrame:CGRectMake(30, 150, (wd * 3) / 5 - 35, 30)];
        UITextField *locationText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [locationText addTarget:self action:@selector(openLocationSelect:) forControlEvents:UIControlEventEditingDidBegin];
        locationText.borderStyle = UITextBorderStyleRoundedRect;
        locationText.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.1];
        locationText.font = [UIFont systemFontOfSize:15];
        locationText.placeholder = @"Location";
        UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        locationText.inputView = dummyView;
        self.locationText = locationText;
        [self addSubview:locationText];
    }
    return self;
}

-(void)openLocationSelect:(id)sender
{
    NSUInteger wd = [[UIScreen mainScreen] bounds].size.width;
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    MFLocationSelectView *locationView = [[MFLocationSelectView alloc] initWithFrame:CGRectMake(0, ht, wd, ht) returnView:self];
    [self.superview.superview addSubview:locationView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         locationView.frame = CGRectMake(0, 0, wd, ht);
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

-(void)locationReturn:(Location *)location
{
    self.location = location;
    self.locationText.text = location.name;
    
    NSUInteger ht = [[UIScreen mainScreen] bounds].size.height;
    
    //MFMapView *map = [[MFMapView alloc] initWithFrame:CGRectMake(30, 385, wd - 60, ht - 455)];
    MFMapView *map = [[MFMapView alloc] initWithFrame:self.mapFrame];
    if(ht < 568 && [self.superview isMemberOfClass:[UIScrollView class]])
    {
        //map.frame = CGRectMake(30, 385, wd - 60, 140);
        map.frame = CGRectMake(self.mapFrame.origin.x, self.mapFrame.origin.y, self.mapFrame.size.width, 140);
        UIScrollView *superView = (UIScrollView *)self.superview;
        superView.contentSize = CGSizeMake(superView.frame.size.width, self.mapFrame.origin.y + 150);
    }
    [map loadMap:location];
    [self.superview addSubview:map];
    
}

@end
