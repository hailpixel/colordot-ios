//
//  Palette+HailpixelIntegration.m
//  colordot-ios
//
//  Created by Colin on 10/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "Palette+HailpixelIntegration.h"
#import "Color.h"

@implementation Palette (HailpixelIntegration)


//- (id)initWithHailpixelURL:(NSURL *)hailpixelURL;
//{
//    
//}


- (NSURL *)generateHailpixelURL
{
    NSMutableArray *hexNums = [[NSMutableArray alloc] init];
    for (Color *color in self.colorsArray) {
        NSString *hexNum = [[color.hexString substringFromIndex:1] stringByAppendingString:@","];
        [hexNums addObject:hexNum];
    }
    
    NSString *fragment = [hexNums componentsJoinedByString:@""];
    return [NSURL URLWithString:[NSString stringWithFormat:@"#%@", fragment] relativeToURL:HAILPIXELBASEURL];
}

@end
