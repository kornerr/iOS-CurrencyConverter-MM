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
  public var shouldStartCore: Bool? {
    if
      converterModel.isRecent,
      let cm = converterModel.value,
      cm.buttons.isInfoPressed
    {
      return true
    }

    return nil
  }

  // НАДО
  public var shouldStopCore: Bool? {
    if buttons.isExitPressed {
      return true
    }

    return nil
  }
}
