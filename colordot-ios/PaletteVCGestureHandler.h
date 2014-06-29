//
//  PaletteVCGestureHandler.h
//  colordot-ios
//
//  Created by Colin on 6/28/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaletteViewController;

@interface PaletteVCGestureHandler : NSObject <UIGestureRecognizerDelegate>

@property (weak, nonatomic) PaletteViewController *paletteVC;
@property (strong, nonatomic) UIView *dragUpView;
@property (weak, nonatomic) UITableView *tableView;

- (PaletteVCGestureHandler *)initWithPaletteVC:(PaletteViewController *)paletteVC;

- (void)respondToPan:(UIGestureRecognizer *)gestureRecognizer;

@end
