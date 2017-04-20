//
//  LoadingTableView.swift
//  Vantage
//
//  Created by Parth Saxena on 7/11/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit

class LoadingTableView: UITableView {

    var loadingImage = UIImage(named: "loadingIndicator")
    var loadingImageView: UIImageView!
    
    required init(coder aDecoder : NSCoder) {
        loadingImageView = UIImageView(image: loadingImage)
        //loadingImageView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        super.init(coder: aDecoder)!
        addSubview(loadingImageView)
        adjustSizeOfLoadingIndicator()
    }
    
    func showLoadingIndicator() {
        loadingImageView.isHidden = false
        self.bringSubview(toFront: loadingImageView)
        
        startRefreshing()
    }
    
    func hideLoadingIndicator() {
        loadingImageView.isHidden = true
        
        stopRefreshing()
    }
    
    override func reloadData() {
        super.reloadData()
        self.bringSubview(toFront: loadingImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustSizeOfLoadingIndicator()
    }
    
    fileprivate func adjustSizeOfLoadingIndicator() {
        let loadingImageSize = loadingImage?.size
        loadingImageView.frame = CGRect(x: frame.width/2 - loadingImageSize!.width/2, y: frame.height/2-loadingImageSize!.height/2, width: loadingImageSize!.width, height: loadingImageSize!.height)
    }
    
    fileprivate func startRefreshing() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.isRemovedOnCompletion = false
        animation.toValue = M_PI * 2.0
        animation.duration = 0.8
        animation.isCumulative = true
        animation.repeatCount = Float.infinity
        loadingImageView.layer.add(animation, forKey: "rotationAnimation")
    }
    
    fileprivate func stopRefreshing() {
        loadingImageView.layer.removeAllAnimations()
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
