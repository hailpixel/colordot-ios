//
//  PopAnimator.m
//  colordot-ios
//
//  Created by Colin on 9/3/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PopAnimator.h"
#import "PalettePickerViewController.h"
#import "UIView+Clone.h"
#import "UIView+Shadow.h"

@implementation PopAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    PalettePickerViewController *toVC = (PalettePickerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UITableView *tableView = toVC.tableView;
    NSIndexPath *selectedRow = toVC.selectedRow;
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:selectedRow];
    selectedCell.alpha = 0;
    CGRect selectedCellRect = [tableView convertRect:[tableView rectForRowAtIndexPath:selectedRow] toView:tableView.superview];
    
    [[transitionContext containerView] addSubview:toVC.view];
    [[transitionContext containerView] bringSubviewToFront:fromVC.view];
    
    CGFloat xScale = selectedCellRect.size.width / fromVC.view.frame.size.height;
    CGFloat yScale = selectedCellRect.size.height / fromVC.view.frame.size.width;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGAffineTransform rotate = CGAffineTransformMakeRotation(-M_PI/2);
        CGAffineTransform scale = CGAffineTransformMakeScale(xScale, yScale);
        fromVC.view.transform = CGAffineTransformConcat(rotate, scale);
        fromVC.view.frame = selectedCellRect;
    } completion:^(BOOL finished) {
        selectedCell.alpha = 1;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
