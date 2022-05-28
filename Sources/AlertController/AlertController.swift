//
//  AlertController.swift
//  WatchApp
//
//  Created by Adam Wienconek on 20/09/2021.
//  Copyright © 2021 A+E Networks. All rights reserved.
//

import UIKit
import Combine
import AWUtils_iOS

public class AlertController: UIAlertController, OverlayPresentable {

    public var onTextFieldChange: ((UITextField) -> Void)?
    public var onDisappear: ((AlertController) -> Void)?

    public weak var window: UIWindow?
    
    private lazy var onDisappearSubject: PassthroughSubject<Void, Never> = .init()

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupAfterPresentation()
        onDisappearSubject.send()
        onDisappear?(self)
    }
    
    public var onDisappearPublisher: AnyPublisher<Void, Never> {
        onDisappearSubject.eraseToAnyPublisher()
    }
    
    public var textFieldInputDidChangePublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification)
            .compactMap { $0.object as? UITextField }
            .filter { [weak self] in
                self?.textFields?.contains($0) == true
            }
            .eraseToAnyPublisher()
    }
    
    public var contentViewController: UIViewController? {
        get {
            value(forKey: "contentViewController") as? UIViewController
        } set {
            setValue(newValue, forKey: "contentViewController")
        }
    }
    
    public override func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        super.addTextField(configurationHandler: configurationHandler)
        
        guard let lastTextField = textFields?.last else {
            return
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: nil, queue: nil) { [weak self, weak lastTextField] sender in
            guard let textField = sender.object as? UITextField,
            textField === lastTextField else {
                return
            }
            self?.onTextFieldChange?(textField)
        }
    }
}
