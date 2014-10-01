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
        self.navigationControllerDelegate = self.paletteVC.navigationController.delegate;
    }
    return self;
}

#pragma mark - Drag up to add
- (void)respondToPan:(UIGestureRecognizer *)gestureRecognizer;
{
    CGFloat y = [gestureRecognizer locationInView:self.paletteVC.view].y;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self prepareColorAndDragUpViewForPaletteViewController:self.paletteVC];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat yDelta = y - self.yLagged;
        
        [self updateDragToAddActionByValue:yDelta forPaletteViewController:self.paletteVC];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat height = self.dragUpView.frame.size.height;
        self.paletteVC.pullButton.hidden = YES;
        
        if (height > ((3.0f / 8.0f) * self.paletteVC.view.bounds.size.height)) {
            [self completeDragToAddActionFromHeight:height forPaletteViewController:self.paletteVC];
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

- (void)prepareColorAndDragUpViewForPaletteViewController:(PaletteViewController *)pvc
{
    [UIView setAnimationsEnabled:NO];

    self.color = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:pvc.managedObjectContext];
    [self.color randomValues];
    self.color.order = [NSNumber numberWithUnsignedInteger:pvc.colorsArray.count];
    
    self.dragUpView.backgroundColor = self.color.UIColor;
    
    [pvc growDragUpViewByValue:42];
    [pvc.view bringSubviewToFront:pvc.pullButton];
}

- (void)updateDragToAddActionByValue:(CGFloat)yDelta forPaletteViewController:(PaletteViewController *)pvc
{
    [pvc growDragUpViewByValue:-yDelta];
    
    CGRect buttonFrame = pvc.pullButton.frame;
    buttonFrame.origin.y += yDelta;
    pvc.pullButton.frame = buttonFrame;
}

- (void)completeDragToAddActionFromHeight:(CGFloat)height forPaletteViewController:(PaletteViewController *)pvc
{
    [UIView setAnimationsEnabled:YES];
    
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
    PaletteViewController *pvc = self.paletteVC;
    UITableView *tableView = self.tableView;
    CGPoint touchPoint = [longPressRecognizer locationInView:tableView];
    CGFloat x = touchPoint.x;
    CGFloat y = touchPoint.y;
    
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        // grab reordering cell
        pvc.reorderingCellIndexPath = nil;
        NSUInteger rowCount = pvc.colorsArray.count;
        int row = 0;
        while (pvc.reorderingCellIndexPath == nil) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            CGRect tableViewRect = [tableView rectForRowAtIndexPath:indexPath];
            
            if (CGRectContainsPoint(tableViewRect, touchPoint)) pvc.reorderingCellIndexPath = indexPath;
            else row++;
            
            if (row >= rowCount) {
                NSLog(@"Did not find touch.");
                abort();
            }
        }
        
        // add clone view to tableView
        UITableViewCell *reorderingCell = [tableView cellForRowAtIndexPath:pvc.reorderingCellIndexPath];
        CGRect reorderingCellRect = [tableView rectForRowAtIndexPath:pvc.reorderingCellIndexPath];
        
        self.reorderingCellView = [reorderingCell clone];
        self.reorderingCellView.frame = reorderingCellRect;
        [self.reorderingCellView addShadow];
        
        [tableView addSubview:self.reorderingCellView];

        [UIView animateWithDuration:0.2 animations:^{
            [self.reorderingCellView setTransform:CGAffineTransformMakeScale(1.2f, 1.2f)];
        }];
        
        [tableView reloadData];
    } else if (longPressRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat xDelta = x - self.xLagged;
        CGFloat yDelta = y - self.yLagged;
        
        CGRect reorderingCellViewFrame = self.reorderingCellView.frame;
        reorderingCellViewFrame.origin.x += xDelta;
        reorderingCellViewFrame.origin.y += yDelta;
        self.reorderingCellView.frame = reorderingCellViewFrame;
        
        CGRect reorderingCellFrame = [tableView rectForRowAtIndexPath:pvc.reorderingCellIndexPath];
        if (!CGRectContainsPoint(reorderingCellFrame, touchPoint)) {
            NSInteger shift = y < reorderingCellFrame.origin.y ? -1 : 1;
            NSIndexPath *oldIndexPath = pvc.reorderingCellIndexPath;
            NSUInteger index = oldIndexPath.row;
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(index + shift) inSection:0];

            Color *movingColor = pvc.colorsArray[index];
            Color *displacedColor = pvc.colorsArray[index + shift];
            
            [tableView beginUpdates];
            movingColor.order = [NSNumber numberWithInteger:(index + shift)];
            displacedColor.order = [NSNumber numberWithInteger:index];
            [pvc saveContext];
            
            [tableView moveRowAtIndexPath:newIndexPath toIndexPath:oldIndexPath]; // new to old because cell being moved goes "over" cell being displaced
            pvc.reorderingCellIndexPath = newIndexPath;
            [tableView endUpdates];
        }
    } else if (longPressRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect movedCellFrame = [tableView rectForRowAtIndexPath:pvc.reorderingCellIndexPath];
        pvc.reorderingCellIndexPath = nil;
        [UIView animateWithDuration:0.2 animations:^{
            // TODO (Colin): convert this animation to a CGAffineTransformIdentity and center the clone view over the moved cell, to fix the hexLabel not resizing with the view.
            self.reorderingCellView.frame = movedCellFrame;
        } completion:^(BOOL finished) {
            [self.reorderingCellView removeFromSuperview];
            self.reorderingCellView = nil;
            [tableView reloadData];
        }];
    }
    
    self.xLagged = x;
    self.yLagged = y;
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
