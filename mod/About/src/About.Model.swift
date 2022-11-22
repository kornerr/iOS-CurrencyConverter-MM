import Converter
import MPAK

extension About {
  public struct Model {
    public struct Buttons {
      public var isAPIURLPressed = false
    }

    public struct Perform {
      public var exit = false
    }

    public var apiURL: String?
    public var buttons = Buttons()
    public var converterModel = MPAK.Recent<Converter.Core.Model?>(nil)
    public var perform = Perform()
  }
}

// MARK: - Публичная интерпретация сырых данных

extension About.Model {
  // Следует открыть ссылку, если нажали на неё.
  public var shouldOpenURL: URL? {
    if
      buttons.isAPIURLPressed,
      let surl = apiURL,
      let url = URL(string: surl)
    {
      return url
    }
    return nil
  }

  // Следует запустить ядро (показать About), если:
  // только что в основном интерфейсе нажали на кнопку информации.
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

  // Следует остановить ядро (скрыть About), если:
  // скрыли интерфейс About смахиванием.
  public var shouldStopCore: Bool? {
    if perform.exit {
      return true
    }

    return nil
  }
}
