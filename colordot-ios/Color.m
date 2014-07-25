//
//  Color.m
//  colordot-ios
//
//  Created by Colin on 7/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "Color.h"
#import "Palette.h"


@implementation Color

@dynamic brightness;
@dynamic hue;
@dynamic saturation;
@dynamic order;
@dynamic palette;

- (UIColor *)UIColor
{
    CGFloat hue = [self.hue floatValue];
    CGFloat saturation = [self.saturation floatValue];
    CGFloat brightness = [self.brightness floatValue];
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
}

- (void)randomValues
{
    NSMutableArray *randomNumbers = [[NSMutableArray alloc] init];
    for (int i=0; i<3; i++) {
        float randomFloat = (arc4random() % 100) / 100.0f;
        [randomNumbers addObject:[NSNumber numberWithFloat:randomFloat]];
    }
    
    self.hue = randomNumbers[0];
    self.saturation = randomNumbers[1];
    self.brightness = randomNumbers[2];
}

@end
