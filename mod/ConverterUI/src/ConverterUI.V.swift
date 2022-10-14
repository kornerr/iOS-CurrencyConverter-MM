import Combine
import Const
import SwiftUI

extension ConverterUI {
  public struct V: View {
    @ObservedObject private var vm: VM

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
          if vm.isPickerSrcVisible {
            pickerSrc
          }
          amountDst
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
          Spacer()
        }
      }
        .animation(.easeInOut(duration: 0.3))
    }
  }
}

extension ConverterUI.V {
  private var amountDst: some View {
    HStack(spacing: 0) {
      Spacer()
        .frame(width: 8)
      Text(vm.amountDst)
        .font(.system(size: 60, weight: .thin))
        .foregroundColor(.white)
        .minimumScaleFactor(1.0/3.0)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: vm.amountHeight)
      Button(action: { vm.selectCurrencyDst.send() }) {
        Text(vm.currencyDst)
          .font(.system(size: 30))
          .foregroundColor(.white)
          .padding(.horizontal, 5)
      }
    }
  }

  private var amountSrc: some View {
    HStack(spacing: 0) {
      Spacer()
        .frame(width: 5)
      TextField("", text: $vm.amountSrc)
        .keyboardType(.decimalPad)
        .font(.system(size: 60, weight: .thin))
        .foregroundColor(Const.purple)
        .minimumScaleFactor(1.0/3.0)
        .lineLimit(1)
        .frame(height: vm.amountHeight)
      Button(action: { vm.selectCurrencySrc.send() }) {
        Text(vm.currencySrc)
          .font(.system(size: 30))
          .foregroundColor(Const.purple)
          .padding(.horizontal, 5)
      }
    }
    .background(Color.white)
  }
  
  private var pickerSrc: some View {
    Picker(selection: $vm.selectedCurrencySrcId, label: Text("www").padding(20)) {
      ForEach(0..<vm.currencies.count, id: \.self) {
        Text(vm.currencies[$0])
          .font(.system(size: 30))
          .foregroundColor(Color.white)
      }
    }
    .pickerStyle(WheelPickerStyle())
  }
}
