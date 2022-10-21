import Combine
import UIKit

extension About {
  public class Dismissal: NSObject, UIAdaptivePresentationControllerDelegate {
    public let didDismiss = PassthroughSubject<Void, Never>()

    public func presentationControllerDidDismiss(_: UIPresentationController) {
      didDismiss.send()
    }
  }
}

