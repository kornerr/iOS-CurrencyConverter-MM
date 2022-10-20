import Converter
import MPAK

extension About {
  public struct Model {
    public struct Buttons {
      public var isExitPressed = false
    }

    public var buttons = Buttons()
    public var converterModel = MPAK.Recent<Converter.Core.Model?>(nil)
  }
}

// MARK: - Публичная интерпретация сырых данных

extension About.Model {
  // НАДО
  public var shouldHideUI: Bool? {
    return nil
  }

  // Следует открыть ссылку, если нажали на неё.
  public var shouldOpenURL: URL? {
    return nil
/*
    if
      converterModel
      let url = URL(string: "https://www.exchangerate-api.com/docs/overview")
    {
      return url
    }
*/
  }

  // НАДО
  public var shouldShowUI: Bool? {
    return nil
  }

  // НАДО
  public var shouldStartCore: Bool? {
      /*
    if
      converterModel.isRecent,
      converterModel.value?.shouldStartCore != nil
    {
      return true
    }
    */
    return nil
  }

  // НАДО
  public var shouldStopCore: Bool? {
    return nil
  }
}
