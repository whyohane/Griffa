//
//  UIViewController+GriffaNavigationBar.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import UIKit

extension UIViewController {

    func setupGriffaNavigationBar(onAdd: @escaping () -> Void) {
        navigationItem.leftBarButtonItem = makeMascotItem()
        navigationItem.titleView = makeAppNameView()
        navigationItem.rightBarButtonItem = makeAddItem(onAdd: onAdd)
    }

    private func makeMascotItem() -> UIBarButtonItem {
        let imageView = makeImageView(UIImage(resource: .borderedCatinho), height: 51)
        imageView.accessibilityLabel = "Griffa mascot"

        let item = UIBarButtonItem(customView: imageView)
        item.hidesSharedBackground = true
        return item
    }

    private func makeAppNameView() -> UIView {
        let imageView = makeImageView(UIImage(resource: .griffa), height: 35)
        imageView.accessibilityLabel = "Griffa"
        return imageView
    }

    private func makeAddItem(onAdd: @escaping () -> Void) -> UIBarButtonItem {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { _ in onAdd() }
        )
        // .prominent preenche o fundo (vidro) com o tint
        item.style = .prominent
        item.tintColor = UIColor(resource: .primaryPurple)
        item.accessibilityLabel = "Add"
        return item
    }

    private func makeImageView(_ image: UIImage, height: CGFloat) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let aspectRatio = image.size.width / image.size.height
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: height),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio)
        ])
        return imageView
    }
}
