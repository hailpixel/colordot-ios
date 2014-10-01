//
//  PaletteVCGestureHandler.m
//  colordot-ios
//
//  Created by Colin on 6/28/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PaletteVCGestureHandler.h"
#import "PaletteViewController.h"
#import "NavigationControllerDelegate.h"

#import "Palette.h"
#import "Color.h"
#import "UIView+Clone.h"
#import "UIView+Shadow.h"

@interface PaletteVCGestureHandler ()

@property CGFloat xLagged;
@property CGFloat yLagged;
@property UIView *reorderingCellView;
@property NavigationControllerDelegate *navigationControllerDelegate;

@end

@implementation PaletteVCGestureHandler

- (PaletteVCGestureHandler *)initWithPaletteVC:(PaletteViewController *)paletteVC
{
    self = [super init];
    if (self) {
        self.paletteVC = paletteVC;
        self.tableView = paletteVC.tableView;
        self.navigationControllerDelegate = paletteVC.navigationController.delegate;
    }
    return self;
}

#pragma mark - Drag up to add
- (void)respondToPan:(UIGestureRecognizer *)gestureRecognizer;
{
    CGFloat y = [gestureRecognizer locationInView:self.paletteVC.view].y;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self prepareColorAndDragUpView];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat yDelta = y - self.yLagged;
        
        [self updateDragToAddActionByValue:yDelta];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat height = self.dragUpView.frame.size.height;
        self.paletteVC.pullButton.hidden = YES;
        
        if (height > ((3.0f / 8.0f) * self.paletteVC.view.bounds.size.height)) {
            [self completeDragToAddActionFromHeight:height];
        } else {
            [self dismissDragUpActionFromHeight:height forPaletteViewController:self.paletteVC];
        }
        
        UIButton *pullButton = self.paletteVC.pullButton;
        CGRect buttonFrame = pullButton.frame;
        buttonFrame.origin.y += (height - 42);
        pullButton.frame = buttonFrame;
    }
    
    self.yLagged = y;
}

- (void)prepareColorAndDragUpView
{
    [UIView setAnimationsEnabled:NO];   // Let view updates occur real-time with user input

    PaletteViewController *pvc = self.paletteVC;
    
    self.color = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:pvc.managedObjectContext];
    [self.color randomValues];
    self.color.order = [NSNumber numberWithUnsignedInteger:pvc.colorsArray.count];
    
    self.dragUpView.backgroundColor = self.color.UIColor;
    
    [pvc growDragUpViewByValue:42];
    [pvc.view bringSubviewToFront:pvc.pullButton];
}

- (void)updateDragToAddActionByValue:(CGFloat)yDelta
{
    PaletteViewController *pvc = self.paletteVC;

    [pvc growDragUpViewByValue:-yDelta];
    
    CGRect buttonFrame = pvc.pullButton.frame;
    buttonFrame.origin.y += yDelta;
    pvc.pullButton.frame = buttonFrame;
}

- (void)completeDragToAddActionFromHeight:(CGFloat)height
{
    [UIView setAnimationsEnabled:YES];

    PaletteViewController *pvc = self.paletteVC;
    
    CGFloat viewHeight = pvc.view.bounds.size.height;
    CGFloat viewWidth = pvc.view.bounds.size.width;
    CGFloat newHeight = viewHeight - (pvc.colorsArray.count * ROUNDUPHALF(0.2f * (viewHeight - viewWidth)));
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [pvc growDragUpViewByValue:(newHeight - self.dragUpView.frame.size.height)];
    } completion:^(BOOL finished) {
        [UIView setAnimationsEnabled:NO];
        
        [self.tableView beginUpdates];
        
        [pvc.palette addColorsObject:self.color];
        [pvc saveContext];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(pvc.colorsArray.count - 1) inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [pvc tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        
        [pvc growDragUpViewByValue:-newHeight];
        
        [UIView setAnimationsEnabled:YES];
    }];
}

- (void)dismissDragUpActionFromHeight:(CGFloat)height forPaletteViewController:(PaletteViewController *)pvc
{
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [pvc growDragUpViewByValue:-height];
    } completion:^(BOOL finished) {
        pvc.pullButton.hidden = NO;
        self.color = nil;
    }];
}

#pragma mark - Swipe to go back
- (void)respondToScreenEdge:(UIScreenEdgePanGestureRecognizer *)screenEdgeRecognizer
{
    CGFloat x = [screenEdgeRecognizer locationInView:self.paletteVC.view.superview].x;
    if (screenEdgeRecognizer.state == UIGestureRecognizerStateBegan) {
        self.navigationControllerDelegate.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.paletteVC.navigationController popViewControllerAnimated:YES];
    } else if (screenEdgeRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat progress = x / self.paletteVC.view.bounds.size.width;
        [self.navigationControllerDelegate.interactionController updateInteractiveTransition:progress];
    } else if (screenEdgeRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.xLagged < x - 5 || x > (self.paletteVC.view.bounds.size.width / 2)) {
            [self.navigationControllerDelegate.interactionController finishInteractiveTransition];
        } else {
            [self.navigationControllerDelegate.interactionController cancelInteractiveTransition];
        }
    }
    
    self.xLagged = x;
}

