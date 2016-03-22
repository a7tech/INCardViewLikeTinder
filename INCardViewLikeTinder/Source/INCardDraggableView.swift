//
//  INCardDraggableView.swift
//  INCardViewLikeTinder
//
//  Created by mac on 18/03/16.
//  Copyright © 2016 Inwizards. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

enum SwipeDirection: Int{
    case NoneSwipeDirection = 0
    case LeftSwipeDirection = 1
    case RightSwipeDirection
    case UpSwipeDirection
    case DownSwipeDirection
    
}
 protocol DraggableCardViewDelegate : NSObjectProtocol
{
    func cardViewWillBeginSwipeToDirection(swipeDirection:SwipeDirection)
    func cardView(cardView:INCardDraggableView, didEndSwipeToDirection swipeDirection:SwipeDirection)
    func shouldBlockSwipeDirections(direction: NSArray)
}

class INCardDraggableView: UIView {
    
    var delegateOfDragging: DraggableCardViewDelegate?
    var gesturesenabled:Bool!
    var isAnimatingMoving:Bool = true
    var movingAnimaionDidFinish: Bool = true
    
    var rightOverlayImage:UIImage!
    var leftOverlayImage:UIImage!
    
    var screenshotView:UIView!
    var panGestureRecognizer:UIPanGestureRecognizer!
    var originalCenterPoint:CGPoint!
    var overlayView:INOverlayView!
    
    
    
    var ScreenWidth = UIScreen.mainScreen().bounds.size.width
    var ScreenHeight = UIScreen.mainScreen().bounds.size.height
    var SCALE_QUICKNESS:CGFloat = 4.0
    var SCALE_MAX:CGFloat = 0.93
    var ROTATION_ANGLE:CGFloat = CGFloat(M_PI / 8)
    var ROTATION_MAX:CGFloat = 1
    var ROTATION_QUICKNESS:CGFloat = 320
    var k_AnimationTime = 0.4
    
    
    
    
    // * Offsets of drag from self center point
    var xFromCenter:CGFloat!
    var yFromCenter:CGFloat!
    // * Distance from the center, after acrossing which - applies the action to self.
    var k_ACTION_MARGIN_X:CGFloat!
    var k_ACTION_MARGIN_Y:CGFloat!
    
    internal func initWithViewFrame(frame:CGRect) -> Void{
        self.initWithViewFrame(frame)
        if self == true {
            self.setup()
        }
        return
    }
    
    override func awakeFromNib() {
        self.setup()
    }
    func setup(){
        self.GesturesEnabled(true)        
    }

    func createScreenshotOfSelf(){
        
        self.screenshotView = self.snapshotViewAfterScreenUpdates(false)
        self.screenshotView.frame = self.bounds
        self.addSubview(self.screenshotView)
        
        // * Create shadow
        self.screenshotView.layer.cornerRadius = 4.0
        self.screenshotView.layer.shadowRadius = 2.0
        self.screenshotView.layer.shadowOpacity = 0.5
        self.screenshotView.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        
        let path:UIBezierPath = UIBezierPath(rect: self.bounds)
        self.screenshotView.layer.shadowPath = path.CGPath
        self.screenshotView.layer.masksToBounds = true
        self.screenshotView.contentMode = UIViewContentMode.Redraw
        
        for v in self.subviews{
            if (!v.isEqual(self.screenshotView)){
                v.hidden = true
            }
        }
        self.createOverlayView()
        
        
    }
    
    func createOverlayView(){
        if(self.overlayView != nil){
            self.overlayView.removeFromSuperview()
        }
        self.overlayView = INOverlayView(frame: self.screenshotView.bounds)
        self.overlayView.leftImage = self.leftOverlayImage
        self.overlayView.rightImage = self.rightOverlayImage
        self.screenshotView.addSubview(self.overlayView)
        
    }
    
    func restoreOriginSelf_animationBlock()
    {
        self.screenshotView.layer.cornerRadius = 0.0
        self.screenshotView.layer.shadowRadius = 0.0
        self.screenshotView.layer.shadowOpacity = 0.0
    }
    func restoreOriginSelf_completionBlock()
    {
        
        for v in self.subviews {
            if (!v.isEqual(self.screenshotView)){
                v.hidden = false
            }
        }
        self.screenshotView.removeFromSuperview()
    }
    
    
    func handlePanGesture(panRecognizer:UIPanGestureRecognizer){
        
        xFromCenter = panRecognizer.translationInView(self).x
        yFromCenter = panRecognizer.translationInView(self).y
        switch panRecognizer.state {
        case UIGestureRecognizerState.Began:
            let actionMargin = min(self.bounds.size.width * 0.5 , self.bounds.size.height * 0.5)
            k_ACTION_MARGIN_X = actionMargin
            k_ACTION_MARGIN_Y = actionMargin
            self.originalCenterPoint = self.center
            self.createScreenshotOfSelf()
            break
            
        case UIGestureRecognizerState.Changed:
            self.animateView()
            break
            
        case UIGestureRecognizerState.Ended:
            self.updateResizing()
            self.detectSwipeDirection()
            break
            
        case UIGestureRecognizerState.Possible: break
        case UIGestureRecognizerState.Cancelled: break
        case UIGestureRecognizerState.Failed: break
        }
        
    }
    
