import Combine
import Const
import SwiftUI

extension ConverterUI {
  public struct V: View {
    @ObservedObject var vm: VM

    public init(_ vm: VM) {
      self.vm = vm
    }

    public var body: some View {
      ZStack {
        Spacer()
          .background(Const.purple)
          .edgesIgnoringSafeArea(.all)
        VStack {
          amountSrc
          Spacer()
        }
      }
        .animation(.easeInOut(duration: 0.3))
    }
  }
}

extension ConverterUI.V {
  private var amountSrc: some View {
    HStack {
      TextField("", text: $vm.amountSrc)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .keyboardType(.decimalPad)
        /**/.border(Color.gray.opacity(0.2), width: 1)
    }
  }
}
