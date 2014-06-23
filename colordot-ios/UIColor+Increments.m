//
//  UIColor+Increments.m
//  UIColorIncrements
//
//  Created by Colin on 3/13/14.
//  Copyright (c) 2014 Colin Jackson
//

#import "UIColor+Increments.h"

@implementation UIColor (Increments)

#pragma mark - HSB instantiation methods
- (UIColor *)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
    /*
     Grayscale colors fail HSB conversion, but their RGB equivalents do not. Converting grayscale to RGB first allows for all colors to work as expected with this instance method.
     */
    CGFloat colorRed = 0.0f, colorGreen = 0.0f, colorBlue = 0.0f, colorAlpha = 0.0f, colorHue = 0.0f, colorSaturation = 0.0f, colorBrightness = 0.0f;
    [self getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
    UIColor *rgbColor = [UIColor colorWithRed:colorRed green:colorGreen blue:colorBlue alpha:1.0f];
    [rgbColor getHue:&colorHue saturation:&colorSaturation brightness:&colorBrightness alpha:NULL];
    
    // Hue loops rather than min/max
    colorHue += hue;
    if (colorHue >= 1.0f) colorHue -= 1.0f;
    else if (colorHue < 0.0f) colorHue += 1.0f;
    
    colorSaturation += saturation;
    colorBrightness += brightness;
    colorAlpha += alpha;
    
    return [UIColor colorWithHue:colorHue saturation:colorSaturation brightness:colorBrightness alpha:colorAlpha];
}

- (UIColor *)cho_colorWithChangeToHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness
{
    return [self cho_colorWithChangeToHue:hue saturation:saturation brightness:brightness alpha:0.0f];
}

- (UIColor *)cho_colorWithChangeToHue:(CGFloat)hue;
{
    return [self cho_colorWithChangeToHue:hue saturation:0.0f brightness:0.0f];
}

- (UIColor *)cho_colorWithChangeToSaturation:(CGFloat)saturation
{
    return [self cho_colorWithChangeToHue:0.0f saturation:saturation brightness:0.0f];
}

- (UIColor *)cho_colorWithChangeToBrightness:(CGFloat)brightness
{
    return [self cho_colorWithChangeToHue:0.0f saturation:0.0f brightness:brightness];
}


#pragma mark - RGB instantiation methods
- (UIColor *)cho_colorWithChangeToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    CGFloat colorRed = 0.0f, colorGreen = 0.0f, colorBlue = 0.0f, colorAlpha = 0.0f;
    [self getRed:&colorRed green:&colorGreen blue:&colorBlue alpha:&colorAlpha];
    
    colorRed += red;
    colorGreen += green;
    colorBlue += blue;
    colorAlpha += alpha;
    
    return [UIColor colorWithRed:colorRed green:colorGreen blue:colorBlue alpha:colorAlpha];
}

- (UIColor *)cho_colorWithChangeToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [self cho_colorWithChangeToRed:red green:green blue:blue alpha:0.0f];
}

- (UIColor *)cho_colorWithChangeToRed:(CGFloat)red
{
    return [self cho_colorWithChangeToRed:red green:0.0f blue:0.0f];
}

- (UIColor *)cho_colorWithChangeToGreen:(CGFloat)green
{
    return [self cho_colorWithChangeToRed:0.0f green:green blue:0.0f];
}

- (UIColor *)cho_colorWithChangeToBlue:(CGFloat)blue
{
    return [self cho_colorWithChangeToRed:0.0f green:0.0f blue:blue];
}


#pragma mark - Alpha instantiation methods
- (UIColor *)cho_colorWithChangeToAlpha:(CGFloat)alpha
{
    CGFloat newAlpha = 0.0f;
    [self getWhite:NULL alpha:&newAlpha];
    return [self colorWithAlphaComponent:(alpha + newAlpha)];
}


@end
