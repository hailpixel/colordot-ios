//
//  UILocationAxis.m
//  colordot-ios
//
//  Created by Colin on 10/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "UILocationAxis.h"

@interface UILocationAxis ()

@property (weak, nonatomic) UIView *wrappingLocatorView;

@end

@implementation UILocationAxis

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _value = 0.0;
        [self initializeInterface];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initializeInterface
{
    UIView *trackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
    trackView.backgroundColor = [UIColor whiteColor];
    [self addSubview:trackView];
    self.trackView = trackView;
    
    UIView *locatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    locatorView.layer.cornerRadius = 12;
    locatorView.layer.borderColor = [[UIColor whiteColor] CGColor];
    locatorView.layer.borderWidth = 2.0f;
    
    [self addSubview:locatorView];
    self.locatorView = locatorView;
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    CGRect trackViewFrame = self.trackView.frame;
    trackViewFrame.size.width = self.bounds.size.width;
    self.trackView.frame = trackViewFrame;
    self.trackView.center = self.center;
    
    self.locatorView.center = CGPointMake((self.bounds.size.width * self.value), self.center.y);
    [self wrapLocatorView];
}


#pragma mark - Custom setters
- (void)setValue:(float)value
{
    _value = value;
    self.locatorView.center = (CGPointMake((self.bounds.size.width * self.value), self.center.y));
    [self wrapLocatorView];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.trackView.backgroundColor = backgroundColor;
    self.locatorView.layer.borderColor = [backgroundColor CGColor];
    if (self.wrappingLocatorView) {
        self.wrappingLocatorView.layer.borderColor = [backgroundColor CGColor];
    }
}


#pragma mark - Private methods
- (void)wrapLocatorView
{
    BOOL isOutsideLeftBound = self.locatorView.frame.origin.x < 0;
    BOOL isOutsideRightBound = (self.locatorView.frame.origin.x + self.locatorView.frame.size.width) > self.bounds.size.width;
    if (!isOutsideLeftBound && !isOutsideRightBound) {
        if (self.wrappingLocatorView) {
            [self.wrappingLocatorView removeFromSuperview];
            self.wrappingLocatorView = nil;
            
        }
        return;
    }
    
    if (!self.wrappingLocatorView) {
        UIView *wrappingLocatorView = [[UIView alloc] initWithFrame:self.locatorView.frame];
        wrappingLocatorView.layer.cornerRadius = 12;
        wrappingLocatorView.layer.borderWidth = 2;
        wrappingLocatorView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        [self addSubview:wrappingLocatorView];
        self.wrappingLocatorView = wrappingLocatorView;
    }

    CGPoint wrappingLocatorViewCenter = self.wrappingLocatorView.center;
    CGFloat newX = self.locatorView.center.x + (isOutsideLeftBound ? self.bounds.size.width : -self.bounds.size.width);
    wrappingLocatorViewCenter.x = newX;
    self.wrappingLocatorView.center = wrappingLocatorViewCenter;
}


@end
