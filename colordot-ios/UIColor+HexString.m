//
//  UIColor+HexString.m
//  colordot-ios
//
//  Created by Colin on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "UIColor+HexString.h"

@implementation UIColor (HexString)

- (NSString *)cho_hexString
{
    CGFloat red = 0.0f, green = 0.0f, blue = 0.0f;
    [self getRed:&red green:&green blue:&blue alpha:NULL];
    red *= 255, blue *= 255, green *= 255;
    
    NSArray *colorParts = @[
                            [NSNumber numberWithInt:red],
                            [NSNumber numberWithInt:green],
                            [NSNumber numberWithInt:blue],
                            ];
    
    NSMutableString *hexString = [NSMutableString stringWithString:@"#"];
    for (NSNumber *colorPart in colorParts) {
        [hexString appendString:[NSString stringWithFormat:@"%02X", [colorPart intValue]]];
    }
    
    return hexString;
}

@end
