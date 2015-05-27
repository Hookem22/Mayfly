//
//  MFMapView.m
//  Mayfly
//
//  Created by Will Parks on 5/26/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import "MFMapView.h"

@interface MFMapView ()

@end

@implementation MFMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)loadMap:(Location *)location
{
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.bounds];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    
    [mapView setCenterCoordinate:coord];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = coord;
    point.title = location.name;
    //point.subtitle = @"I'm here!!!";
    
    [mapView addAnnotation:point];
    
    [self addSubview:mapView];
    
    //mapView.delegate = self;
    //self.endLocation = coord;
    //[self getRouteTime];
    
}


@end
