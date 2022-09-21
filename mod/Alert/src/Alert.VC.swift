import UIKit

extension Alert {
  public final class VC: UIAlertController {
    private static var wnd: UIWindow?

    override public func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      Self.wnd = nil
    }

    public func show() {
      // https://stackoverflow.com/a/30941356
      guard Self.wnd == nil else { return }
      let wnd = UIWindow(frame: UIScreen.main.bounds)
      Self.wnd = wnd
      wnd.windowLevel = UIWindow.Level.alert
      wnd.backgroundColor = .clear
      let vc = UIViewController()
      wnd.rootViewController = vc
      wnd.makeKeyAndVisible()
      vc.present(self, animated: true)
    }
  }
}