#pragma mark - Tap and hold to reorder
- (void)respondToLongPress:(UILongPressGestureRecognizer *)longPressRecognizer
{
    CGPoint touchPoint = [longPressRecognizer locationInView:self.tableView];
    
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.paletteVC setReorderingCellIndexPathForTouchPoint:touchPoint];
        [self instantiateCloneFromReorderingCell];
    } else if (longPressRecognizer.state == UIGestureRecognizerStateChanged) {
        [self moveReorderingCellViewWithTouchPoint:touchPoint];
        
        CGRect reorderingCellFrame = [self.tableView rectForRowAtIndexPath:self.paletteVC.reorderingCellIndexPath];
        if (!CGRectContainsPoint(reorderingCellFrame, touchPoint)) {
            NSInteger shift = touchPoint.y < reorderingCellFrame.origin.y ? -1 : 1;
            [self changeReorderingCellInTableViewWithShift:shift];
        }
    } else if (longPressRecognizer.state == UIGestureRecognizerStateEnded) {
        [self dismissReorderingCellClone];
    }
    
    self.xLagged = touchPoint.x;
    self.yLagged = touchPoint.y;
}

- (void)instantiateCloneFromReorderingCell
{
    PaletteViewController *pvc = self.paletteVC;
    
    UITableViewCell *reorderingCell = [self.tableView cellForRowAtIndexPath:pvc.reorderingCellIndexPath];
    CGRect reorderingCellRect = [self.tableView rectForRowAtIndexPath:pvc.reorderingCellIndexPath];
    
    self.reorderingCellView = [reorderingCell clone];
    self.reorderingCellView.frame = reorderingCellRect;
    [self.reorderingCellView addShadow];
    
    [self.tableView addSubview:self.reorderingCellView];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.reorderingCellView setTransform:CGAffineTransformMakeScale(1.2f, 1.2f)];
    }];
    
    [self.tableView reloadData];
}

- (void)moveReorderingCellViewWithTouchPoint:(CGPoint)touchPoint
{
    CGFloat xDelta = touchPoint.x - self.xLagged;
    CGFloat yDelta = touchPoint.y - self.yLagged;
    
    CGRect reorderingCellViewFrame = self.reorderingCellView.frame;
    reorderingCellViewFrame.origin.x += xDelta;
    reorderingCellViewFrame.origin.y += yDelta;
    self.reorderingCellView.frame = reorderingCellViewFrame;
}

- (void)changeReorderingCellInTableViewWithShift:(int)shift
{
    PaletteViewController *pvc = self.paletteVC;
    
    NSIndexPath *oldIndexPath = pvc.reorderingCellIndexPath;
    NSUInteger index = oldIndexPath.row;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(index + shift) inSection:0];
    
    Color *movingColor = pvc.colorsArray[index];
    Color *displacedColor = pvc.colorsArray[index + shift];
    
    [self.tableView beginUpdates];
    movingColor.order = [NSNumber numberWithInteger:(index + shift)];
    displacedColor.order = [NSNumber numberWithInteger:index];
    [pvc saveContext];
    
    [self.tableView moveRowAtIndexPath:newIndexPath toIndexPath:oldIndexPath]; // new to old because cell being moved goes "over" cell being displaced
    pvc.reorderingCellIndexPath = newIndexPath;
    [self.tableView endUpdates];
}

- (void)dismissReorderingCellClone
{
    PaletteViewController *pvc = self.paletteVC;
    
    UITableViewCell *movedCell = [self.tableView cellForRowAtIndexPath:pvc.reorderingCellIndexPath];
    [UIView animateWithDuration:0.2 animations:^{
        self.reorderingCellView.center = movedCell.center;
        [self.reorderingCellView setTransform:CGAffineTransformIdentity];
    } completion:^(BOOL finished) {
        [self.reorderingCellView removeFromSuperview];
        self.reorderingCellView = nil;
        [self.tableView reloadData];
    }];
    
    pvc.reorderingCellIndexPath = nil;
}


#pragma mark - UIGestureRecognizer delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    PaletteViewController *pvc = self.paletteVC;
    
    CGFloat y = [touch locationInView:pvc.view].y;
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && pvc.activeCellIndexPath == nil) return YES;
    else if (y > (pvc.view.frame.size.height - 42) && pvc.activeCellIndexPath == nil && pvc.colorsArray.count < 6) return YES;
    return NO;
}


@end
