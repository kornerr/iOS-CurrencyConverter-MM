import Combine
import Converter
import MPAK

extension About {
  public final class Controller: MPAK.Controller<About.Model> {
    public init() {
      super.init(
        About.Model(),
        debugClassName: "AboutC",
        debugLog: { print($0) }
      )
    }
  }
}

// MARK: - Core

extension About.Controller {
  public func setupCore(
    sub: inout [AnyCancellable],
    _ exit: AnyPublisher<Void, Never>,
    _ showDocs: AnyPublisher<Void, Never>
  ) {
    pipe(
      dbg: "exit",
      sub: &sub,
      exit,
      { $0.buttons.isExitPressed = true },
      { $0.buttons.isExitPressed = false }
    )

    pipe(
      dbg: "showD",
      sub: &sub,
      showDocs,
      { $0.buttons.isAPIURLPressed = true },
      { $0.buttons.isAPIURLPressed = false }
    )
  }
}

// MARK: - Service

extension About.Controller {
  public func setupService(
    _ converterModel: AnyPublisher<Converter.Core.Model, Never>
  ) {
    pipeValue(
      dbg: "converterM",
      converterModel,
      {
        $0.converterModel.value = $1
        $0.converterModel.isRecent = true
      },
      { m, _ in m.converterModel.isRecent = false }
    )
  }
}
