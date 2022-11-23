import Combine
import MPAK

extension Converter {
  public final class Service {
    private let core: Core
    private let worldModel: PassthroughSubject<Converter.Model, Never>

    public init(
      _ worldModel: PassthroughSubject<Converter.Model, Never>
    ) {
      self.worldModel = worldModel

      core = Converter.Core()
    
      // Транслируем модель Core в мир.
      core.m
        .receive(on: DispatchQueue.main)
        .sink { model in self.worldModel.send(model) }
        .store(in: &core.subscriptions)
    }
  }
}
