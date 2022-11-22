import Combine
import SUI

extension About {
  public final class Core {
    private let dismissal = About.Dismissal()
    private let vm = About.VM()
    private var subscriptions = [AnyCancellable]()
    private var wnd: UIWindow?

    deinit {
      hideUI()
    }

    public init(
      _ ctrl: About.Controller,
      _ world: About.World
    ) {
      ctrl.setupCore(
        sub: &subscriptions,
        vm.$apiURL.eraseToAnyPublisher(),
        dismissal.didDismiss.eraseToAnyPublisher(),
        vm.showDocs.eraseToAnyPublisher()
      )
      showUI()

      // Открываем URL.
      ctrl.m
        .compactMap { $0.shouldOpenURL }
        .receive(on: DispatchQueue.main)
        .sink { v in world.openURL.send(v) }
        .store(in: &subscriptions)
    }
  }
}

extension About.Core {
  private func hideUI() {
    wnd?.rootViewController?.presentedViewController?.dismiss(animated: true) { [weak self] in
      self?.wnd = nil
    }
  }

  private func showUI() {
    // Создаём и отображаем окно с корневым прозрачным VC.
    wnd = UIWindow(frame: UIScreen.main.bounds)
    let vc = UIViewController()
    wnd?.rootViewController = vc
    wnd?.makeKeyAndVisible()

    // Создаём и отображаем наш UI.
    let ui = UIViewController()
    ui.view.backgroundColor = .white
    ui.presentationController?.delegate = dismissal

    // Встраиваем интерфейс на SwiftUI в UIViewController.
    SUI.addSwiftUIViewAsChildVC(swiftUIView: About.V(vm), parentVC: ui)
    wnd?.rootViewController?.present(ui, animated: true)
  }
}
