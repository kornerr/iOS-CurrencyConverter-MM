import Combine
import Converter

public enum About {
  public struct World {
    let converterModel: PassthroughSubject<Converter.Core.Model, Never>
    let openURL: PassthroughSubject<URL, Never>

    public init(
      _ converterModel: PassthroughSubject<Converter.Core.Model, Never>,
      _ openURL: PassthroughSubject<URL, Never>
    ) {
      self.converterModel = converterModel
      self.openURL = openURL
    }
  }
}
