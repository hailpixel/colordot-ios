//
//  Palette.m
//  colordot-ios
//
//  Created by Colin on 7/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "Palette.h"
#import "Color.h"

@implementation Palette

@dynamic created;
@dynamic colors;

- (NSArray *)colorsArray
{
    NSSortDescriptor *colorsSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *colorsArray = [self.colors sortedArrayUsingDescriptors:@[colorsSortDescriptor]];
    
    return colorsArray;
}

@end
