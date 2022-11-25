import Net

public enum Disk {
  private static let storageKey = "state"

  public struct State: Codable {
    public var amount: String
    public var dst: String
    public var src: String
    public var rates: Net.ExchangeRates

    public init(
      amount: String,
      dst: String,
      src: String,
      rates: Net.ExchangeRates
    ) {
      self.amount = amount
      self.dst = dst
      self.src = src
      self.rates = rates
    }
  }
}

extension Disk {
  public static func loadState() -> Disk.State? {
    if
      let data = UserDefaults.standard.value(forKey: storageKey) as? Data,
      let state = try? JSONDecoder().decode(Disk.State.self, from: data)
    {
      return state
    }
    return nil
  }

  public static func saveState(_ state: Disk.State) {
    guard let data = try? JSONEncoder().encode(state) else { return }
    UserDefaults.standard.set(data, forKey: storageKey)
    //UserDefaults.standard.synchronize()
  }
}
