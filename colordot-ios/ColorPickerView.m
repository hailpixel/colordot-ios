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
        [self interfaceSetup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutInterface];
}

#pragma mark - Private methods
- (void)interfaceSetup
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
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    [self addSubview:cameraButton];
    self.cameraButton = cameraButton;
    
    [self layoutInterface];
}

- (void)layoutInterface
{
    self.hexLabel.center = self.center;
    self.cameraButton.center = CGPointMake(self.bounds.size.width - 20.0f, self.center.y);
}

@end
