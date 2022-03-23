//
//  ViewController.swift
//  MemoryFiller
//
//  Created by Михаил Куренков on 11.03.17.
//  Copyright © 2017 Михаил Куренков. All rights reserved.
//

import UIKit

// Note: Colors from https://color.adobe.com/Flat-UI-color-theme-9314650/

class ViewController: UIViewController, MFMemoryFillerDelegate {
    
    @IBOutlet weak var containerView: MFView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var firstContainerTitleLabel: UILabel!
    @IBOutlet weak var firstContainerSubtitleLabel: UILabel!
    @IBOutlet weak var firstContainerActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var firstContainerWriteButton: MFButton!
    @IBOutlet weak var firstContainerCleanButton: MFButton!
    @IBOutlet weak var firstContainerCancelButton: MFButton!
    
    @IBOutlet weak var secondContainerTitleLabel: UILabel!
    @IBOutlet weak var secondContainerSubtitleLabel: UILabel!
    @IBOutlet weak var secondContainerActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var secondContainerWriteButton: MFButton!
    @IBOutlet weak var secondContainerCleanButton: MFButton!
    @IBOutlet weak var secondContainerCancelButton: MFButton!
    
    private var firstMemoryFiller : MFMemoryFiller?
    private var secondMemoryFiller : MFMemoryFiller?
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstMemoryFiller = MFMemoryFiller.init(directoryName: "FirstContainer")
        firstMemoryFiller?.delegate = self
        
        secondMemoryFiller = MFMemoryFiller.init(directoryName: "SecondContainer")
        secondMemoryFiller?.delegate = self
        
        updateFirstContainerState()
        updateSecondContainerState()
    }
    
    // MARK: Actions
    @IBAction func firstContainerWriteTapped(_ sender: UIButton) {
        firstMemoryFiller?.fill()
    }
    
    @IBAction func firstContainerCleanTapped(_ sender: UIButton) {
        firstMemoryFiller?.clean()
    }
    
    @IBAction func firstContainerCancelTapped(_ sender: UIButton) {
        firstMemoryFiller?.cancel()
    }
    
    @IBAction func secondContainerWriteTapped(_ sender: UIButton) {
        secondMemoryFiller?.fill()
    }
    
    @IBAction func secondContainerCleanTapped(_ sender: UIButton) {
        secondMemoryFiller?.clean()
    }
    
    @IBAction func secondContainerCancelTapped(_ sender: UIButton) {
        secondMemoryFiller?.cancel()
    }
    
    // MARK: MFMemoryFillerDelegate
    func didChangeState(memoryFiller : MFMemoryFiller) {
        DispatchQueue.main.async {
            if (memoryFiller == self.firstMemoryFiller) {
                self.updateFirstContainerState()
            } else if (memoryFiller == self.secondMemoryFiller) {
                self.updateSecondContainerState()
            }
        }
    }
    
    func didWriteFile(memoryFiller : MFMemoryFiller) {
        DispatchQueue.main.async {
            if (memoryFiller == self.firstMemoryFiller) {
                self.updateFirstContainerSubtitle()
            } else if (memoryFiller == self.secondMemoryFiller) {
                self.updateSecondContainerSubtitle()
            }
            self.updateSubtitle()
        }
    }
    
    // MARK: Private - Update UI
    func updateSubtitle() {
        let freeDiskspace = MFMemoryFiller.getFreeDiskspace()
        let freeDiskspaceeString = ByteCountFormatter.string(fromByteCount: Int64(freeDiskspace), countStyle: ByteCountFormatter.CountStyle.file)
        subtitleLabel.text = NSString.init(format: "Free %@", freeDiskspaceeString) as String
    }
    
    func updateFirstContainerSubtitle() {
        let size = firstMemoryFiller?.getSize()
        let sizeString = ByteCountFormatter.string(fromByteCount: Int64(size ?? 0), countStyle: ByteCountFormatter.CountStyle.file)
        firstContainerSubtitleLabel.text = sizeString
    }
    
    func updateSecondContainerSubtitle() {
        let size = secondMemoryFiller?.getSize()
        let sizeString = ByteCountFormatter.string(fromByteCount: Int64(size ?? 0), countStyle: ByteCountFormatter.CountStyle.file)
        secondContainerSubtitleLabel.text = sizeString
    }
    
    func updateFirstContainerState() {
        if (firstMemoryFiller?.state == MFMemoryFiller.State.filling ||
            firstMemoryFiller?.state == MFMemoryFiller.State.cleaning)
        {
            
            UIView.animate(withDuration: 0.2) {
                self.firstContainerActivityIndicator.startAnimating()
                
                self.firstContainerWriteButton.isEnabled = false
                self.firstContainerCleanButton.isEnabled = false
                self.firstContainerCancelButton.isEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.firstContainerActivityIndicator.stopAnimating()
                
                self.firstContainerWriteButton.isEnabled = true
                self.firstContainerCleanButton.isEnabled = true
                self.firstContainerCancelButton.isEnabled = false
            }
        }
        
        updateFirstContainerSubtitle()
        updateSubtitle()
    }
    
    func updateSecondContainerState() {
        if (secondMemoryFiller?.state == MFMemoryFiller.State.filling ||
            secondMemoryFiller?.state == MFMemoryFiller.State.cleaning) {
            
            UIView.animate(withDuration: 0.2) {
                self.secondContainerActivityIndicator.startAnimating()
                
                self.secondContainerWriteButton.isEnabled = false
                self.secondContainerCleanButton.isEnabled = false
                self.secondContainerCancelButton.isEnabled = true
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.secondContainerActivityIndicator.stopAnimating()
                
                self.secondContainerWriteButton.isEnabled = true
                self.secondContainerCleanButton.isEnabled = true
                self.secondContainerCancelButton.isEnabled = false
            }
        }
        updateSecondContainerSubtitle()
        updateSubtitle()
    }
}
