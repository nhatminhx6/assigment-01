//
//  UIView+Extension.swift
//  MeraAssignment
//
//  Created by NhatMinh on 26/11/24.
//

import UIKit

extension UIView {
    func addBottomShadow(withCornerRadius value: CGFloat = 0) {
        layer.cornerRadius = value
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 4
        layer.shadowColor  = UIColor.systemGray2.cgColor
        
    }
}
