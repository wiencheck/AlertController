//
//  AlertController.swift
//  WatchApp
//
//  Created by Adam Wienconek on 20/09/2021.
//  Copyright © 2021 A+E Networks. All rights reserved.
//

import UIKit
import Combine
import OverlayPresentable

public class AlertController: UIAlertController, OverlayPresentable {

    public var onTextFieldChange: ((UITextField) -> Void)?
    public var onDisappear: ((AlertController) -> Void)?

    public weak var window: UIWindow?
    
    private var selectedActionSubject: CurrentValueSubject<UIAlertAction?, Never> = .init(nil)
    private var selectedActionContinuation: CheckedContinuation<UIAlertAction?, Never>?
    private var selectedActionCancellable: AnyCancellable?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedActionCancellable = NotificationCenter.default.publisher(for: actionSelectedNotification,
                                                                         object: self)
            .sink { [weak self] in
                let action = $0.userInfo?["action"] as? UIAlertAction
                self?.handleAction(action)
            }
    }
        
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupAfterPresentation()
        onDisappear?(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.handleAction(nil)
        }
    }
    
    /**
     Async getter to obtain information about selected action from the alert.
     */
    public var selectedAction: UIAlertAction? {
        get async {
            return await withCheckedContinuation { continuation in
                self.selectedActionContinuation = continuation
            }
        }
    }
    
    public var selectedActionPublisher: AnyPublisher<UIAlertAction?, Never> {
        selectedActionSubject.first().eraseToAnyPublisher()
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

private extension AlertController {
    
    func handleAction(_ action: UIAlertAction?) {
        guard selectedActionCancellable != nil else {
            return
        }
        selectedActionCancellable = nil
        selectedActionContinuation?.resume(returning: action)
        selectedActionContinuation = nil
        selectedActionSubject.send(action)
    }
    
}

@available(iOS 13.0, *)
public extension AlertController {
    
    var textFieldInputDidChangePublisher: AnyPublisher<UITextField, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification)
            .compactMap { $0.object as? UITextField }
            .filter { [weak self] in
                self?.textFields?.contains($0) == true
            }
            .eraseToAnyPublisher()
    }
    
}
