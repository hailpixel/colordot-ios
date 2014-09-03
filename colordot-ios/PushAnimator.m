//
//  PushAnimator.m
//  colordot-ios
//
//  Created by Colin on 9/3/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PushAnimator.h"
#import "PalettePickerViewController.h"
#import "UIView+Clone.h"
#import "UIView+Shadow.h"

@implementation PushAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    PalettePickerViewController *fromVC = (PalettePickerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UITableView *tableView = fromVC.tableView;
    NSIndexPath *selectedRow = fromVC.selectedRow;
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:selectedRow];
    UIView *selectedCellView = [selectedCell clone];
    selectedCell.alpha = 0;
    selectedCellView.frame = [tableView convertRect:[tableView rectForRowAtIndexPath:selectedRow] toView:[tableView superview]];
    [selectedCellView addShadow];
    
    [fromVC.view addSubview:selectedCellView];
    
    CGFloat xScale = fromVC.view.frame.size.width / selectedCellView.frame.size.height;
    CGFloat yScale = fromVC.view.frame.size.height / selectedCellView.frame.size.width;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI/2);
        CGAffineTransform scale = CGAffineTransformMakeScale(xScale, yScale);
        selectedCellView.transform = CGAffineTransformConcat(rotate, scale);
        selectedCellView.center = fromVC.view.center;
    } completion:^(BOOL finished) {
        [selectedCellView removeFromSuperview];
        [[transitionContext containerView] addSubview:toVC.view];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
