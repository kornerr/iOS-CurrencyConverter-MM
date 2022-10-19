import MPAK

extension Converter.Core {
  public struct Model {
    public struct Buttons {
      public var isDstPressed = false
      public var isSrcPressed = false
    }

    public struct Currency {
      public var isoCode = MPAK.Recent<String?>(nil)
      public var isoCodeId = MPAK.Recent(0)
      public var isPickerVisible = MPAK.Recent(false)
    }

    public struct Perform {
      public var start = false
    }

    public var amount = MPAK.Recent("")
    public var buttons = Buttons()
    public var currencies = MPAK.Recent<[String]?>(nil)
    public var dst = Currency()
    public var perform = Perform()
    public var rates = MPAK.Recent<Converter.Rates?>(nil)
    public var src = Currency()
  }
}

// MARK: - Публичная интерпретация сырых данных

extension Converter.Core.Model {
  // Следует обновить курсы валют, если:
  // 1. только что произошёл запуск приложения
  public var shouldRefreshExchangeRates: URL? {
    if
      perform.start,
      let url = URL(string: "https://open.er-api.com/v6/latest/USD")
    {
      return url
    }
    return nil
  }

  // Сообщаем об ошибке, если:
  // 1. не удалось загрузить курсы валют
  public var shouldReportError: String? {
    if
      rates.isRecent,
      rates.value == nil
    {
      return "Could not load exchange rates"
    }
    return nil
  }

  // Вычисляем значение поля назначения, если:
  // 1. только что произошёл запуск приложения
  // 1. запустили приложение
  // 2. изменили сумму валюты-источника
  // 3. загрузили курс
  // 4. изменили валюту-источник
  // 5. изменили валюту-назначение
  // 2.  ОПИСАТЬ ВСЕ ПУНКТЫ пользователь изменил сумму для конвертации или обновился курс валют
  public var shouldResetAmountDst: String? {
    guard
      perform.start ||
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

  // Задаём значение поля с суммой для конвертации, если:
  // 1. только что произошёл запуск приложения
  // 2. пользователь изменил значение в поле
  public var shouldResetAmountSrc: String? {
    if perform.start {
      return "100"
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
  // обновился список валют.
  public var shouldResetCurrencies: [String]? {
    guard
      rates.isRecent,
      let r = rates.value
    else {
      return nil
    }
    return r.rates.keys.sorted()
  }

  // НАДО
  public var shouldResetCurrencyDstId: Int? {
    if
      currencies.isRecent,
      let isoCodes = currencies.value
    {
      return isoCodes.firstIndex(of: "EUR")
    }
    return nil
  }

  // Задаём валюту-назначение, если:
  // 1. УБРАТЬ только что произошёл запуск приложения
  // 2. НАДО
  public var shouldResetCurrencyDst: String? {
      /*
    if perform.start {
      return "EUR"
    }
    */
    
    if
      dst.isoCodeId.isRecent,
      let currs = currencies.value,
      dst.isoCodeId.value < currs.count
    {
      return currs[dst.isoCodeId.value]
    }
    
    return nil
  }

  // Задаём значение валюты-источника, если:
  // 1. УБРАТЬ только что произошёл запуск приложения
  // 2. НАДО
  public var shouldResetCurrencySrc: String? {
      /*
    if perform.start {
      return "USD"
    }
    */

    if
      src.isoCodeId.isRecent,
      let currs = currencies.value,
      src.isoCodeId.value < currs.count
    {
      return currs[src.isoCodeId.value]
    }

    return nil
  }

  // НАДО
  public var shouldResetCurrencySrcId: Int? {
    if
      currencies.isRecent,
      let isoCodes = currencies.value
    {
      return isoCodes.firstIndex(of: "USD")
    }
    return nil
  }

  // Следует переключить видимость пикера валюты-назначения, если
  // нажали на кнопку валюты-назначения.
  public var shouldResetPickerDstVisibility: Bool? {
    if buttons.isDstPressed {
      return !dst.isPickerVisible.value
    }
    return nil
  }

  // Переключаем видимость пикера валюты-источника, если
  // нажали на кнопку валюты-источника.
  public var shouldResetPickerSrcVisibility: Bool? {
    if buttons.isSrcPressed {
      return !src.isPickerVisible.value
    }
    return nil
  }

  // Задаём курс единицы валюты, если (ИЛИ):
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

extension Converter.Core.Model {
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
      let dstR = rates.value?.rates[dstC],
      let srcR = rates.value?.rates[srcC]
    {
      return money / srcR * dstR
    }
    return nil
  }
}