    func animateView(){
        // Dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
        let rotationQuickness:CGFloat = min(xFromCenter / ROTATION_QUICKNESS, ROTATION_MAX)
        // Change the rotation in radians
        let rotationAngle:CGFloat = (CGFloat) (ROTATION_ANGLE * rotationQuickness)
        // the height will change when the view reaches certain point
        let scale:CGFloat = max(1 - fabs(rotationQuickness) / SCALE_QUICKNESS, SCALE_MAX)
        // move the object center depending on the coordinate
        self.center = CGPointMake(self.originalCenterPoint.x + xFromCenter,self.originalCenterPoint.y + yFromCenter)
        // rotate by the angle
        let rotateTransform:CGAffineTransform = CGAffineTransformMakeRotation(rotationAngle);
        // scale depending on the rotation
        let scaleTransform:CGAffineTransform = CGAffineTransformScale(rotateTransform, scale, scale);
        // apply transformations
        self.transform = scaleTransform;
        // * Update overlay above screenshotView
        self.updateOverlayView()
    }
  
    func updateOverlayView(){
        // * Set overlay image
        if (xFromCenter > 0) {
            self.overlayView.setMode(OverlayMode.overlayApprov)
           // self.overlayView.mode = OverlayMode.overlayApprov
        } else if (xFromCenter < 0) {
            self.overlayView.setMode(OverlayMode.OverlayReject)
           // self.overlayView.mode = OverlayMode.OverlayReject
        }
        // * Update transperancy in left/right directions
        if (fabs(xFromCenter) > fabs(yFromCenter)) {
            let transperancy:CGFloat = min(fabs(xFromCenter)/125, 1.0)
            
            self.overlayView.setSignsTransperancy(transperancy)
            self.overlayView.setBackgroundTransperancy(transperancy)
            
        } else {
            // * Update transperancy in up/down directions
            let transperancy:CGFloat = min(fabs(yFromCenter)/200, 0.8);
            
            self.overlayView.setSignsTransperancy(0.0)
            self.overlayView.setBackgroundTransperancy(transperancy)
        }
    }
   
    func updateResizing(){
        self.autoresizingMask =  [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleBottomMargin , .FlexibleRightMargin]
    }
    
    func detectSwipeDirection(){
        var swipeDirection:SwipeDirection = SwipeDirection.NoneSwipeDirection
        
        if (xFromCenter > k_ACTION_MARGIN_X) {
            swipeDirection = SwipeDirection.RightSwipeDirection
        } else if (xFromCenter < -k_ACTION_MARGIN_X) {
            swipeDirection = SwipeDirection.LeftSwipeDirection;
        } else if (yFromCenter > k_ACTION_MARGIN_Y) {
            swipeDirection = SwipeDirection.DownSwipeDirection;
        } else if (yFromCenter < -k_ACTION_MARGIN_Y) {
            swipeDirection = SwipeDirection.UpSwipeDirection;
        }
        
    if ((delegateOfDragging?.respondsToSelector(Selector("shouldBlockSwipeDirections:"))) != nil){
            self.performCenterAnimation()
    }
        else if (swipeDirection == .RightSwipeDirection){
            self.performRightAnimation()
        }else if (swipeDirection == .LeftSwipeDirection){
            self.performLeftAnimation()
        }else if (swipeDirection == .DownSwipeDirection){
            self.performDownAnimation()
        }else if (swipeDirection == .UpSwipeDirection){
            self.performUpAnimation()
        }else{
            self.performCenterAnimation()
        }
    }
    
