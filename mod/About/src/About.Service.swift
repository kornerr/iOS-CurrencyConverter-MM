import Combine

extension About {
  public final class Service {
    public let ctrl = About.Controller()
    private var core: Core?
    private var subscriptions = [AnyCancellable]()

    public init(_ world: World) {
      ctrl.setupService(world.converterModel.eraseToAnyPublisher())

      // Запускаем ядро.
      ctrl.m
        .compactMap { $0.shouldStartCore }
        .receive(on: DispatchQueue.main)
        /**/.handleEvents(receiveOutput: { o in print("ИГР AboutS.init shouldSaC") })
        .sink { _ in self.core = About.Core(self.ctrl, world) }
        .store(in: &subscriptions)

      // Завершаем ядро.
      ctrl.m
        .compactMap { $0.shouldStopCore }
        .receive(on: DispatchQueue.main)
        /**/.handleEvents(receiveOutput: { o in print("ИГР AboutS.init shouldSoC") })
        .sink { _ in self.core = nil }
        .store(in: &subscriptions)
    }
  }
}
