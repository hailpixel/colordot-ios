//
//  NavigationControllerDelegate.h
//  colordot-ios
//
//  Created by Colin on 9/2/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavigationControllerDelegate : NSObject <UINavigationControllerDelegate>

@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactionController;

@end
