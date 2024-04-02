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
}

public func send(heartRate: Int) {
    guard WCSession.default.activationState == .activated else {
        return
    }
    let userInfo: [String: Any] = ["heartRate": heartRate]
    WCSession.default.transferUserInfo(userInfo)
}

func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    if userInfo["heartRate"] is Int {
        // Update your UI with the received heart rate
    }
}



