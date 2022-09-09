import Combine

extension MPAK {
  open class Controller<Model> {
    public let m: CurrentValueSubject<Model, Never>
    public var subscriptions = [AnyCancellable]()

    private var debugClassName: String?
    private var debugLog: ((String) -> Void)?
    private var model: Model

    public init(
      _ model: Model,
      debugClassName: String? = nil,
      debugLog: ((String) -> Void)? = nil
    ) {
      m = .init(model)
      self.model = model
      self.debugClassName = debugClassName
      self.debugLog = debugLog
    }

    public func pipe<T>(
      dbg: String? = nil,
      _ node: AnyPublisher<T, Never>,
      _ reaction: @escaping (inout Model) -> Void,
      _ reversion: ((inout Model) -> Void)? = nil
    ) {
      node
        .sink { [weak self] _ in
          assert(Thread.isMainThread)
          guard let self = self else { return }
          self.dbgLog(dbg)
          reaction(&self.model)
          let modelCopy = self.model
          if let rev = reversion {
            rev(&self.model)
          }
          self.m.send(modelCopy)
        }
        .store(in: &subscriptions)
    }

    public func pipeOptional<T>(
      dbg: String? = nil,
      _ node: AnyPublisher<T?, Never>,
      _ reaction: @escaping (inout Model, T?) -> Void,
      _ reversion: ((inout Model, T?) -> Void)? = nil
    ) {
      node
        .sink { [weak self] value in
          assert(Thread.isMainThread)
          guard let self = self else { return }
          self.dbgLog(dbg)
          reaction(&self.model, value)
          let modelCopy = self.model
          if let rev = reversion {
            rev(&self.model, value)
          }
          self.m.send(modelCopy)
        }
        .store(in: &subscriptions)
    }

    public func pipeValue<T>(
      dbg: String? = nil,
      _ node: AnyPublisher<T, Never>,
      _ reaction: @escaping (inout Model, T) -> Void,
      _ reversion: ((inout Model, T) -> Void)? = nil
    ) {
      node
        .sink { [weak self] value in
          assert(Thread.isMainThread)
          guard let self = self else { return }
          self.dbgLog(dbg)
          reaction(&self.model, value)
          let modelCopy = self.model
          if let rev = reversion {
            rev(&self.model, value)
          }
          self.m.send(modelCopy)
        }
        .store(in: &subscriptions)
    }

    private func dbgLog(_ text: String?) {
      guard
        let className = debugClassName,
        let log = debugLog,
        let text = text
      else {
        return
      }
      log("\(className).\(text)")
    }
  }
}
