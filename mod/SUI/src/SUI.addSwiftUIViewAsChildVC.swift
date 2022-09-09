import SwiftUI

extension SUI {
  @discardableResult
  public static func addSwiftUIViewAsChildVC<Type>(
    swiftUIView: Type,
    parentVC: UIViewController
  ) -> UIHostingController<Type> {
    let childVC = UIHostingController(rootView: swiftUIView)
    childVC.view.backgroundColor = .clear
    parentVC.view.addSubview(childVC.view)
    parentVC.addChild(childVC)
    childVC.didMove(toParent: parentVC)
    childVC.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      childVC.view.topAnchor.constraint(equalTo: parentVC.view.topAnchor),
      childVC.view.bottomAnchor.constraint(equalTo: parentVC.view.bottomAnchor),
      childVC.view.leadingAnchor.constraint(equalTo: parentVC.view.leadingAnchor),
      childVC.view.trailingAnchor.constraint(equalTo: parentVC.view.trailingAnchor),
    ])
    return childVC
  }
}
