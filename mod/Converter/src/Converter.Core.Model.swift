import MPAK

extension Converter.Core {
  public struct Model {
    public struct Currency {
      public var dst = MPAK.Recent<String?>(nil)
      public var src = MPAK.Recent<String?>(nil)
    }

    public var amount = MPAK.Recent("")
    public var currency = Currency()
  }
}

extension Converter.Core.Model {
  // Форматируем поле ввода, если оно только что изменилось, следующим образом:
  // 1. убрать пробелы по краям
  // 2. оставить лишь цифры и точку
  // 3. заменить запятую на точку
  public var shouldResetAmount: String? {
    guard amount.isRecent else { return nil }
    var av = amount.value
    av = av.trimmingCharacters(in: .whitespaces)
    let allowed: Set<Character> = [".", ",", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    /**/print("ИГР ConverterCM.shouldRA-1: '\(av)'")
    av = String(av.filter { allowed.contains($0) })
    /**/print("ИГР ConverterCM.shouldRA-2: '\(av)'")
    if av != amount.value {
      return av
    }
    return nil
  }

  /*
  // Стоит обновить логотип хоста.
  public var shouldRefreshHostLogo: URL? {
    guard
      !host.isEmpty,
      let id = systemInfo?.domain.logoResourceId
    else {
      return nil
    }
    let urlString = "http://\(host)/resource/\(id)"
    return URL(string: urlString)
  }
  */
}
