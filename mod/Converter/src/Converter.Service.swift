import Combine
import MPAK

extension Converter {
  public final class Service {
    private let core: Core
    private let wnd: UIWindow
    private let worldModel = CurrentValueSubject<Converter.Core.Model?, Never>(nil)

    public init(
      _ window: UIWindow,
      _ worldModel: CurrentValueSubject<Converter.Core.Model?, Never>
    ) {
      core = Converter.Core()
      wnd = window
      core.ui.modalPresentationStyle = .overFullScreen
      wnd.rootViewController?.present(core.ui, animated: false)
    
      // Транслируем модель Core в мир.
      core.m
        .receive(on: DispatchQueue.main)
        .sink { model in self.worldModel.send(model) }
        .store(in: &core.subscriptions)
    }
  }
}
