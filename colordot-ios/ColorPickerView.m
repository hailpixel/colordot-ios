//
//  ColorPickerView.m
//  colordot-ios
//
//  Created by Colin on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "ColorPickerView.h"

@implementation ColorPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self hexLabelSetup];
    }
    return self;
}


#pragma mark - Private methods
- (void)hexLabelSetup
{
    CGFloat inset = (self.bounds.size.width / 2.0f) - 50.0f;
    UILabel *hexLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset, inset, 100.0f, 100.0f)];
    
    hexLabel.clipsToBounds = YES;
    hexLabel.layer.cornerRadius = 50.0f;
    hexLabel.backgroundColor = [UIColor blackColor];
    hexLabel.alpha = 0.63f;
    hexLabel.textColor = [UIColor whiteColor];
    hexLabel.text = @"#XXYYZZ";
    hexLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:hexLabel];
    self.hexLabel = hexLabel;
}

@end
