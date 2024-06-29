//
//  WiFiSyncServer.swift
//  WiFiSyncServer
//
//  Created by Strongbox on 20/11/2023.
//

import Foundation
import Network
import OSLog

extension Notification.Name {
    static let wiFiSyncServiceNameDidChange = Notification.Name("wiFiSyncServiceNameDidChange")
}

@objc public extension NSNotification {
    static let wiFiSyncServiceNameDidChange = Notification.Name.wiFiSyncServiceNameDidChange
}



@objc
class WiFiSyncServer: NSObject {
    static let listenerQ: DispatchQueue = .init(label: "Wi-Fi-Sync-Listener-Queue")

    @objc
    var lastRegisteredServiceName: String? = nil { 
        didSet {
            postChangeNotification()
        }
    }

    func postChangeNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .wiFiSyncServiceNameDidChange, object: nil)
        }
    }

    @objc
    static var shared = WiFiSyncServer()

    let settings = CrossPlatformDependencies.defaults().applicationPreferences

    @objc var lastError: String? = nil

    var connections: ConcurrentMutableSet<WiFiSyncInboundConnection> = .init()
    var listener: NWListener?

    @objc
    var isRunning: Bool {
        listener != nil
    }

    var wiFiSyncIsPossible: Bool {
        settings.isPro && StrongboxProductBundle.supportsWiFiSync
    }

    @objc
    func startOrStopWiFiSyncServerAccordingToSettings() throws {
        if settings.runAsWiFiSyncSourceDevice, wiFiSyncIsPossible, let passcode = settings.wiFiSyncPasscode {
            try WiFiSyncServer.shared.start(name: settings.wiFiSyncServiceName,
                                            passcode: passcode)
        } else {
            WiFiSyncServer.shared.stop()
        }
    }

    @objc
    func stop(with error: String? = nil) {
        if isRunning {
            listener?.stateUpdateHandler = nil
            listener?.serviceRegistrationUpdateHandler = nil
            listener?.newConnectionHandler = nil

            listener?.cancel()

            listener = nil
            lastRegisteredServiceName = nil

            if let error {
                lastError = error
            }
        }
    }

    func start(name: String? = nil, passcode: String) throws {
        stop()

        if !wiFiSyncIsPossible || !settings.runAsWiFiSyncSourceDevice {
            NSLog("⚠️ Not starting WiFi Sync Service as not Pro or enabled")
        }

        do {
            lastError = nil

            let listener = try NWListener(using: NWParameters(passcode: passcode))

            listener.service = NWListener.Service(name: name, type: WiFiSyncConstants.ServiceType)

            listener.stateUpdateHandler = listenerStateChanged
            listener.serviceRegistrationUpdateHandler = registrationStateChanged
            listener.newConnectionHandler = onNewConnection

            listener.start(queue: Self.listenerQ)

            self.listener = listener

            NSLog("🟢 WiFiSync Server Started")
        } catch {
            NSLog("🔴 \(error)")
            throw error
        }
    }

    

    func listenerStateChanged(newState: NWListener.State) {
        switch newState {
        case .ready:
            NSLog("listenerStateChanged: Listener ready on \(String(describing: listener?.port))")
        case let .failed(error):
            lastError = String(describing: error)

            if error == NWError.dns(DNSServiceErrorType(kDNSServiceErr_DefunctConnection)) {
                NSLog("listenerStateChanged: Listener failed with \(error), restarting")
                
            } else {
                NSLog("listenerStateChanged: Listener failed with \(error), stopping")
                stop()
            }
        case .cancelled:
            NSLog("listenerStateChanged: Cancelled")
            listener = nil
        default:
            NSLog("listenerStateChanged: %@", String(describing: newState))
        }

        postChangeNotification()
    }

    func registrationStateChanged(_ change: NWListener.ServiceRegistrationChange) {
        

        if case let .add(nWEndpoint) = change {
            if case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = nWEndpoint {
                lastRegisteredServiceName = name
            }
        }
    }

    

    func onNewConnection(_ connection: NWConnection) {
        #if os(iOS)
            let managementInterface = IOSWiFiSyncManagementInterface()
        #else
            let managementInterface = MacWiFiSyncManagementInterface()
        #endif

        let incoming = WiFiSyncInboundConnection(connection: connection, managementInterface: managementInterface) { [weak self] connection, error in
            guard let self else { return }

            NSLog("onErrorOrClose for connection: [\(String(describing: connection))], Error = [\(String(describing: error))]")

            
            
            
            
            

            connections.remove(connection)

            NSLog("Removing Connection: [\(connections.count()) current connections]")
        }

        connections.add(incoming)

        NSLog("newConnection: [\(connections.count()) current connections]")
    }

    
}
