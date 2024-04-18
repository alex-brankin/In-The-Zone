//
//  Connectivity.swift
//  InTheZone
//
//  Created by Alex Brankin on 02/04/2024.
//

import Foundation
import WatchConnectivity

final class Connectivity: NSObject {
    static let shared = Connectivity()

    private override init() {
        super.init()
        #if !os(watchOS)
        guard WCSession.isSupported() else {
            return
        }
        #endif
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
}

extension Connectivity: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error activating session: \(error.localizedDescription)")
            return
        }
        // Handle activation completion
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation
    }
    #endif

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        if let heartRate = userInfo["heartRate"] as? Int {
            print("Received heart rate: \(heartRate)")
            // Update your UI with the received heart rate
        }
    }
}

extension Connectivity {
    public func send(heartRate: Int) {
        guard WCSession.default.activationState == .activated else {
            print("Error: WCSession is not activated")
            return
        }
        let userInfo: [String: Any] = ["heartRate": heartRate]
        WCSession.default.transferUserInfo(userInfo)
    }
}
