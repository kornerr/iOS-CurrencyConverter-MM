import About
import Combine
import Converter
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  let converterModel = PassthroughSubject<Converter.Core.Model, Never>()
  let openURL = PassthroughSubject<URL, Never>()
  var aboutS: About.Service?
  var application: UIApplication?
  var converterS: Converter.Service?
  var subscriptions = [AnyCancellable]()
  var window: UIWindow?
}

extension AppDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    self.application = application

    let vc = UIViewController()
    vc.view.backgroundColor = .white

    let w = UIWindow(frame: UIScreen.main.bounds)
    w.rootViewController = vc
    w.makeKeyAndVisible()
    window = w

    converterS = Converter.Service(converterModel)

    setupAbout()

    return true
  }
}

extension AppDelegate {
  private func setupAbout() {
    let w =
      About.World(
        converterModel.eraseToAnyPublisher(),
        openURL
      )
    aboutS = About.Service(w)
    
    openURL
      .receive(on: DispatchQueue.main)
      .sink { v in self.application?.open(v) }
      .store(in: &subscriptions)
  }
}
