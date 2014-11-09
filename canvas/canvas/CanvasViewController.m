//
//  CanvasViewController.m
//  canvas
//
//  Created by Raylene Yung on 11/6/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "CanvasViewController.h"

@interface CanvasViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *trayView;
@property (weak, nonatomic) IBOutlet UIView *downArrow;

@property (weak, nonatomic) IBOutlet UIImageView *deadView;
@property (weak, nonatomic) IBOutlet UIImageView *excitedView;
@property (weak, nonatomic) IBOutlet UIImageView *happyView;
@property (weak, nonatomic) IBOutlet UIImageView *sadView;
@property (weak, nonatomic) IBOutlet UIImageView *tongueView;
@property (weak, nonatomic) IBOutlet UIImageView *winkView;


@property (nonatomic, strong) UIImageView *panningFace;

@property (nonatomic, assign) CGFloat extendedTrayY; // 320
@property (nonatomic, assign) CGFloat minimizedTrayY; // 520

@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Smiley tray pan gesture
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTrayPan:)];
    [self.trayView addGestureRecognizer:pgr];

    NSLog(@"tray frame: %@", NSStringFromCGRect(self.trayView.frame));
    NSLog(@"self.view frame: %@", NSStringFromCGRect(self.view.frame));
    
    self.extendedTrayY = self.trayView.frame.origin.y;
    self.minimizedTrayY = self.trayView.frame.origin.y + 200;
    NSLog(@"tray center max, min: %f, %f", self.extendedTrayY, self.minimizedTrayY);
    NSLog(@"self.view center: %f, %@", self.view.center.y, NSStringFromCGPoint(self.view.frame.origin));
    
    UIPanGestureRecognizer *smileyPGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onSmileyPan:)];
    [self.deadView addGestureRecognizer:smileyPGR];
    [self.deadView setUserInteractionEnabled:YES];

    [self.excitedView addGestureRecognizer:smileyPGR];
    [self.excitedView setUserInteractionEnabled:YES];

    [self.happyView addGestureRecognizer:smileyPGR];
    [self.happyView setUserInteractionEnabled:YES];

    [self.sadView addGestureRecognizer:smileyPGR];
    [self.sadView setUserInteractionEnabled:YES];

    [self.tongueView addGestureRecognizer:smileyPGR];
    [self.tongueView setUserInteractionEnabled:YES];

    [self.winkView addGestureRecognizer:smileyPGR];
    [self.winkView setUserInteractionEnabled:YES];
}

- (void)onTrayPan:(UIPanGestureRecognizer *)sender {
    // Grab existing frame, save as CGRect, modify only the y dimension
    // Might need the full view? self.view - 44
    
    CGPoint location = [sender locationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    NSLog(@"Velocity %@", NSStringFromCGPoint(velocity));
    CGRect newFrame = self.trayView.frame;
    if (location.y > self.minimizedTrayY) {
        newFrame.origin.y = self.minimizedTrayY;
    } else {
        newFrame.origin.y = MAX(self.extendedTrayY, location.y);
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Gesture began at: %@", NSStringFromCGPoint(location));
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Gesture changed: %@", NSStringFromCGPoint(location));
        self.trayView.frame = newFrame;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Gesture ended: %@", NSStringFromCGPoint(location));
        [UIView animateWithDuration:0.15 animations:^{
            CGRect finalFrame = self.trayView.frame;
            if (velocity.y < 0) {
                finalFrame.origin.y = self.extendedTrayY;
            } else {
                finalFrame.origin.y = self.minimizedTrayY;
            }
            self.trayView.frame = finalFrame;
        }];
    }
}

- (void)onSmileyPan:(UIPanGestureRecognizer *)sender {
    NSLog(@"onSmileyPan");
    CGPoint location = [sender locationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    UIImageView *sourceView = (UIImageView *)sender.view;

    NSLog(@"Smiley velocity %@", NSStringFromCGPoint(velocity));
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Smiley gesture began at: %@", NSStringFromCGPoint(location));
        
        [self createNewSmileyView:sourceView];
        [UIView animateWithDuration:0.1 animations:^{
            self.panningFace.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Smiley gesture changed: %@", NSStringFromCGPoint(location));
        self.panningFace.center = location;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Smiley gesture ended: %@, %@", NSStringFromCGPoint(location), NSStringFromCGRect(self.panningFace.frame));
        BOOL faceIsInDrawer = (self.panningFace.frame.origin.y + self.panningFace.frame.size.height) > self.extendedTrayY;
        if (faceIsInDrawer) {
            [UIView animateWithDuration:0.15 animations:^{
                NSLog(@"sourceView center: %@", NSStringFromCGPoint(sourceView.center));
                CGPoint sourceCenter = sourceView.center;
                sourceCenter.y += self.extendedTrayY;
                self.panningFace.center = sourceCenter;
            } completion:^(BOOL finished) {
                [self.panningFace removeFromSuperview];
            }];
        } else {
            [UIView animateWithDuration:0.1 animations:^{
                self.panningFace.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }
    }
}

- (void)onSeparateSmileyPan:(UIPanGestureRecognizer *)sender {
    NSLog(@"onSeparateSmilyPan");
    CGPoint location = [sender locationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    NSLog(@"Separate velocity %@", NSStringFromCGPoint(velocity));

    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Separate Smiley gesture began at: %@", NSStringFromCGPoint(location));
        [UIView animateWithDuration:0.1 animations:^{
            sender.view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        NSLog(@"Separate Smiley gesture changed: %@", NSStringFromCGPoint(location));
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Separate Smiley gesture ended: %@", NSStringFromCGPoint(location));
        [UIView animateWithDuration:0.1 animations:^{
            sender.view.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
}

- (void)onSmileyPinch:(UIPinchGestureRecognizer *)sender {
    NSLog(@"scale: %f", sender.scale);
    sender.view.transform = CGAffineTransformMakeScale(sender.scale, sender.scale);
}

- (void)onSmileyRotate:(UIRotationGestureRecognizer *)sender {
    NSLog(@"rotation: %f", sender.rotation);
}

# pragma UIGestureViewRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

# pragma Smiley View creation

- (void)createNewSmileyView:(UIImageView *)sourceView {
    // Ensure new view's frame takes its parent's position (the tray) into account
    // TODO: see if there's a better way to do this?
    CGRect panningFaceFrame = sourceView.frame;
    panningFaceFrame.origin.y += self.extendedTrayY;
    
    self.panningFace = [[UIImageView alloc] initWithFrame:panningFaceFrame];
    [self.panningFace setImage:sourceView.image];
    
    // Pan
    UIPanGestureRecognizer *smileyPGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onSeparateSmileyPan:)];
    [self.panningFace addGestureRecognizer:smileyPGR];
    smileyPGR.delegate = self;
    
    // Pinch
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onSmileyPinch:)];
    [self.panningFace addGestureRecognizer:pinchGR];
    
    // Rotate
    UIRotationGestureRecognizer *rotateGR = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onSmileyRotate:)];
    [self.panningFace addGestureRecognizer:rotateGR];

    // Add
    [self.panningFace setUserInteractionEnabled:YES];
    [self.view addSubview:self.panningFace];
}

@end
