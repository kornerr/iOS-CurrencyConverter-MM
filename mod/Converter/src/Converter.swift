public enum Converter { }

extension Converter {
  public struct Rates: Codable {
    public var base_code: String
    public var rates: [String: Double]
  }
}
