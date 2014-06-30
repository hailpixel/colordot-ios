//
//  CameraPickerView.m
//  colordot-ios
//
//  Created by Devin Hunt on 6/25/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "CameraPickerView.h"

@implementation CameraPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    NSLog(@"%@", NSStringFromCGRect(frame));
    if(self.previewLayer) {
        self.previewLayer.frame = self.bounds;
        [self setCameraMask];
    }
}

- (void)setPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer {
    if(self.previewLayer) {
        [self.previewLayer removeFromSuperlayer];
    }
    
    _previewLayer = previewLayer;
    
    if(self.previewLayer) {
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.bounds;
        [self.layer addSublayer:self.previewLayer];
        [self setCameraMask];
    }
    
}

- (void) setCameraMask {
    CAShapeLayer *mask = [CAShapeLayer layer];
    
    mask.frame = self.bounds;
    mask.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((mask.frame.size.width / 2.0f) - kCameraPickerViewHoleRadius,
                                                                  (mask.frame.size.height / 2.0f) - kCameraPickerViewHoleRadius,
                                                                  kCameraPickerViewHoleRadius * 2.0f,
                                                                  kCameraPickerViewHoleRadius * 2.0f)].CGPath;
    mask.fillColor = [UIColor whiteColor].CGColor;
    self.previewLayer.mask = mask;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
