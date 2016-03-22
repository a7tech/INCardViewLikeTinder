//
//  CardView.swift
//  INCardViewLikeTinder
//
//  Created by Dharmendra on 18/03/16.
//  Copyright © 2016 Inwizards. All rights reserved.
//

import UIKit

class CardView: INCardDraggableView,UIGestureRecognizerDelegate {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var rejectImageView:UIButton!
    @IBOutlet weak var approveImageView:UIButton!
    @IBOutlet weak var CardImgView:UIView!
    @IBOutlet weak var EventImageView:UIImageView!
   override func awakeFromNib() {
    super.awakeFromNib()
    self.setup()
    self.setUI()
    }
    
    
    
    func setUI(){
        
        self.CardImgView.layer.cornerRadius = 10
        self.CardImgView.layer.borderWidth = 3
        self.CardImgView.layer.borderColor = UIColor.whiteColor().CGColor
        self.CardImgView.clipsToBounds = true

        //Reload Button.
        self.rejectImageView.tintColor = UIColor.whiteColor()
        self.rejectImageView.backgroundColor = UIColorRGB(0x78A511)
        self.rejectImageView.layer.cornerRadius = self.rejectImageView.frame.size.width / 2
        self.rejectImageView.clipsToBounds = true
        self.rejectImageView.setImage(UIImage(named: "no-sign")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)

    
    
        self.approveImageView.tintColor = UIColor.whiteColor()
        self.approveImageView.backgroundColor = UIColorRGB(0x78A511)
        self.approveImageView.layer.cornerRadius = self.approveImageView.frame.size.width / 2
        self.approveImageView.clipsToBounds = true
        self.approveImageView.setImage(UIImage(named: "yes-sign")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)

    }

    override func setup() {
        super.setup()
        let tapApproveImageViewGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "rightButtonAction")
        tapApproveImageViewGesture.cancelsTouchesInView = false
        self.approveImageView.addGestureRecognizer(tapApproveImageViewGesture)
        
        
        let tapRejectImageViewGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "leftButtonAction")
        tapRejectImageViewGesture.cancelsTouchesInView = false
        self.rejectImageView.addGestureRecognizer(tapRejectImageViewGesture)
    }
    func UIColorRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }

}
