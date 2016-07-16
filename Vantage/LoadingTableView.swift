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
        loadingImageView.hidden = false
        self.bringSubviewToFront(loadingImageView)
        
        startRefreshing()
    }
    
    func hideLoadingIndicator() {
        loadingImageView.hidden = true
        
        stopRefreshing()
    }
    
    override func reloadData() {
        super.reloadData()
        self.bringSubviewToFront(loadingImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        adjustSizeOfLoadingIndicator()
    }
    
    private func adjustSizeOfLoadingIndicator() {
        let loadingImageSize = loadingImage?.size
        loadingImageView.frame = CGRectMake(CGRectGetWidth(frame)/2 - loadingImageSize!.width/2, CGRectGetHeight(frame)/2-loadingImageSize!.height/2, loadingImageSize!.width, loadingImageSize!.height)
    }
    
    private func startRefreshing() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.removedOnCompletion = false
        animation.toValue = M_PI * 2.0
        animation.duration = 0.8
        animation.cumulative = true
        animation.repeatCount = Float.infinity
        loadingImageView.layer.addAnimation(animation, forKey: "rotationAnimation")
    }
    
    private func stopRefreshing() {
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
