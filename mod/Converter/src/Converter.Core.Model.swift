import MPAK

extension Converter.Core {
  public struct Model {
    public struct Currency {
      public var dst = MPAK.Recent<String?>(nil)
      public var src = MPAK.Recent<String?>(nil)
    }

    public struct Perform {
      public var start = false
    }

    public var amount = MPAK.Recent("")
    public var currency = Currency()
    public var perform = Perform()
  }
}

// MARK: - Публичная интерпретация сырых данных

extension Converter.Core.Model {
  // Задаём значение поля с суммой для конвертации, если:
  // 1. только что произошёл запуск приложения
  // 2. пользователь изменил значение в поле
  public var shouldResetAmount: String? {
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

  // Задаём значение валюты-источника, если:
  // 1. только что произошёл запуск приложения
  public var shouldResetCurrencySrc: String? {
    if perform.start {
      return "USD"
    }
    return nil
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
}
