//
//  MFMemoryFillerDelegate.swift
//  MemoryFiller
//
//  Created by Михаил Куренков on 11.03.17.
//  Copyright © 2017 Михаил Куренков. All rights reserved.
//

import UIKit

protocol MFMemoryFillerDelegate {
    
    func didChangeState(memoryFiller : MFMemoryFiller)
    func didWriteFile(memoryFiller : MFMemoryFiller)
    
}
