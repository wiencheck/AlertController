//
//  File.swift
//  
//
//  Created by Adam Wienconek on 06/10/2022.
//

import Foundation
import UIKit
import Combine

public extension AlertController {
    
    private var imageViewController: AlertImageViewController? {
        get { contentViewController as? AlertImageViewController }
        set { contentViewController = newValue }
    }
    
    var image: UIImage? {
        get { imageViewController?.imageView.image }
        set {
            guard let image = newValue else {
                imageViewController = nil
                return
            }
            imageViewController = .init(image: image)
        }
    }
    
}

fileprivate class AlertImageViewController: UIViewController {
    
    private(set) lazy var imageView: UIImageView = {
        let imv = UIImageView(image: image)
        imv.contentMode = .scaleAspectFit
        imv.clipsToBounds = true
        
        return imv
    }()
    
    private var image: UIImage?
    private var imageCancellable: AnyCancellable?
    
    convenience init(image: UIImage) {
        self.init(nibName: nil, bundle: nil)
        self.image = image
    }
    
    override func loadView() {
        view = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize.height = 44
    }
    
}
