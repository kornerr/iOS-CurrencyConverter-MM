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
  // Форматируем поле ввода, если оно только что изменилось:
  // 1. оставляем лишь точки, запятые и цифры
  // 2. заменяем запятые на точки
  // 3. оставляем лишь первую точку
  public var shouldResetAmount: String? {
    guard amount.isRecent else { return nil }
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
