//
//  MFButton.swift
//  MemoryFiller
//
//  Created by Михаил Куренков on 11.03.17.
//  Copyright © 2017 Михаил Куренков. All rights reserved.
//

import UIKit

@IBDesignable
class MFButton: UIButton {

    @IBInspectable
    public var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            didChangeState()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            didChangeState()
        }
    }
    
    private func didChangeState() {
        if (!isEnabled) {
            alpha = 0.4
        } else if (isHighlighted) {
            alpha = 0.75
        } else {
            alpha = 1
        }
    }
}
