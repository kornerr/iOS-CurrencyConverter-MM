import Combine

extension About {
  public final class VM: ObservableObject {
    @Published public var apiURL = "https://www.exchangerate-api.com/docs"
    public let showDocs = PassthroughSubject<Void, Never>()
  }
}
