import Alert
import Combine
import ConverterUI
import MPAK
import SUI
import SwiftUI

extension Converter {
  public final class Core: MPAK.Controller<Core.Model> {
    let ui = UIViewController()
    private let isLoadingExchangeRates = PassthroughSubject<Void, Never>()
    private let resultExchangeRates = PassthroughSubject<Converter.Rates?, Never>()
    private let vm = ConverterUI.VM()

    public init() {
      super.init(
        Model(),
        debugClassName: "ConverterC",
        debugLog: { print($0) }
      )

      setupPipes()
      setupUI()
      setupNetwork()
    }
  }
}

extension Converter.Core {
  private func setupNetwork() {
    // Загружаем курсы валют.
    m.compactMap { $0.shouldRefreshExchangeRates }
      .flatMap { [weak self] url -> AnyPublisher<Converter.Rates?, Never> in
        self?.isLoadingExchangeRates.send()
        return URLSession.shared.dataTaskPublisher(for: url)
          .map { v in try? JSONDecoder().decode(Converter.Rates.self, from: v.data) }
          .catch { _ in Just(nil) }
          .eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.resultExchangeRates.send(v) }
      .store(in: &subscriptions)
  }

  private func setupPipes() {
    pipeValue(
      dbg: "amount",
      vm.$amountSrc.removeDuplicates().eraseToAnyPublisher(),
      {
        $0.amount.value = $1
        $0.amount.isRecent = true
      },
      { m, _ in m.amount.isRecent = false }
    )

    pipeValue(
      dbg: "currencyD",
      vm.$currencyDst.removeDuplicates().eraseToAnyPublisher(),
      {
        $0.dst.isoCode.value = $1
        $0.dst.isoCode.isRecent = true
      },
      { m, _ in m.dst.isoCode.isRecent = false }
    )

    pipeValue(
      dbg: "currencyS",
      vm.$currencySrc.removeDuplicates().eraseToAnyPublisher(),
      {
        $0.src.isoCode.value = $1
        $0.src.isoCode.isRecent = true
      },
      { m, _ in m.src.isoCode.isRecent = false }
    )

    pipeValue(
      dbg: "resultER",
      resultExchangeRates.eraseToAnyPublisher(),
      {
        $0.rates.value = $1
        $0.rates.isRecent = true
      },
      { m, _ in m.rates.isRecent = false }
    )

    pipeValue(
      dbg: "selectedCSI",
      vm.$selectedCurrencySrcId.eraseToAnyPublisher(),
      {
        $0.src.isoCodeId.value = $1
        $0.src.isoCodeId.isRecent = true
      },
      { m, _ in m.src.isoCodeId.isRecent = false }
    )

    pipe(
      dbg: "start",
      Just(()).eraseToAnyPublisher(),
      { $0.perform.start = true },
      { $0.perform.start = false }
    )
  }

  private func setupUI() {
    // Вставляем интерфейс на SwiftUI в VC.
    SUI.addSwiftUIViewAsChildVC(swiftUIView: ConverterUI.V(vm), parentVC: ui)
    // Включаем кнопку очистки на всех полях ввода,
    // т.к. в SwiftUI нельзя эту кнопку включить.
    UITextField.appearance().clearButtonMode = .whileEditing

    // Форматируем поле ввода.
    m.compactMap { $0.shouldResetAmountSrc }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.amountSrc = v }
      .store(in: &subscriptions)

    // Вычисляем результат.
    m.compactMap { $0.shouldResetAmountDst }
      .receive(on: DispatchQueue.main)
      /**/.handleEvents(receiveOutput: { o in print("ИГР ConverterC.setupU shouldRAD: '\(o)'") })
      .sink { [weak self] v in self?.vm.amountDst = v }
      .store(in: &subscriptions)

    // Задаём список валют.
    m.compactMap { $0.shouldResetCurrencies }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.currencies = v }
      .store(in: &subscriptions)

    // Задаём валюту-источник.
    m.compactMap { $0.shouldResetCurrencySrc }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.currencySrc = v }
      .store(in: &subscriptions)

    // Задаём валюту-назначение.
    m.compactMap { $0.shouldResetCurrencyDst }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.currencyDst = v }
      .store(in: &subscriptions)

    // Сообщаем об ошибке.
    m.compactMap { $0.shouldReportError }
      .receive(on: DispatchQueue.main)
      .sink { Self.reportError($0) }
      .store(in: &subscriptions)
  }
}

extension Converter.Core {
  private static func reportError(_ msg: String) {
    let alert = Alert.VC(title: msg, message: nil, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .default)
    alert.addAction(ok)
    alert.show()
  }
}
