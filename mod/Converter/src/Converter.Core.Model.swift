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
