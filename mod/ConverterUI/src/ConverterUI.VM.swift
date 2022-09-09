import Combine

extension ConverterUI {
  public final class VM: ObservableObject {
    @Published public var amountSrc = ""
    @Published public var amountDst = ""

    public let signIn = PassthroughSubject<Void, Never>()

    public init() { }
  }
}
