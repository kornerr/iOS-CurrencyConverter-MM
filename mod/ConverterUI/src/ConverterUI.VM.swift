import Combine

extension ConverterUI {
  public final class VM: ObservableObject {
    @Published public var amountDst = "0.Z"
    @Published public var amountSrc = ""
    @Published public var currencyDst = "dSt"
    @Published public var currencySrc = ""

    public let amountHeight: CGFloat
    public let selectCurrencyDst = PassthroughSubject<Void, Never>()
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
