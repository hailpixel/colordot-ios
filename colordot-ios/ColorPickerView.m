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
        [self initializeInterface];
        self.state = ColorPickerStateTouch;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutInterface];
}

- (void)setState:(ColorPickerState)state {
    _state = state;
    
    switch(self.state) {
        case ColorPickerStateTouch:
            self.openCameraButton.enabled = YES;
            self.openCameraButton.hidden = NO;
            
            self.closeCameraButton.enabled = NO;
            self.closeCameraButton.hidden = YES;
            break;
            
        case ColorPickerStateCameraInitializing:
            self.openCameraButton.enabled = NO;
            self.openCameraButton.hidden = YES;
            break;
            
        case ColorPickerStateCameraOpening:
            break;
            
        case ColorPickerStateCamera:
            self.closeCameraButton.enabled = YES;
            self.closeCameraButton.hidden = NO;
            break;
            
        case ColorPickerStateCameraClosing:
            self.closeCameraButton.enabled = YES;
            self.closeCameraButton.hidden = NO;
            break;
    }
}

#pragma mark - Private methods
- (void)initializeInterface
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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 32);
    [button setTitle:@"Camera" forState:UIControlStateNormal];
    
    [self addSubview:button];
    self.openCameraButton = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 32);
    [button setTitle:@"Close" forState:UIControlStateNormal];
    
    [self addSubview:button];
    self.closeCameraButton = button;
    
    [self layoutInterface];
}

- (void)layoutInterface
{
    self.hexLabel.center = self.center;
    self.openCameraButton.center = CGPointMake(self.center.x, self.bounds.size.height - 20.0f);
    self.closeCameraButton.center = self.openCameraButton.center;
}

@end
