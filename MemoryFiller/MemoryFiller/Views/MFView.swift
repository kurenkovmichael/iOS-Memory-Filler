//
//  MFView.swift
//  MemoryFiller
//
//  Created by Михаил Куренков on 11.03.17.
//  Copyright © 2017 Михаил Куренков. All rights reserved.
//

import UIKit

@IBDesignable
class MFView: UIView {
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    public var shadowColor: UIColor? {
        didSet {
            self.layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable
    public var shadowOpacity: CGFloat = 0 {
        didSet {
            self.layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable
    public var shadowOffset: CGSize = CGSize.init() {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }
}