    func performCenterAnimation(){
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.overlayView.setSignsTransperancy(0.0)
            self.overlayView.setBackgroundTransperancy(0.0)
            }) { (finished) -> Void in
               self.overlayView.removeFromSuperview()
        }
        UIView.animateWithDuration(k_AnimationTime * 2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.center = self.originalCenterPoint
            self.transform = CGAffineTransformIdentity
            self.restoreOriginSelf_animationBlock()
            }) { (finished) -> Void in
                self.restoreOriginSelf_completionBlock()
        }
    }
    
    func performRightAnimation(){
        let finishPoint:CGPoint = CGPointMake(ScreenWidth*2, 2 * yFromCenter + self.originalCenterPoint.y)
        self.performAnimationBlockForSwipesWithCenterPoint(finishPoint, withSwipeDirection: .RightSwipeDirection)
    }
    
    func performLeftAnimation(){
        let finishPoint:CGPoint = CGPointMake(-ScreenWidth, 2 * yFromCenter + self.originalCenterPoint.y)
        self.performAnimationBlockForSwipesWithCenterPoint(finishPoint, withSwipeDirection: .LeftSwipeDirection)
    }
    func performDownAnimation(){
        let finishPoint:CGPoint = CGPointMake(ScreenWidth/2, ScreenHeight*2)
        self.performAnimationBlockForSwipesWithCenterPoint(finishPoint, withSwipeDirection: .DownSwipeDirection)
    }
    func performUpAnimation(){
        let finishPoint:CGPoint = CGPointMake(ScreenWidth/2, -ScreenHeight)
        self.performAnimationBlockForSwipesWithCenterPoint(finishPoint, withSwipeDirection: .UpSwipeDirection)
    }
    func performAnimationBlockForSwipesWithCenterPoint(point:CGPoint,withSwipeDirection swipeDirection:SwipeDirection ){
        self.willBeginSwipeToDirection(swipeDirection)
        UIView.animateWithDuration(k_AnimationTime, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.center = point
            }) { (finished) -> Void in
                self.removeFromSuperview()
                self.didEndSwipeToDirection(swipeDirection)
        }
    }
    
    func performRightAnimationButtonAction(){
        self.isAnimatingMoving = true
        self.createScreenshotOfSelf()
        self.overlayView.setMode(.overlayApprov)
       
        let transperancy:CGFloat = 1.0
        
        self.overlayView.setSignsTransperancy(transperancy)
        
        let finishPoint:CGPoint = CGPointMake(ScreenWidth*2, ScreenHeight * 0.3)
        
        self.willBeginSwipeToDirection(.RightSwipeDirection)
       
        UIView.animateWithDuration(k_AnimationTime * 2, delay: k_AnimationTime * 2, options: [.BeginFromCurrentState, .AllowAnimatedContent] , animations: { () -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransformMakeRotation(1)
            }) { (finished) -> Void in
                self.removeFromSuperview()
                self.didEndSwipeToDirection(.RightSwipeDirection)
        }
    }
    
    func performLeftAnimationButtonAction(){
        self.isAnimatingMoving = true
        self.createScreenshotOfSelf()
        self.overlayView.setMode(.OverlayReject)
        let transperancy:CGFloat = 1.0
        
        self.overlayView.setSignsTransperancy(transperancy)
        
        let finishPoint:CGPoint = CGPointMake(-ScreenWidth, ScreenHeight * 0.3)
        
        self.willBeginSwipeToDirection(.LeftSwipeDirection)

        UIView.animateWithDuration(k_AnimationTime*2, delay: k_AnimationTime*2, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransformMakeRotation(-1)
            }) { (finished) -> Void in
                self.removeFromSuperview()
                self.didEndSwipeToDirection(.LeftSwipeDirection)
        }
    }
    
    func performUpAnimationButtonAction(){
       let finishPoint:CGPoint = CGPointMake(ScreenWidth/2, -ScreenHeight)
        self.performAnimationBlockForSwipesWithCenterPoint(finishPoint, withSwipeDirection: .UpSwipeDirection)
    }
    func performDownAnimationButtonAction(){
        let finishPoint:CGPoint = CGPointMake(ScreenWidth/2, ScreenHeight*2)
        self.performAnimationBlockForSwipesWithCenterPoint(finishPoint, withSwipeDirection: .DownSwipeDirection)
    }
    
    func performAnimationBlockForUpAndDownButtonActionWithCenterPoint(point:CGPoint,withSwipeDirection swipeDirection:SwipeDirection){
        self.willBeginSwipeToDirection(swipeDirection)
        UIView.animateWithDuration(k_AnimationTime*2, delay: k_AnimationTime/2, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.center = point
            }) { (finished) -> Void in
                self.removeFromSuperview()
                self.didEndSwipeToDirection(swipeDirection)
        }
    }
    func GesturesEnabled(gesturesEnabled:Bool){
        gesturesenabled = gesturesEnabled
        
        if(gesturesEnabled == true){
            self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
            self.addGestureRecognizer(self.panGestureRecognizer)
        }else{
            for recognizer in self.gestureRecognizers!{
                self.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func willBeginSwipeToDirection(swipeDirection:SwipeDirection){
        
        if ((self.delegateOfDragging?.respondsToSelector(Selector("cardViewWillBeginSwipeToDirection:"))) != nil){
            self.delegateOfDragging?.cardViewWillBeginSwipeToDirection(swipeDirection)

        }
    }
    
    func didEndSwipeToDirection(swipeDirection:SwipeDirection){
        
        self.isAnimatingMoving = false
        self.movingAnimaionDidFinish = true
        
        if ((self.delegateOfDragging?.respondsToSelector(Selector("didEndSwipeToDirection:"))) != nil){
            self.delegateOfDragging?.cardView(self, didEndSwipeToDirection: swipeDirection)
        }
     }

    func rightButtonAction(){
        self.performRightAnimationButtonAction()
    }
    
    func leftButtonAction(){
        self.performLeftAnimationButtonAction()
    }
    
    func upButtonAction(){
        self.performUpAnimationButtonAction()
    }
    
    func downButtonAction(){
        self.performDownAnimationButtonAction()
    }
}


