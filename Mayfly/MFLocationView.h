//
//  MFLocationView.h
//  Mayfly
//
//  Created by Will Parks on 6/10/15.
//  Copyright (c) 2015 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFLocationSelectView.h"
#import "MFMapView.h"
#import "Location.h"

@interface MFLocationView : UIView

-(id)initWithFrame:(CGRect)frame mapFrame:(CGRect)mapFrame;
-(void)locationReturn:(Location *)location;

@property (nonatomic, strong) Location *location;

@end
