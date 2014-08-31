//
//  ColorPickerView.m
//  colordot-ios
//
//  Created by Colin on 6/24/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "ColorPickerView.h"
#import "Color.h"

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
            [self revealCamera];
            break;
            
        case ColorPickerStateCamera:
            self.closeCameraButton.enabled = YES;
            self.closeCameraButton.hidden = NO;
            break;
            
        case ColorPickerStateCameraClosing:
            [self hideCamera];
            self.closeCameraButton.enabled = YES;
            self.closeCameraButton.hidden = NO;
            break;
    }
}

- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    if(self.previewLayer != nil) {
        [self.previewLayer removeFromSuperlayer];
    }
    
    _previewLayer = previewLayer;
    
    if(self.previewLayer) {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.bounds;
        [self.layer insertSublayer:self.previewLayer below:self.hexLabel.layer];
        [self setMask];
    }
}

- (void)setPickedColor:(Color *)color {
    self.backgroundColor = [color UIColor];
    self.hexLabel.backgroundColor = [color UIColor];
    self.hexLabel.text = [color hexString];
    
    if([color.brightness floatValue] > .5) {
        self.hexLabel.textColor = [UIColor blackColor];
    } else {
        self.hexLabel.textColor = [UIColor whiteColor];
    }
}

#pragma mark - Mask setup and animation

- (void)setMask {
    CAShapeLayer *mask = [CAShapeLayer layer];
    CGRect bounds = self.bounds;
    
    mask.frame = bounds;
    mask.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f, 0, 0)].CGPath;
    mask.fillColor = [UIColor whiteColor].CGColor;
    self.previewLayer.mask = mask;
}

- (void)revealCamera {
    CAShapeLayer *mask = (CAShapeLayer *)self.previewLayer.mask;
    CGRect bounds = mask.frame;
    CGFloat diameter = MIN(bounds.size.width, bounds.size.height) - 20.0f;
    CGPathRef oldPath = mask.path;
    CGPathRef newPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(
                                        (bounds.size.width - diameter) / 2.0f,
                                        (bounds.size.height - diameter) / 2.0f,
                                        diameter,
                                        diameter)].CGPath;
    
    [CATransaction begin];
    CABasicAnimation *revealAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    revealAnimation.fromValue = (__bridge id)oldPath;
    revealAnimation.toValue = (__bridge id)newPath;
    revealAnimation.duration = .4f;
    revealAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    mask.path = newPath;
    
    [CATransaction setCompletionBlock:^{
        self.state = ColorPickerStateCamera;
    }];
    
    [mask addAnimation:revealAnimation forKey:@"revealAnimation"];
    [CATransaction commit];
}

- (void)hideCamera {
    CAShapeLayer *mask = (CAShapeLayer *)self.previewLayer.mask;
    CGRect bounds = mask.frame;
    CGPathRef oldPath = mask.path;
    CGPathRef newPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(bounds.size.width / 2.0f, bounds.size.height / 2.0f, 0, 0)].CGPath;
    
    [CATransaction begin];
    CABasicAnimation *revealAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    revealAnimation.fromValue = (__bridge id)oldPath;
    revealAnimation.toValue = (__bridge id)newPath;
    revealAnimation.duration = .3f;
    revealAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    mask.path = newPath;
    
    [CATransaction setCompletionBlock:^{
        self.previewLayer.mask = nil;
        [self.previewLayer removeFromSuperlayer];
        self.state = ColorPickerStateTouch;
    }];
    
    [mask addAnimation:revealAnimation forKey:@"revealAnimation"];
    [CATransaction commit];
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
