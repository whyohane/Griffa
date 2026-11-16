//
//  UIViewController+GriffaNavigationBar.swift
//  Griffa
//
//  Created by Yohane Cavalcante on 16/11/26.
//

import UIKit

extension UIViewController {

    /// Monta a barra de navegação padrão do app: catinho à esquerda,
    /// nome do app no centro e botão de adicionar à direita.
    /// Catinho e nome são só visuais (não reagem a toque).
    func setupGriffaNavigationBar(onAdd: @escaping () -> Void) {
        navigationItem.leftBarButtonItem = makeMascotItem()
        navigationItem.titleView = makeAppNameView()
        navigationItem.rightBarButtonItem = makeAddItem(onAdd: onAdd)
    }

    // MARK: - Itens da barra

    private func makeMascotItem() -> UIBarButtonItem {
        let imageView = makeImageView(UIImage(resource: .borderedCatinho), height: 36)
        imageView.accessibilityLabel = "Griffa mascot"

        let item = UIBarButtonItem(customView: imageView)
        // Sem o fundo de vidro do sistema: a borda já faz parte da imagem
        item.hidesSharedBackground = true
        return item
    }

    private func makeAppNameView() -> UIView {
        let imageView = makeImageView(UIImage(resource: .griffa), height: 28)
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

    // MARK: - Imagem com tamanho fixo

    /// A altura é fixa e a largura segue a proporção da imagem.
    /// As variantes clara e escura têm dimensões diferentes, então o tamanho nunca vem da imagem.
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
