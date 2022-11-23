import Combine
import Converter

public enum About {
  public struct World {
    let converterModel: AnyPublisher<Converter.Model, Never>
    let openURL: PassthroughSubject<URL, Never>

    public init(
      _ converterModel: AnyPublisher<Converter.Model, Never>,
      _ openURL: PassthroughSubject<URL, Never>
    ) {
      self.converterModel = converterModel
      self.openURL = openURL
    }
  }
}
