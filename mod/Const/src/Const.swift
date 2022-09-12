import SwiftUI

public enum Const {
  public static var purple: Color { c(0x280f78) }
}

private extension Const {
  static func c(_ hex: Int, opacity: Double = 1.0) -> Color {
    // https://stackoverflow.com/a/58216967
    let r = Double((hex & 0xff0000) >> 16) / 255.0
    let g = Double((hex & 0xff00) >> 8) / 255.0
    let b = Double((hex & 0xff) >> 0) / 255.0
    return Color(.sRGB, red: r, green: g, blue: b, opacity: opacity)
  }
}
