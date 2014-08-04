//
//  Color+Increments.m
//  colordot-ios
//
//  Created by Colin on 7/25/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "Color+Increments.h"

@implementation Color (Increments)

#pragma mark - HSB instantiation methods
- (void)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    CGFloat colorHue = [self.hue floatValue], colorSaturation = [self.saturation floatValue], colorBrightness = [self.brightness floatValue];
    
    // Hue loops rather than min/max
    colorHue += hue;
    if (colorHue >= 1.0f) colorHue -= 1.0f;
    else if (colorHue < 0.0f) colorHue += 1.0f;
    self.hue = [NSNumber numberWithFloat:colorHue];
    
    colorSaturation += saturation;
    colorBrightness += brightness;
    NSArray *values = @[[NSNumber numberWithFloat:colorSaturation], [NSNumber numberWithFloat:colorBrightness]];
    NSMutableArray *minmaxedValues = [[NSMutableArray alloc] init];
    for (NSNumber *value in values) {
        if ([value floatValue] > 1.0f) {
            [minmaxedValues addObject:@1];
        } else if ([value floatValue] < 0.0f) {
            [minmaxedValues addObject:@0];
        } else {
            [minmaxedValues addObject:value];
        }
    }
    self.saturation = minmaxedValues[0];
    self.brightness = minmaxedValues[1];
}

- (void)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness
{
    [self cho_colorWithChangeToHue:hue saturation:saturation brightness:brightness alpha:0.0f];
}

- (void)cho_colorWithChangeToHue:(CGFloat)hue;
{
    [self cho_colorWithChangeToHue:hue saturation:0.0f brightness:0.0f];
}

- (void)cho_colorWithChangeToSaturation:(CGFloat)saturation
{
    [self cho_colorWithChangeToHue:0.0f saturation:saturation brightness:0.0f];
}

- (void)cho_colorWithChangeToBrightness:(CGFloat)brightness
{
    [self cho_colorWithChangeToHue:0.0f saturation:0.0f brightness:brightness];
}

@end
