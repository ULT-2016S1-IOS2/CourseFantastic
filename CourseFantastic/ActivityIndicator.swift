//
//  ActivityIndicator.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 21/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import Foundation
import UIKit


class ActivityIndicator {
    
    var loadingView = UIView()
    var container = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    func show() {
        
        let window = UIApplication.sharedApplication().delegate!.window!! as UIWindow
        loadingView = UIView(frame: window.frame)
        loadingView.tag = 1
        loadingView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0)
        
        window.addSubview(loadingView)
        
        container = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.width / 3, height: window.frame.width / 3))
        container.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6)
        container.layer.cornerRadius = 10.0
        container.layer.borderColor = UIColor.grayColor().CGColor
        container.layer.borderWidth = 0.5
        container.clipsToBounds = true
        container.center = loadingView.center
        
        activityIndicator.frame = CGRectMake(0, 0, window.frame.width / 5, window.frame.width / 5)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = loadingView.center
        
        loadingView.addSubview(container)
        loadingView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
    }
    
    func hide() {
        
        UIView.animateWithDuration(0.0, delay: 1.0, options: .CurveEaseOut,
            animations: {
                self.container.alpha = 0.0
                self.loadingView.alpha = 0.0
                self.activityIndicator.stopAnimating()
            }, completion: { finished in
                self.activityIndicator.removeFromSuperview()
                self.container.removeFromSuperview()
                self.loadingView.removeFromSuperview()
                let window = UIApplication.sharedApplication().delegate!.window!! as UIWindow
                let removeView  = window.viewWithTag(1)
                removeView?.removeFromSuperview()
            })
        
    }
    
}