import Combine
import SwiftUI

extension ConverterUI {
  public final class VM: ObservableObject {
    @Published public var amountDst = ""
    @Published public var amountSrc = ""
    @Published public var currencies = [String]()
    @Published public var currencyDst = ""
    @Published public var currencySrc = ""
    @Published public var isPickerDstVisible = false
    @Published public var isPickerSrcVisible = false
    @Published public var isUpdateVisible = true
    @Published public var rate = ""
    @Published public var ratesColor = Color.red
    @Published public var ratesDate = "2022-01-01"
    @Published public var ratesStatus = "Outdated"
    @Published public var selectedCurrencyDstId = 0
    @Published public var selectedCurrencySrcId = 0

    public let amountHeight: CGFloat
    public let selectCurrencyDst = PassthroughSubject<Void, Never>()
    public let selectCurrencySrc = PassthroughSubject<Void, Never>()
    public let showInfo = PassthroughSubject<Void, Never>()
    public let signIn = PassthroughSubject<Void, Never>()
    public let update = PassthroughSubject<Void, Never>()

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
