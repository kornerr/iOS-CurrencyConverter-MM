import About
import Combine
import Const
import Converter
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  let converterModel = PassthroughSubject<Converter.Model, Never>()
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
    let vc = UIViewController()
    vc.view.backgroundColor = Const.purple
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = vc
    window?.makeKeyAndVisible()

    self.application = application
    setupAbout()
    setupConverter()

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

  private func setupConverter() {
    let w = Converter.World(converterModel)
    converterS = Converter.Service(w)
  }
}
