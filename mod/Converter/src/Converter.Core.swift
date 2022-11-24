import Alert
import Combine
import ConverterUI
import Disk
import MPAK
import Net
import SUI
import SwiftUI

extension Converter {
  public final class Core {
    let ui = UIViewController()
    private let hasStartedUpdatingExchangeRates = PassthroughSubject<Void, Never>()
    private let resultExchangeRates = PassthroughSubject<Net.ExchangeRates?, Never>()
    private let vm = ConverterUI.VM()
    private var subscriptions = [AnyCancellable]()
    private var wnd: UIWindow?

    deinit {
      hideUI()
    }

    public init(
      _ ctrl: Converter.Controller,
      _ world: Converter.World
    ) {
      ctrl.setupCore(
        sub: &subscriptions,
        amountSrc: vm.$amountSrc.removeDuplicates().eraseToAnyPublisher(),
        currencies: vm.$currencies.eraseToAnyPublisher(),
        currencyDst: vm.$currencyDst.removeDuplicates().eraseToAnyPublisher(),
        currencySrc: vm.$currencySrc.removeDuplicates().eraseToAnyPublisher(),
        hasStartedUpdatingExchangeRates: hasStartedUpdatingExchangeRates.eraseToAnyPublisher(),
        isPickerDstVisible: vm.$isPickerDstVisible.eraseToAnyPublisher(),
        isPickerSrcVisible: vm.$isPickerSrcVisible.eraseToAnyPublisher(),
        refreshRates: vm.refreshRates.eraseToAnyPublisher(),
        resultExhangeRates: resultExchangeRates.eraseToAnyPublisher(),
        selectCurrencyDst: vm.selectCurrencyDst.eraseToAnyPublisher(),
        selectCurrencySrc: vm.selectCurrencySrc.eraseToAnyPublisher(),
        selectedCurrencyDstId: vm.$selectedCurrencyDstId.eraseToAnyPublisher(),
        selectedCurrencySrcId: vm.$selectedCurrencySrcId.eraseToAnyPublisher(),
        showInfo: vm.showInfo.eraseToAnyPublisher()
      )

      setupUI()
      setupNetwork()
      setupStorage()
      showUI()

      ctrl.start()

    }
  }
}

extension Converter.Core {
  private func setupNetwork() {
    // Загружаем курсы валют.
    m.compactMap { $0.shouldRefreshExchangeRates }
      /**/.handleEvents(receiveOutput: { _ in print("ИГР ConverterC.setupN shouldRER-1") })
      .flatMap { [weak self] url -> AnyPublisher<Net.ExchangeRates?, Never> in
        self?.hasStartedUpdatingExchangeRates.send()
        return Net.loadExchangeRates(url)
      }
      .receive(on: DispatchQueue.main)
      /**/.handleEvents(receiveOutput: { o in print("ИГР ConverterC.setupN shouldRER-2: '\(o)'") })
      .sink { [weak self] v in self?.resultExchangeRates.send(v) }
      .store(in: &subscriptions)
  }

  private func setupUI() {
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

    // Задаём первоначальную установку валюты-источника.
    m.compactMap { $0.shouldResetCurrencySrcId }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.selectedCurrencySrcId = v }
      .store(in: &subscriptions)

    // Задаём валюту-назначение.
    m.compactMap { $0.shouldResetCurrencyDst }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.currencyDst = v }
      .store(in: &subscriptions)

    // Задаём первоначальную установку валюты-назначения.
    m.compactMap { $0.shouldResetCurrencyDstId }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.selectedCurrencyDstId = v }
      .store(in: &subscriptions)

    // Сообщаем об ошибке.
    m.compactMap { $0.shouldReportError }
      .receive(on: DispatchQueue.main)
      .sink { Self.reportError($0) }
      .store(in: &subscriptions)

    // Задаём видимость списка валют для источника.
    m.compactMap { $0.shouldResetPickerSrcVisibility }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.isPickerSrcVisible = v }
      .store(in: &subscriptions)

    // Задаём видимость списка валют для назначения.
    m.compactMap { $0.shouldResetPickerDstVisibility }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.isPickerDstVisible = v }
      .store(in: &subscriptions)

    // Задаём справочный курс единицы валюты.
    m.compactMap { $0.shouldResetSingleRate }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.rate = v }
      .store(in: &subscriptions)

    // Задаём дату обновления курса.
    m.compactMap { $0.shouldResetRatesDate }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.ratesDate = v }
      .store(in: &subscriptions)

    // Задаём статус актуальности курса.
    m.compactMap { $0.shouldResetRatesStatus }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.areRatesUpToDate = v }
      .store(in: &subscriptions)

    // Задаём статус загрузки курса.
    m.compactMap { $0.shouldResetRatesUpdate }
      .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
      .sink { [weak self] v in self?.vm.isUpdatingRates = v }
      .store(in: &subscriptions)
  }
}

// MARK: - Storage

extension Converter.Core {
  private func setupStorage() {
    // Сохраняем текущее состояние приложения на диск.
    m.compactMap { $0.shouldResetDiskState }
      .receive(on: DispatchQueue.main)
      .sink { state in Disk.saveState(state) }
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

extension Converter.Core {
  private func hideUI() {
    wnd?.rootViewController?.presentedViewController?.dismiss(animated: true) { [weak self] in
      self?.wnd = nil
    }
  }

  private func showUI() {
    // Создаём и отображаем окно с корневым прозрачным VC.
    wnd = UIWindow(frame: UIScreen.main.bounds)
    let vc = UIViewController()
    wnd?.rootViewController = vc
    wnd?.makeKeyAndVisible()

    // Создаём UI.
    let ui = UIViewController()
    // Вставляем интерфейс на SwiftUI в UIViewController.
    SUI.addSwiftUIViewAsChildVC(swiftUIView: ConverterUI.V(vm), parentVC: ui)
    // Включаем кнопку очистки на всех полях ввода,
    // т.к. в SwiftUI нельзя эту кнопку включить.
    UITextField.appearance().clearButtonMode = .whileEditing
    // Отображаем UI.
    ui.modalPresentationStyle = .overFullScreen
    wnd?.rootViewController?.present(ui, animated: false)
  }
}
