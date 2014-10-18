//
//  UILocationAxis.h
//  colordot-ios
//
//  Created by Colin on 10/18/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocationAxis : UIView

@property (weak, nonatomic) UIView *trackView;
@property (weak, nonatomic) UIView *locatorView;

@property (nonatomic) float value;

@end
