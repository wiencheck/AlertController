//
//  File.swift
//  
//
//  Created by Adam Wienconek on 08/09/2022.
//

import Foundation
import UIKit

let actionSelectedNotification = Notification.Name("actionSelectedNotification")

public extension UIAlertAction {
    
    /**
     Creates new action object prepared for use with `UIAlertController`'s `selectedAction` async property.
     
     - Parameters:
        - title: The text to use for the button title. The value you specify should be localized for the user’s current language. This parameter must not be nil, except in a tvOS app where a nil title may be used with UIAlertAction.Style.cancel.
        - style: Additional styling information to apply to the button. Use the style information to convey the type of action that is performed by the button. For a list of possible values, see the constants in UIAlertAction.Style.
        - alertController: Alert controller which action is attached to.
     */
    convenience init(title: String?,
                     style: Style,
                     alertController: AlertController) {
        self.init(title: title,
                  style: style,
                  handler: { [weak alertController] in
            NotificationCenter.default.post(
                name: actionSelectedNotification,
                object: alertController,
                userInfo: [
                    "action": $0
                ]
            )
        })
    }
    
}

