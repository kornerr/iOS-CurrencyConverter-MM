public enum Converter { }

extension Converter {
  public struct Rates: Codable {
    public var base_code: String
    public var rates: [String: Double]
  }

  public struct DiskState: Codable {
    public var amount: Double
    public var dst: String
    public var src: String
    public var rates: Rates
  }
}
