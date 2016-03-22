//
//  ViewController.swift
//  INCardViewLikeTinder
//
//  Created by mac on 18/03/16.
//  Copyright © 2016 Inwizards. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController{

    @IBOutlet var ReloadBtn: UIButton!
    @IBOutlet weak var cardViewPlaceholder:UIView!
    var cardViews:NSMutableArray!
    var card:CardView = CardView()
    var currentPhotoID = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        let arr = NSArray()
        self.cardViews = NSMutableArray(array: arr)
        self.cardViewPlaceholder.hidden = true
        self.initCardViews()  
    }
    func setUI(){
                //Reload Button.
        self.ReloadBtn.tintColor = UIColor.whiteColor()
        self.ReloadBtn.backgroundColor = UIColorRGB(0x78A511)
        self.ReloadBtn.layer.cornerRadius = self.ReloadBtn.frame.size.width / 2
        self.ReloadBtn.clipsToBounds = true
        self.ReloadBtn.setImage(UIImage(named: "reload")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.layoutCardViews()
    }

    @IBAction func ReloadAction(sender: AnyObject) {
        let arr = NSArray()
        self.cardViews = NSMutableArray(array: arr)
        self.cardViewPlaceholder.hidden = true
        self.initCardViews()
    }
    func initCardViews(){
        
        for currentPhotoID = 1; currentPhotoID < 10; currentPhotoID++ {
            let cardView:CardView = NSBundle.mainBundle().loadNibNamed("CardView", owner: nil, options: nil)[0] as! CardView
            cardView.frame = self.cardViewPlaceholder.frame
            cardView.rightOverlayImage = UIImage(named: "no")
            cardView.leftOverlayImage = UIImage(named: "yes")
            //cardView.titleLabel.text = NSString(format: "#%lu", currentPhotoID+1) as String
            cardView.EventImageView.image = UIImage(named: "\(currentPhotoID).jpg")
            self.cardViews.addObject(cardView)
        }
        
        for cardView in self.cardViews.reverseObjectEnumerator() {
            self.view.addSubview(cardView as! CardView)
        }
     }
    
    func layoutCardViews(){
        for v in self.cardViews{
            card = v as! CardView
           card.frame = cardViewPlaceholder.frame
        }
    }
    
    //***************************************
    // MARK: Apply HEX Color.
    //***************************************
    
    func UIColorRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
}

