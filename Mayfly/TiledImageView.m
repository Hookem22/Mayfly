//
//  TiledImageView.m
//  Pow Wow
//
//  Created by Will Parks on 2/26/16.
//  Copyright © 2016 Mayfly. All rights reserved.
//

#import "TiledImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TiledImageView

@synthesize image;

// Set the layer's class to be CATiledLayer.
+ (Class)layerClass {
    return [CATiledLayer class];
}

// Create a new TiledImageView with the desired frame and scale.
-(id)initWithFrame:(CGRect)_frame image:(UIImage*)img scale:(CGFloat)scale {
    if ((self = [super initWithFrame:_frame])) {
        self.image = img;
        imageRect = CGRectMake(0.0f, 0.0f, CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage));
        imageScale = scale;
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        // levelsOfDetail and levelsOfDetailBias determine how
        // the layer is rendered at different zoom levels.  This
        // only matters while the view is zooming, since once the
        // the view is done zooming a new TiledImageView is created
        // at the correct size and scale.
        tiledLayer.levelsOfDetail = 4;
        tiledLayer.levelsOfDetailBias = 4;
        tiledLayer.tileSize = CGSizeMake(512.0, 512.0);
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Scale the context so that the image is rendered
    // at the correct size for the zoom level.
    CGContextScaleCTM(context, imageScale,imageScale);
    CGContextDrawImage(context, imageRect, image.CGImage);
    CGContextRestoreGState(context);
}

@end

