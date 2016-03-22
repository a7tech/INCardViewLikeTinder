//
//  INOverlayView.swift
//  INCardViewLikeTinder
//
//  Created by mac on 18/03/16.
//  Copyright © 2016 Inwizards. All rights reserved.
//

import UIKit



enum OverlayMode: Int{
   case overlayApprov = 1
   case OverlayReject
    
}
class INOverlayView: UIView {

    
    // Create Outlet of Image View
    var CardimageView:UIImageView = UIImageView()
    
    // Define Properties
    var mode:OverlayMode!
    var rightImage:UIImage!
    var leftImage:UIImage!

    // Get degrees for radians
    var degrees = RADIANS_TO_DEGREES
    var angle = DEGREES_TO_RADIANS
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    func setup(){
        
        //self.setMode(mode)
        self.CardimageView = UIImageView(frame: self.bounds)
        self.CardimageView.contentMode = UIViewContentMode.Redraw
        self.addSubview(self.CardimageView)
        
    }
    // * Lazy selection of overlay
    func setMode(Newmode:OverlayMode){
        if (self.mode == Newmode){
            return
        }
        mode = Newmode
        var image:UIImage!
        self.CardimageView.transform = CGAffineTransformMakeRotation(0)
        self.CardimageView.transform = CGAffineTransformIdentity
        self.CardimageView.image = nil

        let insetTop:CGFloat = 0.22
        let sizeFacetor:CGFloat = 0.003
        
        if (Newmode == .overlayApprov) {
            image = self.leftImage
            
            var frame:CGRect = self.frame
            
            frame.size.width = sizeFacetor * image.size.width * self.frame.size.width
            frame.size.height = frame.size.width * image.size.width * sizeFacetor / 2
            frame.origin.x = 0
            frame.origin.y = self.frame.size.height * insetTop
            self.CardimageView.frame = frame
            // Rotate Image
            self.CardimageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(-45))
            
        }else{
            if (Newmode == .OverlayReject){
                image = self.rightImage
                var frame:CGRect = self.frame
                frame.size.width = sizeFacetor * image.size.width * self.frame.size.width
                frame.size.height = frame.size.width * image.size.width * sizeFacetor / 2
                frame.origin.x = self.frame.size.width - frame.size.width
                frame.origin.y = self.frame.size.height * insetTop
                self.CardimageView.frame = frame
                // Rotate Image
                self.CardimageView.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45))
            }
        }
        self.CardimageView.image = image

    }
    func setSignsTransperancy(transperancy:CGFloat){
         self.CardimageView.alpha = transperancy
    }
    func setBackgroundTransperancy(transperancy:CGFloat){
        let color:UIColor = UIColor(white: 0.0, alpha: 0.2)
        self.backgroundColor = color
    }
    // Declare radiansToDegrees function
    func RADIANS_TO_DEGREES (radians: CGFloat)->CGFloat {
        return radians * 180 / CGFloat(M_PI)
    }
    // Declare DegreesToradians function
    func DEGREES_TO_RADIANS (angle: CGFloat)->CGFloat {
        return angle / 180 * CGFloat(M_PI)
    }
}
