import Combine
import MPAK
import Net

extension Converter {
  public final class Controller: MPAK.Controller<Converter.Model> {
    public init() {
      super.init(
        Converter.Model(),
        debugClassName: "ConverterC",
        debugLog: { print($0) }
      )
    }
  }
}

// MARK: - Core

extension Converter.Controller {
  // Настраиваем зависимости ядра.
  func setupCore(
    sub: inout [AnyCancellable],
    amountSrc: AnyPublisher<String, Never>,
    currencies: AnyPublisher<[String], Never>,
    currencyDst: AnyPublisher<String, Never>,
    currencySrc: AnyPublisher<String, Never>,
    hasStartedUpdatingExchangeRates: AnyPublisher<Void, Never>,
    isPickerDstVisible: AnyPublisher<Bool, Never>,
    isPickerSrcVisible: AnyPublisher<Bool, Never>,
    refreshRates: AnyPublisher<Void, Never>,
    resultExchangeRates: AnyPublisher<Net.ExchangeRates?, Never>,
    selectCurrencyDst: AnyPublisher<Void, Never>,
    selectCurrencySrc: AnyPublisher<Void, Never>,
    selectedCurrencyDstId: AnyPublisher<Int, Never>,
    selectedCurrencySrcId: AnyPublisher<Int, Never>,
    showInfo: AnyPublisher<Void, Never>
  ) {
    pipeValue(
      dbg: "amount",
      sub: &sub,
      amountSrc,
      {
        $0.amount.value = $1
        $0.amount.isRecent = true
      },
      { m, _ in m.amount.isRecent = false }
    )

    pipeValue(
      dbg: "currencies",
      sub: &sub,
      currencies,
      {
        $0.currencies.value = $1
        $0.currencies.isRecent = true
      },
      { m, _ in m.currencies.isRecent = false }
    )

    pipeValue(
      dbg: "currencyD",
      sub: &sub,
      currencyDst,
      {
        $0.dst.isoCode.value = $1
        $0.dst.isoCode.isRecent = true
      },
      { m, _ in m.dst.isoCode.isRecent = false }
    )

    pipeValue(
      dbg: "currencyS",
      sub: &sub,
      currencySrc,
      {
        $0.src.isoCode.value = $1
        $0.src.isoCode.isRecent = true
      },
      { m, _ in m.src.isoCode.isRecent = false }
    )

    pipe(
      dbg: "hasSUER",
      sub: &sub,
      hasStartedUpdatingExchangeRates,
      { $0.hasStartedUpdatingExchangeRates = true },
      { $0.hasStartedUpdatingExchangeRates = false }
    )

    pipeValue(
      dbg: "isPDV",
      sub: &sub,
      isPickerDstVisible,
      {
        $0.dst.isPickerVisible.value = $1
        $0.dst.isPickerVisible.isRecent = true
      },
      { m, _ in m.dst.isPickerVisible.isRecent = false }
    )

    pipeValue(
      dbg: "isPSV",
      sub: &sub,
      isPickerSrcVisible,
      {
        $0.src.isPickerVisible.value = $1
        $0.src.isPickerVisible.isRecent = true
      },
      { m, _ in m.src.isPickerVisible.isRecent = false }
    )

    pipe(
      dbg: "refreshR",
      sub: &sub,
      refreshRates,
      { $0.perform.refreshRates = true },
      { $0.perform.refreshRates = false }
    )

    pipeValue(
      dbg: "resultER",
      sub: &sub,
      resultExchangeRates,
      {
        $0.rates.value = $1
        $0.rates.isRecent = true
      },
      { m, _ in m.rates.isRecent = false }
    )

    pipe(
      dbg: "selectCD",
      sub: &sub,
      selectCurrencyDst,
      { $0.buttons.isDstPressed = true },
      { $0.buttons.isDstPressed = false }
    )

    pipe(
      dbg: "selectCS",
      sub: &sub,
      selectCurrencySrc,
      { $0.buttons.isSrcPressed = true },
      { $0.buttons.isSrcPressed = false }
    )

    pipeValue(
      dbg: "selectedCDI",
      sub: &sub,
      selectedCurrencyDstId,
      {
        $0.dst.isoCodeId.value = $1
        $0.dst.isoCodeId.isRecent = true
      },
      { m, _ in m.dst.isoCodeId.isRecent = false }
    )

    pipeValue(
      dbg: "selectedCSI",
      sub: &sub,
      selectedCurrencySrcId,
      {
        $0.src.isoCodeId.value = $1
        $0.src.isoCodeId.isRecent = true
      },
      { m, _ in m.src.isoCodeId.isRecent = false }
    )

    pipe(
      dbg: "showI",
      sub: &sub,
      showInfo,
      { $0.buttons.isInfoPressed = true },
      { $0.buttons.isInfoPressed = false }
    )
  }

  // Запускаем первичные реактивные цепочки.
  // Следует выполнять после настройки всех прочих реактивных цепочек.
  func start(
    sub: inout [AnyCancellable]
  ) {
    pipe(
      dbg: "start",
      sub: &sub,
      Just(()).eraseToAnyPublisher(),
      { $0.perform.start = true },
      { $0.perform.start = false }
    )
  }
}
