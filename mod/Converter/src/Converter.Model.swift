import Disk
import MPAK
import Net

extension Converter {
  public struct Model {
    public struct Buttons {
      public var isDstPressed = false
      public var isInfoPressed = false
      public var isSrcPressed = false
    }

    public struct Currency {
      public var isoCode = MPAK.Recent<String?>(nil)
      public var isoCodeId = MPAK.Recent(0)
      public var isPickerVisible = MPAK.Recent(false)
    }

    public struct Perform {
      public var refreshRates = false
      public var start = false
    }

    public var amount = MPAK.Recent("")
    public var buttons = Buttons()
    public var currencies = MPAK.Recent<[String]?>(nil)
    public var dst = Currency()
    public var hasStartedUpdatingExchangeRates = false
    public var perform = Perform()
    public var rates = MPAK.Recent<Net.ExchangeRates?>(nil)
    public var src = Currency()
  }
}

// MARK: - Публичная интерпретация сырых данных

extension Converter.Model {
  // Следует обновить курсы валют, если:
  // 1.1. только что произошёл запуск приложения
  // 1.2. имеющиеся данные устарели
  // или
  // 2. запросили обновление руками
  public var shouldRefreshExchangeRates: URL? {
    guard let url = URL(string: Net.apiURL) else { return nil }
    if
      perform.start,
      let r = prioritizedRates,
      Date().timeIntervalSince1970 > TimeInterval(r.time_next_update_unix)
    {
      return url
    }

    if perform.refreshRates {
      return url
    }

    return nil
  }

  // Сообщаем об ошибке, если:
  // не удалось загрузить курсы валют
  public var shouldReportError: String? {
    if
      rates.isRecent,
      rates.value == nil
    {
      return "Could not update exchange rates"
    }
    return nil
  }

  // Вычисляем значение поля назначения, если:
  // 1. изменили сумму для конвертации
  // 2. загрузили курсы валют
  // 3. изменили валюту-источник
  // 4. изменили валюту-назначение
  public var shouldResetAmountDst: String? {
    guard
      amount.isRecent ||
      rates.isRecent ||
      src.isoCode.isRecent ||
      dst.isoCode.isRecent
    else {
      return nil
    }

    guard
      let money = Double(amount.value),
      let conversion = convert(money)
    else {
      return "0.0"
    }

    let result = String(conversion)
    let parts = result.components(separatedBy: ".")
    guard
      let integer = parts.first,
      let fraction = parts.last
    else {
      return nil
    }
    return integer + "." + fraction.prefix(2)
  }

  // Задаём сумму для конвертации, если:
  // 1. только что произошёл запуск приложения
  // 2. пользователь изменил значение в поле
  public var shouldResetAmountSrc: String? {
    if perform.start {
      return diskState?.amount ?? "100"
    }
    if amount.isRecent {
      let cleared = clearAmount
      if cleared != amount.value {
        return cleared
      }
    }
    return nil
  }

  // Задаём упорядоченный по алфавиту список валют, если:
  // 1. получили курс валют из сети
  // 2. только что запустили приложение
  public var shouldResetCurrencies: [String]? {
    if
      rates.isRecent,
      let r = rates.value
    {
      return r.rates.keys.sorted()
    }

    if
      perform.start,
      let r = prioritizedRates
    {
      return r.rates.keys.sorted()
    }
    
    return nil
  }

  // Следует изменить порядковый номер валюты-назначения, если:
  // только что изменился список валют
  public var shouldResetCurrencyDstId: Int? {
    if
      currencies.isRecent,
      let isoCodes = currencies.value
    {
      return isoCodes.firstIndex(of: diskState?.dst ?? "EUR")
    }
    return nil
  }

  // Задаём валюту-назначение, если:
  // только что поменялся её порядковый номер
  public var shouldResetCurrencyDst: String? {
    if
      dst.isoCodeId.isRecent,
      let currs = currencies.value,
      dst.isoCodeId.value < currs.count
    {
      return currs[dst.isoCodeId.value]
    }
    
    return nil
  }

  // Задаём валюту-источник, если:
  // только что поменялся её порядковый номер
  public var shouldResetCurrencySrc: String? {
    if
      src.isoCodeId.isRecent,
      let currs = currencies.value,
      src.isoCodeId.value < currs.count
    {
      return currs[src.isoCodeId.value]
    }

    return nil
  }

  // Задаём порядковый номер валюты-источинка, если:
  // только что изменился список валют
  public var shouldResetCurrencySrcId: Int? {
    if
      currencies.isRecent,
      let isoCodes = currencies.value
    {
      return isoCodes.firstIndex(of: diskState?.src ?? "USD")
    }
    return nil
  }

  // Следует сохранить текущее состояие приложения, если:
  // 1. изменился результат конвертации
  // 2. сумма для конвертации корректна
  // 3. валюта-назначение корректна
  // 4. валюта-источник корректна
  // 5. есть курсы валют
  public var shouldResetDiskState: Disk.State? {
    guard
      shouldResetAmountDst != nil,
      !amount.value.isEmpty,
      let dstC = dst.isoCode.value,
      !dstC.isEmpty,
      let srcC = src.isoCode.value,
      !srcC.isEmpty,
      let rates = prioritizedRates
    else {
      return nil
    }

    return .init(amount: amount.value, dst: dstC, src: srcC, rates: rates)
  }
  
