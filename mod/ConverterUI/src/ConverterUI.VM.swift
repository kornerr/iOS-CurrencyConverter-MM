import Combine

extension ConverterUI {
  public final class VM: ObservableObject {
    @Published public var amountSrc = ""
    @Published public var amountDst = ""
    @Published public var currencySrc = "xYz"

    public let amountHeight: CGFloat
    public let selectCurrencySrc = PassthroughSubject<Void, Never>()
    public let signIn = PassthroughSubject<Void, Never>()

    public init() {
      amountHeight = Self.textHeight
    }
  }
}

extension ConverterUI.VM {
  // Вычисляем высоту полей ввода и вывода, т.к.
  // не хотим её менять при изменении содержимого.
  private static var textHeight: CGFloat {
    let l = UILabel()
    l.font = .systemFont(ofSize: 60, weight: .thin)
    l.numberOfLines = 0
    l.text = "11"
    let maxSize = CGSize(width: 1000, height: 1000)
    return l.sizeThatFits(maxSize).height
  }
}
