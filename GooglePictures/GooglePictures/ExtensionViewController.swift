//
//  ExtensionViewController.swift
//  GooglePictures
//
//  Created by Ivan on 02.05.2024.
//

import UIKit

extension UIViewController {
    func errorAlert(with error: Error, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Error!", message: "Your error: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_: UIAlertAction!) in
            completion()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
