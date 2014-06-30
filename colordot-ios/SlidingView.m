//
//  SlidingView.m
//  colordot-ios
//
//  Created by Devin Hunt on 6/30/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "SlidingView.h"

@interface SlidingView ()

- (void)onPan:(UIPanGestureRecognizer *)gesture;

@end

@implementation SlidingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _state = SlidingViewDefault;
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

#pragma mark Interaction and State
- (void)setState:(SlidingViewStates)state {
    _state = state;
    
    CGAffineTransform transform;
    
    if(self.state == SlidingViewDefault) {
        transform = CGAffineTransformIdentity;
    } else if(self.state == SlidingViewRight) {
        transform = CGAffineTransformMakeTranslation(-self.bounds.size.width, 0.0f);
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        self.centerView.transform = transform;
        self.rightView.transform = transform;
    }];
}

- (void)onPan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];

    if(gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat offset = 0.0f;
        
        if(self.state == SlidingViewDefault) {
            offset = translation.x;
        } else {
            offset = translation.x - self.bounds.size.width;
        }
        
        offset = MAX(MIN(offset, 0), -self.bounds.size.width);
        
        NSLog(@"%f", offset);
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(offset, 0.0f);
        self.centerView.transform = transform;
        self.rightView.transform = transform;
        
    } else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if(self.state == SlidingViewDefault && translation.x < -self.bounds.size.width * kSlidingThreshold) {
            self.state = SlidingViewRight;
        } else {
            self.state = SlidingViewDefault;
        }
    }
    
}

#pragma mark Setters
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // TODO Duplication?
    if(self.centerView) {
        self.centerView.frame = self.bounds;
    }
    
    if(self.rightView) {
        self.rightView.frame = CGRectMake(self.bounds.size.width, 0.0f, self.bounds.size.width, self.bounds.size.height);
    }
}

- (void)setCenterView:(UIView *)centerView {
    _centerView = centerView;
    
    self.centerView.frame = self.bounds;
    [self addSubview:self.centerView];
}

- (void)setRightView:(UIView *)rightView {
    _rightView = rightView;
    
    self.rightView.frame = CGRectMake(self.bounds.size.width, 0.0f, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:self.rightView];
}

@end
