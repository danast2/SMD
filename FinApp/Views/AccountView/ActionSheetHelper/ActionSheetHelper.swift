//
//  ActionSheetHelper.swift
//  FinApp
//
//  Created by Даниил Дементьев on 27.06.2025.
//

import SwiftUI

struct ActionSheetHelper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let title: String
    let items: [ActionSheetItem]
    let tintColor: UIColor

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, uiViewController.presentedViewController == nil else { return }

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        items.forEach { item in
            let action = UIAlertAction(title: item.title, style: .default) { _ in
                item.action()
                isPresented = false
            }
            alert.addAction(action)
        }

        alert.view.tintColor = tintColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if isPresented, uiViewController.presentedViewController == nil {
                uiViewController.present(alert, animated: true)
            }
        }
    }
}
