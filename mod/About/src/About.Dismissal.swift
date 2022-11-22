import Combine
import UIKit

extension About {
  class Dismissal: NSObject, UIAdaptivePresentationControllerDelegate {
    let didDismiss = PassthroughSubject<Void, Never>()

    func presentationControllerDidDismiss(_: UIPresentationController) {
      didDismiss.send()
    }
  }
}

