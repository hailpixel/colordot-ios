//
//  PaletteVCGestureHandler.m
//  colordot-ios
//
//  Created by Colin on 6/28/14.
//  Copyright (c) 2014 Devin Hunt. All rights reserved.
//

#import "PaletteVCGestureHandler.h"
#import "PaletteViewController.h"

#import "Palette.h"
#import "Color.h"

@interface PaletteVCGestureHandler ()

@property CGFloat yLagged;

@end

@implementation PaletteVCGestureHandler

- (PaletteVCGestureHandler *)initWithPaletteVC:(PaletteViewController *)paletteVC
{
    self = [super init];
    if (self) {
        self.paletteVC = paletteVC;
        self.tableView = paletteVC.tableView;
    }
    return self;
}

#pragma mark - Drag up to add
// TODO (Colin): refactor this unholy abomination (helper methods)
- (void)respondToPan:(UIGestureRecognizer *)gestureRecognizer;
{
    CGFloat y = [gestureRecognizer locationInView:self.paletteVC.view].y;
    PaletteViewController *pvc = self.paletteVC;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView setAnimationsEnabled:NO];
        
        self.color = [NSEntityDescription insertNewObjectForEntityForName:@"Color" inManagedObjectContext:pvc.managedObjectContext];
        [self.color randomValues];
        self.color.order = [NSNumber numberWithUnsignedInteger:pvc.colorsArray.count];
        
        self.dragUpView.backgroundColor = self.color.UIColor;
        
        [pvc growDragUpViewByValue:42];
        [pvc.view bringSubviewToFront:pvc.pullButton];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat yDelta = y - self.yLagged;
        
        [pvc growDragUpViewByValue:-yDelta];
        
        CGRect buttonFrame = pvc.pullButton.frame;
        buttonFrame.origin.y += yDelta;
        pvc.pullButton.frame = buttonFrame;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat height = self.dragUpView.frame.size.height;
        pvc.pullButton.hidden = YES;
        
        if (height > ((3.0f / 8.0f) * pvc.view.bounds.size.height)) {
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
                
                NSLog(@"Color values: %@, %@, %@", self.color.hue, self.color.saturation, self.color.brightness);
                
                CGFloat a = 0.0f, b = 0.0f, c = 0.0f;
                [self.color.UIColor getHue:&a saturation:&b brightness:&c alpha:NULL];
                NSLog(@"UIColor values: %f, %f, %f", a, b, c);
                
                [pvc saveContext];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(pvc.colorsArray.count - 1) inSection:0];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                [self.tableView endUpdates];
                
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [pvc tableView:self.tableView didSelectRowAtIndexPath:indexPath];
                
                [pvc growDragUpViewByValue:-newHeight];
                
                [UIView setAnimationsEnabled:YES];
            }];
        } else {
            [UIView setAnimationsEnabled:YES];
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [pvc growDragUpViewByValue:-height];
            } completion:^(BOOL finished) {
                pvc.pullButton.hidden = NO;
                self.color = nil;
            }];
        }
        
        CGRect buttonFrame = pvc.pullButton.frame;
        buttonFrame.origin.y += (height - 42);
        pvc.pullButton.frame = buttonFrame;
    }
    
    self.yLagged = y;
}


#pragma mark - UIGestureRecognizer delegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    PaletteViewController *pvc = self.paletteVC;
    
    CGFloat y = [touch locationInView:pvc.view].y;
    if (y > (pvc.view.frame.size.height - 42) && pvc.activeCellIndexPath == nil && pvc.colorsArray.count < 6) return YES;
    return NO;
}


@end