  // Переключаем видимость пикера валюты-назначения, если:
  // нажали на кнопку валюты-назначения.
  public var shouldResetPickerDstVisibility: Bool? {
    if buttons.isDstPressed {
      return !dst.isPickerVisible.value
    }
    return nil
  }

  // Переключаем видимость пикера валюты-источника, если:
  // нажали на кнопку валюты-источника.
  public var shouldResetPickerSrcVisibility: Bool? {
    if buttons.isSrcPressed {
      return !src.isPickerVisible.value
    }
    return nil
  }

  // Задаём дату последнего обновления курсов, если:
  // есть эта дата.
  public var shouldResetRatesDate: String? {
    if let rlu = ratesLastUpdate {
      let dt = Date(timeIntervalSince1970: TimeInterval(rlu))
      let fmt = DateFormatter()
      fmt.dateFormat = "yyyy-MM-dd"
      return fmt.string(from: dt)
    }
    
    return nil
  }

  // Задаём статус актуальности курсов валют, если:
  // есть этот статус.
  public var shouldResetRatesStatus: Bool? {
    if let rnu = ratesNextUpdate {
      let now = Date().timeIntervalSince1970
      return now < TimeInterval(rnu)
    }
    
    return nil
  }

  // Следует обновить статус загрузки курсов валют, если:
  // 1. только что начали их загрузку
  // 2. только что загрузили их
  public var shouldResetRatesUpdate: Bool? {
    if hasStartedUpdatingExchangeRates {
      return true
    }

    if rates.isRecent {
      return false
    }
    
    return nil
  }

  // Задаём справочный курс единицы валюты, если (ИЛИ):
  // 1. запустили приложение
  // 2. загрузили курс валют
  // 3. изменили валюту-источник
  // 4. изменили валюту-назначение
  public var shouldResetSingleRate: String? {
    guard
      (
        perform.start ||
        rates.isRecent ||
        src.isoCode.isRecent ||
        dst.isoCode.isRecent
      ),
      let s = src.isoCode.value,
      let d = dst.isoCode.value,
      let conversion = convert(1)
    else {
      return nil
    }
    return String(format: "1 %@ = %@ %@", s, String(conversion), d)
  }
}

// MARK: - Внутренние вспомогательные вычисления

extension Converter.Model {
  // Курс валют, поставляемый вместе с приложением
  // на случай первого запуска приложения без сети.
  private var bundleRates: Net.ExchangeRates? {
    if
      let path = Bundle.main.path(forResource: "rates_2022-11-10", ofType: "json"),
      let nsd = NSData(contentsOfFile: path)
    {
      let data = Data(referencing: nsd)
      return try? JSONDecoder().decode(Net.ExchangeRates.self, from: data)
    }
    return nil
  }

  // Форматируем (очищаем от лишнего) сумму для конвертации:
  // 1. оставляем лишь точки, запятые и цифры
  // 2. заменяем запятые на точки
  // 3. оставляем лишь первую точку
  private var clearAmount: String {
    var av = amount.value
    // 1.
    let allowed: Set<Character> = [".", ",", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    av = String(av.filter { allowed.contains($0) })
    // 2.
    av = av.replacingOccurrences(of: ",", with: ".")
    // 3.
    if let id = av.firstIndex(of: ".") {
      av = av.replacingOccurrences(of: ".", with: "")
      av.insert(".", at: id)
    }
    return av
  }

  // Преобразуем сумму из валюты-источника в валюту-назначение, если
  // присутствуют все коэффициенты.
  private func convert(_ money: Double) -> Double? {
    if
      let dstC = dst.isoCode.value,
      let srcC = src.isoCode.value,
      let dstR = prioritizedRates?.rates[dstC],
      let srcR = prioritizedRates?.rates[srcC]
    {
      return money / srcR * dstR
    }
    return nil
  }

  // Сохранённые на диск данные.
  private var diskState: Disk.State? {
    Disk.loadState()
  }

  // Курс валют по приоритету от лучшего к худшему:
  // 1. Сеть (самое новое и точное)
  // 2. Хранилище (предыдущий запрос к сети)
  // 3. Bundle (поставляется с приложением, устаревшие данные)
  private var prioritizedRates: Net.ExchangeRates? {
    rates.value ?? diskState?.rates ?? bundleRates
  }

  // Дата последнего обновления курсов валют, если:
  // 1. только что загрузили их
  // 2. только что запустили приложение
  private var ratesLastUpdate: Int? {
    if
      rates.isRecent,
      let r = rates.value
    {
      return r.time_last_update_unix
    }

    if
      perform.start,
      let r = prioritizedRates
    {
      return r.time_last_update_unix
    }

    return nil
  }

  // Дата следующего обновления курсов валют, если:
  // 1. только что загрузили их
  // 2. только что запустили приложение
  private var ratesNextUpdate: Int? {
    if
      rates.isRecent,
      let r = rates.value
    {
      return r.time_next_update_unix
    }

    if
      perform.start,
      let r = prioritizedRates
    {
      return r.time_next_update_unix
    }

    return nil
  }
}
