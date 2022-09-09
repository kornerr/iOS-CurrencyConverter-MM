import Combine
import SwiftUI

extension ConverterUI {
  public struct V: View {
    @ObservedObject var vm: VM

    public init(_ vm: VM) {
      self.vm = vm
    }

    public var body: some View {
      VStack {
        Text("something")
      }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut(duration: 0.3))
    }
  }
}

// MARK: - Поля ввода

