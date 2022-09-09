public enum MPAK {
  public struct Recent<T> {
    public var isRecent = false
    public var value: T

    public init(_ value: T) {
      self.value = value
    }
  }
}
