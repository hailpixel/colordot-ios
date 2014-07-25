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
    /*
     Grayscale colors fail HSB conversion, but their RGB equivalents do not. Converting grayscale to RGB first allows for all colors to work as expected with this instance method.
     */
    CGFloat colorHue = [self.hue floatValue], colorSaturation = [self.saturation floatValue], colorBrightness = [self.brightness floatValue];

    // Hue loops rather than min/max
    colorHue += hue;
    if (colorHue >= 1.0f) colorHue -= 1.0f;
    else if (colorHue < 0.0f) colorHue += 1.0f;
    
    colorSaturation += saturation;
    colorBrightness += brightness;
    
    self.hue = [NSNumber numberWithFloat:colorHue];
    self.saturation = [NSNumber numberWithFloat:colorSaturation];
    self.brightness = [NSNumber numberWithFloat:colorBrightness];
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
