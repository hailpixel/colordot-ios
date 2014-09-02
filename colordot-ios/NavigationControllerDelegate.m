//
//  NavigationControllerDelegate.m
//  colordot-ios
//
//  Created by Colin on 9/2/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "NavigationControllerDelegate.h"
#import "Animator.h"
#import "PalettePickerViewController.h"

@interface NavigationControllerDelegate ()

@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) Animator *animator;

@end

@implementation NavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush && [fromVC isKindOfClass:[PalettePickerViewController class]]) {
        return self.animator;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.animator = [[Animator alloc] init];
    }
    
    return self;
}

@end
