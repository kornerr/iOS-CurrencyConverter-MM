
public enum Storage {
  public struct State: Codable {
    public var amount: Double
    public var dst: String
    public var src: String
    public var rates: Rates

    public init(
      amount: Double,
      src: String,
      dst: String,
      rates: Rates
    ) {
      self.amount = amount
      self.dst = dst
      self.src = src
      self.rates = rates
    }
  }

  public static func load() -> State? {
    if
      let data = UserDefaults.standard.value(forKey: "state") as? Data,
      let state = try? JSONDecoder().decode(State.self, from: data)
    {
      return state
    }
    return nil
  }

  public static func save(_ state: State) {
    if let data = try? JSONEncoder().encode(state) {
      UserDefaults.standard.set(data, forKey: "state")
      UserDefaults.standard.synchronize()
    }
  }
}
