public enum Converter { }

extension Converter {
  public struct Rates: Codable {
    public var base_code: String
    public var rates: [String: Double]
  }

  public struct DiskState: Codable {
    public var amount: String
    public var dst: String
    public var src: String
    public var rates: Rates

    public init(
      amount: String,
      dst: String,
      src: String,
      rates: Rates
    ) {
      self.amount = amount
      self.dst = dst
      self.src = src
      self.rates = rates
    }
  }
}
