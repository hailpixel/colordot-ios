//
//  NavigationControllerDelegate.m
//  colordot-ios
//
//  Created by Colin on 9/2/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "NavigationControllerDelegate.h"
#import "PushAnimator.h"
#import "PopAnimator.h"
#import "PalettePickerViewController.h"

@interface NavigationControllerDelegate ()

@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) PushAnimator *pushAnimator;
@property (strong, nonatomic) PopAnimator *popAnimator;
@end

@implementation NavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush && [fromVC isKindOfClass:[PalettePickerViewController class]]) {
        return self.pushAnimator;
//    } else if (operation == UINavigationControllerOperationPop && [toVC isKindOfClass:[PalettePickerViewController class]]) {
//        return self.popAnimator;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.pushAnimator = [[PushAnimator alloc] init];
        self.popAnimator = [[PopAnimator alloc] init];
    }
    
    return self;
}

@end
