//
//  NetworkStatusMonitor.swift
//  SkyMate
//
//  Created by Thomas Heinis on 27/06/2023.
//

import Combine
import Network

/// `NetworkStatusMonitor` is a class responsible for monitoring the network status of the device.
/// It provides a simple `isConnected` Boolean that is updated and published whenever the network status changes.
class NetworkStatusMonitor: ObservableObject {

  // MARK: - Properties

  private let monitor: NWPathMonitor
  private let queue: DispatchQueue

  /// A Boolean value indicating whether the device is connected to the network.
  @Published var isConnected: Bool

  // MARK: - Initialization

  init() {
    monitor = NWPathMonitor()
    queue = DispatchQueue(label: Constant.Label.networkStatusQueue)
    isConnected = false
  }

  // MARK: - Network Monitoring

  /// Starts monitoring the network status.
  /// Updates `isConnected` whenever the network status changes.
  func startMonitoring() {
    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        self?.isConnected = path.status == .satisfied
      }
    }

    monitor.start(queue: queue)
  }

  /// Stops monitoring the network status.
  func stopMonitoring() {
    monitor.cancel()
  }

  // MARK: - Deinitialization

  deinit {
    stopMonitoring()
  }
}
