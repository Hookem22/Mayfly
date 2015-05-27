//
//  MFMapView.h
//  Mayfly
//
//  Created by Will Parks on 5/26/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Location.h"

@interface MFMapView : UIView <MKMapViewDelegate>

-(void)loadMap:(Location *)location;

@end
