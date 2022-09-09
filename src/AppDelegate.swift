import Combine
import Converter
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  let conveterModel = CurrentValueSubject<Converter.Core.Model?, Never>(nil)
  var converterS: Converter.Service?
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let vc = UIViewController()
    vc.view.backgroundColor = .white

    let w = UIWindow(frame: UIScreen.main.bounds)
    w.rootViewController = vc
    w.makeKeyAndVisible()
    window = w

    converterS = Converter.Service(w, conveterModel)

    return true
  }
}
