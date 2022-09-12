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
        VStack(spacing: 0) {
          amountSrc
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
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
      Spacer()
        .frame(width: 5)
      TextField("", text: $vm.amountSrc)
        .keyboardType(.decimalPad)
        .font(.system(size: 60, weight: .thin))
        .foregroundColor(Const.purple)
    }
      .background(Color.white)
  }
}
