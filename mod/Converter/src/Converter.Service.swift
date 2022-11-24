import Combine
import MPAK

extension Converter {
  public final class Service {
    public let ctrl = Converter.Controller()
    private let core: Core

    public init(_ world: World) {
      core = Converter.Core(ctrl, world)
    
      // Транслируем модель Core в мир.
      ctrl.m
        .receive(on: DispatchQueue.main)
        .sink { model in world.converterModel.send(model) }
        .store(in: &core.subscriptions)
    }
  }
}
