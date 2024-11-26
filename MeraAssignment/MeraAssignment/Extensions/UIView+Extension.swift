//
//  UIView+Extension.swift
//  MeraAssignment
//
//  Created by NhatMinh on 26/11/24.
//

import UIKit

extension UIView {
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.systemGray2.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 4, height: 4)
        layer.shadowRadius = 6
        
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: 2,
                                                     width: bounds.width,
                                                     height: bounds.height)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = 1
        
    }
}
