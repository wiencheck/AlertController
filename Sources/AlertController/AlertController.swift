//
//  AlertController.swift
//  WatchApp
//
//  Created by Adam Wienconek on 20/09/2021.
//  Copyright © 2021 A+E Networks. All rights reserved.
//

import UIKit
import Combine

public final class AlertControllerWindow: UIWindow {}

public class AlertController: UIAlertController {

    public var onTextFieldChange: ((UITextField) -> Void)?
    public var onDisappear: ((AlertController) -> Void)?

    private let _selectedAction = PassthroughSubject<UIAlertAction?, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    private var _window: UIWindow?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        observeSelectedAction()
    }
        
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        _window = nil
        onDisappear?(self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self._selectedAction.send(nil)
        }
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
    
    public func show(
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let scene = UIWindowScene.focused else {
            return
        }
        guard _window == nil else {
            return
        }
        let window = AlertControllerWindow(windowScene: scene)
        window.tintColor = scene.keyWindow?.tintColor
        _window = window
        
        window.rootViewController = ClearViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(
            self,
            animated: animated,
            completion: completion
        )
    }
    
    public func show(
        animated: Bool = true,
        actions: [UIAlertAction] = [],
        completion: (() -> Void)? = nil
    ) -> AnyPublisher<UIAlertAction?, Never> {
        if !actions.isEmpty {
            assert(
                self.actions.isEmpty,
                "When passing array of UIAlertAction exisitng actions should be empty."
            )
            for action in actions {
                addAction(action)
            }
        }
        show(
            animated: animated,
            completion: completion
        )
        return _selectedAction.first()
            .eraseToAnyPublisher()
    }
    
    public func showAndWait(
        animated: Bool = true,
        actions: [UIAlertAction] = [],
        completion: (() -> Void)? = nil
    ) async -> UIAlertAction? {
        let publisher = show(
            animated: animated,
            actions: actions,
            completion: completion
        )
        for await action in await publisher.values {
            return action
        }
        return nil
    }
    
}

private extension AlertController {
    
    func observeSelectedAction() {
        NotificationCenter.default.publisher(
            for: actionSelectedNotification
        )
        .compactMap {
            $0.object as? UIAlertAction
        }
        .filter { [weak self] sender in
            self?.actions.contains(sender) == true
        }
        .sink { [weak self] action in
            self?._selectedAction.send(action)
        }
        .store(in: &cancellables)
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
