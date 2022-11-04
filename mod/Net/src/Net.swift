import Combine

public enum Net {
  public static let apiURL = "https://open.er-api.com/v6/latest/USD"

  public struct ExchangeRates: Codable {
    public var base_code: String
    public var rates: [String: Double]
    public var time_last_update_unix: Int
    public var time_next_update_unix: Int
  }
}

extension Net {
  public static func loadExchangeRates(_ url: URL) -> AnyPublisher<ExchangeRates?, Never> {
    URLSession.shared.dataTaskPublisher(for: url)
      .map { v in try? JSONDecoder().decode(ExchangeRates.self, from: v.data) }
      .catch { _ in Just(nil) }
      .eraseToAnyPublisher()
  }
}
