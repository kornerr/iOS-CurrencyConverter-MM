import Combine
import SwiftUI

extension About {
  public struct V: View {
    @ObservedObject private var vm: VM

    public init(_ vm: VM) {
      self.vm = vm
    }

    public var body: some View {
      VStack {
        Spacer()
          .frame(height: 18)
        Text("About app")
          .font(.headline.weight(.semibold))
        Spacer()
          .frame(height: 48)
        Text("This is a free currency converter")
        Spacer()
          .frame(height: 25)
        Text("Special thanks for currency rates to")
        Spacer()
          .frame(height: 10)
        Button(action: vm.showDocs.send) {
          Text(vm.apiURL)
        }
        Spacer()
      }
    }
  }
}
