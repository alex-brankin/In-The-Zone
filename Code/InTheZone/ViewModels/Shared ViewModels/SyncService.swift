//
//  InTheZone
//
//  Created by Alex Brankin on 02/03/2024.
//
// The SyncService class implements communication between an iOS device and an Apple Watch using the
// WCSession API from the WatchConnectivity framework. It manages the session's lifecycle, handling its activation
// and state changes, and provides functionality to send and receive messages between devices. The class uses
// asynchronous methods to handle data received from the watch, and includes error handling and retry logic for
// message sending, ensuring robustness in the communication process.

import Foundation
import WatchConnectivity

class SyncService : NSObject, WCSessionDelegate {
    private var session: WCSession = .default
    var dataReceived: ((String, Any) -> Void)?
    
    init(session: WCSession = .default) {
        self.session = session

        super.init()

        self.session.delegate = self
        self.connect()
    }
    
    func connect(){
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
        
        session.activate()
        print("WCSession activated")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
    }
    #endif

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard dataReceived != nil else {
            print("Received data, but 'dataReceived' handler is not provided")
            return
        }
        
        DispatchQueue.main.async {
            if let dataReceived = self.dataReceived {
                for pair in message {
                    dataReceived(pair.key, pair.value)
                }
            }
        }
        print("Received message")
    }

    func sendMessage(_ key: String, _ message: String, _ errorHandler: ((Error) -> Void)?) {
        sendWithRetry(key, message, errorHandler, delay: 60, retries: 0)
    }
    
    private func sendWithRetry(_ key: String, _ message: String, _ errorHandler: ((Error) -> Void)?, delay: TimeInterval, retries: Int) {
        if session.isReachable {
            session.sendMessage([key : message], replyHandler: nil) { (error) in
                print("Error sending message: \(error.localizedDescription)")
                if let errorHandler = errorHandler {
                    errorHandler(error)
                }
                
                if retries > 0 {
                    print("Retrying message in \(delay) seconds...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.sendWithRetry(key, message, errorHandler, delay: delay, retries: retries - 1)
                    }
                } else {
                    print("Exceeded maximum retries.")
                }
            }
            print("Message sent to Watch")
        } else {
            print("Watch is not reachable. Retrying in \(delay) seconds...")
        }
    }
}
