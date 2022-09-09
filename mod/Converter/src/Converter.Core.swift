import Combine
import ConverterUI
import MPAK
import SUI
import SwiftUI

extension Converter {
  public final class Core: MPAK.Controller<Core.Model> {
    let ui = UIViewController()
    private let isLoadingExchangeRates = PassthroughSubject<Void, Never>()
    private let resultExchangeRates = PassthroughSubject<Void, Never>()
    private let vm = ConverterUI.VM()

    public init() {
      super.init(
        Model(),
        debugClassName: "ConverterC",
        debugLog: { print($0) }
      )

      setupPipes()
      setupUI()
      setupNetwork()
    }
  }
}

extension Converter.Core {
  private func setupNetwork() {
    // Загружаем информацию о системе при смене хоста.
    /*
    m.map { $0.shouldRefreshSystemInfo }
      .removeDuplicates()
      .debounce(for: .seconds(0.3), scheduler: DispatchQueue.main)
      .flatMap { [weak self] url -> AnyPublisher<Net.SystemInfo?, Never> in
        guard let url = url else { return Just(nil).eraseToAnyPublisher() }
        self?.isLoadingSystemInfo.send()
        return URLSession.shared.dataTaskPublisher(for: url)
          .map { v in try? JSONDecoder().decode(Net.SystemInfo.self, from: v.data) }
          .catch { _ in Just(nil) }
          .eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] info in self?.resultSystemInfo.send(info) }
      .store(in: &subscriptions)
      */
  }

  private func setupPipes() {
    pipeValue(
      dbg: "amount",
      vm.$amountSrc.eraseToAnyPublisher(),
      {
        $0.amount.value = $1
        $0.amount.isRecent = true
      },
      { m, _ in m.amount.isRecent = false }
    )

    /*
    pipeValue(
      dbg: "isLSI",
      Publishers.Merge(
        isLoadingSystemInfo.map { _ in true },
        resultSystemInfo.map { _ in false }
      ).eraseToAnyPublisher(),
      { $0.isLoadingSystemInfo = $1 }
    )
    */
  }

  private func setupUI() {
    SUI.addSwiftUIViewAsChildVC(swiftUIView: ConverterUI.V(vm), parentVC: ui)

/*
    // Отображаем факт загрузки системной инфы.
    m.map { $0.isLoadingSystemInfo }
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] v in self?.vm.isLoadingSystemInfo = v }
      .store(in: &subscriptions)
      */
  }
}
