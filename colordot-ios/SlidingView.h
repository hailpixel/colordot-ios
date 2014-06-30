//
//  SlidingView.h
//  colordot-ios
//
//  Created by Devin Hunt on 6/30/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSlidingThreshold .3f

typedef enum {
    SlidingViewDefault,
    SlidingViewRight
} SlidingViewStates;

@interface SlidingView : UIView

@property (nonatomic, strong) UIView *centerView, *rightView;

@property (nonatomic) SlidingViewStates state;

@end
