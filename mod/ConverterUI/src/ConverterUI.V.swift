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
        contents
      }
        .animation(.easeInOut(duration: 0.3))
    }

    private var contents: some View {
      VStack(spacing: 0) {
        amountSrc
          .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
        if vm.isPickerSrcVisible {
          pickerSrc
        }
        amountDst
          .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
        if vm.isPickerDstVisible {
          pickerDst
        }
        ZStack {
          rate
          info
        }
        ratesStatus
          .padding(.leading, 16)
        Spacer()
      }
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

  private var info: some View {
    HStack {
      Spacer()
      Button(action: { vm.showInfo.send() }) {
        Image(systemName: "info.circle")
          .font(.system(size: 23))
          .foregroundColor(Const.purple)
          .padding(.horizontal, 2)
      }
    }
  }

  private var pickerDst: some View {
    Picker(selection: $vm.selectedCurrencyDstId, label: Text("www").padding(20)) {
      ForEach(0..<vm.currencies.count, id: \.self) {
        Text(vm.currencies[$0])
          .font(.system(size: 30))
          .foregroundColor(Color.white)
      }
    }
    .pickerStyle(WheelPickerStyle())
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

  private var rate: some View {
    HStack {
      Text(vm.rate)
        .font(.system(size: 17))
        .foregroundColor(Const.purple)
        .padding(.vertical, 3)
    }
      .frame(maxWidth: .infinity)
      .background(Color.white.opacity(0.5))
  }

  private var ratesStatus: some View {
    VStack {
      HStack {
        Text("Exchange rates: \(vm.ratesDate)")
          .foregroundColor(.white)
        Text(vm.areRatesUpToDate ? "Up-to-date" : "Outdated")
          .foregroundColor(vm.areRatesUpToDate ? .green : .red)
      }
      if !vm.areRatesUpToDate {
        Button(action: { vm.refreshRates.send() }) {
          if vm.isUpdatingRates {
            HStack {
              ProgressView()
                .tint(.white)
              Spacer()
                .frame(width: 8)
              Text("Updating...")
                .foregroundColor(.white)
            }
          } else {
            Text("Update exchange rates")
              .foregroundColor(.white)
          }
        }
          .buttonStyle(.bordered)
          .disabled(vm.isUpdatingRates)
      }
    }
      .padding(.top, 100)
  }
}
