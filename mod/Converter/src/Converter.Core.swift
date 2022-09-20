import Combine
import ConverterUI
import MPAK
import SUI
import SwiftUI

extension Converter {
  public final class Core: MPAK.Controller<Core.Model> {
    let ui = UIViewController()
    private let isLoadingExchangeRates = PassthroughSubject<Void, Never>()
    private let resultExchangeRates = PassthroughSubject<Void, Never>()
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
    // Загружаем информацию о системе при смене хоста.
    /*
    m.map { $0.shouldRefreshSystemInfo }
      .removeDuplicates()
      .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
      .flatMap { [weak self] url -> AnyPublisher<Net.SystemInfo?, Never> in
        guard let url = url else { return Just(nil).eraseToAnyPublisher() }
        self?.isLoadingSystemInfo.send()
        return URLSession.shared.dataTaskPublisher(for: url)
          .map { v in try? JSONDecoder().decode(Net.SystemInfo.self, from: v.data) }
          .catch { _ in Just(nil) }
          .eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] info in self?.resultSystemInfo.send(info) }
      .store(in: &subscriptions)
      */
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
    m.compactMap { $0.shouldResetAmount }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.amountSrc = v }
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
  }
}
