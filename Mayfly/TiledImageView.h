//
//  TiledImageView.h
//  Pow Wow
//
//  Created by Will Parks on 2/26/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TiledImageView : UIView {
    CGFloat imageScale;
    UIImage* image;
    CGRect imageRect;
}
@property (retain) UIImage* image;

-(id)initWithFrame:(CGRect)_frame image:(UIImage*)image scale:(CGFloat)scale;

@end
