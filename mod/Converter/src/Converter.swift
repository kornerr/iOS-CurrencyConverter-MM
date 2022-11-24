import Combine

public enum Converter {
  public struct World {
    let converterModel: PassthroughSubject<Converter.Model, Never>

    public init(
      _ converterModel: PassthroughSubject<Converter.Model, Never>
    ) {
      self.converterModel = converterModel
    }
  }
}
