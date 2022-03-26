//
//  Extensions.swift
//  Toddly
//
//  Created by Locomoviles on 3/20/22.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("error.title", comment: ""), message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension String {
    var localize: String {
        return NSLocalizedString(self, comment: self)
    }
}
