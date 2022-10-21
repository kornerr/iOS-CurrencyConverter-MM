import Combine

extension About {
  public final class Core {
    //private let vm = About.VM()
    private var subscriptions = [AnyCancellable]()
    private var wnd: UIWindow?

    public init(
      _ ctrl: About.Controller,
      _ world: About.World
    ) {
      ctrl.setupCore(
        sub: &subscriptions,
        Just(()).eraseToAnyPublisher()
        //vm.exit.eraseToAnyPublisher()
      )

      // Отображаем окно завершения.
      ctrl.m
        .compactMap { $0.shouldShowUI }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in self?.showUI() }
        .store(in: &subscriptions)

      // Скрываем окно завершения.
      ctrl.m
        .compactMap { $0.shouldHideUI }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in self?.hideUI() }
        .store(in: &subscriptions)

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

    /**/ui.view.backgroundColor = .red

    //ui.modalPresentationStyle = .overFullScreen
    //SUI.addSwiftUIViewAsChildVC(swiftUIView: About.V(vm), parentVC: ui)
    wnd?.rootViewController?.present(ui, animated: true)
  }
}
