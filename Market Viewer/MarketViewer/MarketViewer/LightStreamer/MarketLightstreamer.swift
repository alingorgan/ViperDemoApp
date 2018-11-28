//
//  MarketLightstreamer.swift
//  MarketViewer
//
//  Copyright © 2017 ACME. All rights reserved.
//

import Lightstreamer_iOS_Client

 /**
   Notification to know when lightstreamer has started streaming, if needed, or use delegate
  */
let lightstreamerConnectedNotification = Notification.Name("event.lightstreamer.connected-streaming")
let lightstreamerDisconnectedNotification = Notification.Name("event.lightstreamer.disconnected")
let lightstreamerStalledNotification = Notification.Name("event.lightstreamer.stalled")

/**
  A delegate to receive connection updates from the Lightstreamer. Either use this delegate or register to listen notifications (see above)
 */
protocol MarketLightstreamerDelegate: class {
    /**
     Tells the delegate that lightstreamer has started up and is ready to receive subscriptions
     */
    func lightstreamerDidStartStreaming()
    
    /**
     Informs the delegate of the error message returned by lightstreamer
     */
    func lightstreamerDidReceiveError(errorMessage error: String?)
    
    /**
     Tells the delegate that lightstreamer has stop streaming
     */
    func lightstreamerDidStopStreaming()
    
    /**
     Tells the delegate that lightstreamer has stalled
     */
    func lightstreamerDidStall()
}

/**
 Use this class to stream market data. You can either implement LSClientDelegate to receive updates on the connection status, or register to listen to Notifications (see above). This class is an NSObject subclass so it can conform to the LightStreamer delegate.
*/
class MarketLightstreamer: NSObject, MVMarketLightStreaming {
    
    weak var marketLSDelegate: MarketLightstreamerDelegate?
    
    private var lightStreamerClient: LSLightstreamerClient?
    
    fileprivate var isConnected = false
    
    /**
     This method will connect to Lightstreamer and initialise the system to observe markets.
     - Parameter endpoint: LIGHTSTREAMER URL. This information will be returned by the by the /session API response.
     - Parameter user: Client Account ID
     - Parameter cst: CST token
     - Parameter xst: XST token
     */
    func startStreaming(withEndpoint endpoint: String, user: String, cst: String, xst: String) {
        
        if isConnected { return }
        
        lightStreamerClient = LSLightstreamerClient(serverAddress: endpoint, adapterSet: nil)
        
        if let lsClient = lightStreamerClient {
            lsClient.connectionDetails.user = user
            lsClient.connectionDetails.setPassword("CST-" + cst + "|XST-" + xst)
            lsClient.addDelegate(self)
            
            lsClient.connect()
        }
    }
    /**
     This method will disconnect from Lightstreamer
     */
    func stopStreaming() {
        
        guard let lsClient = lightStreamerClient else {
            return
        }
        
        lsClient.disconnect()
        lightStreamerClient = nil
    }
    
    /**
     This method is used to subscribe to market updates.
     - Parameter epic: a string that represents the market. See REST API documentation at https://labs.ig.com/rest-trading-api-guide
     - Parameter forFields: an array of properties to observe. You can find out about these fields in the API documentation at https://labs.ig.com/streaming-api-reference
     - Parameter withDelegate: Lightstreamer subscription delegate. Implement this delegate to get updates.
     - SeeAlso: /gateway/deal/markets/{watchlistId} response for epic
     */
    func observeMarket(withEpic epic: String, forFields fields: [String], withDelegate delegate: LSSubscriptionDelegate) {
        let subscription = LSSubscription(subscriptionMode: "MERGE", item: "MARKET:" + epic, fields: fields)
        subscription.addDelegate(delegate)
        
        if let lsClient = lightStreamerClient {
            lsClient.subscribe(subscription)
        }
        
    }
    
    /**
     You do not need this method for the purposes of this exercise.
     */
    func subscribeToChart(withEpic epic: String, fields: Array<String>, andDelegate delegate: LSSubscriptionDelegate) {
        let chartSubscription = LSSubscription(subscriptionMode: "DISTINCT", item: "CHART:" + epic + ":TICK", fields: fields)
        chartSubscription.addDelegate(delegate)
        
        if let lsClient = lightStreamerClient {
            lsClient.subscribe(chartSubscription)
        }
    }
    
    func isStreaming() -> Bool {
        return isConnected
    }
}

//MARK: LSClientDelegate implementation
extension MarketLightstreamer: LSClientDelegate {
    
    /**
     Event handler that receives a notification each time the LSLightstreamerClient status has changed.
     */
    func client(_ client: LSLightstreamerClient, didChangeStatus status: String) {
        if status == "CONNECTED:HTTP-STREAMING" {
            marketLSDelegate?.lightstreamerDidStartStreaming()
            isConnected = true
            NotificationCenter.default.post(Notification(name: lightstreamerConnectedNotification))
        } else if status == "DISCONNECTED" {
            marketLSDelegate?.lightstreamerDidStopStreaming()
            NotificationCenter.default.post(Notification(name: lightstreamerDisconnectedNotification))
            isConnected = false
        } else if status == "STALLED" {
            marketLSDelegate?.lightstreamerDidStall()
            NotificationCenter.default.post(Notification(name: lightstreamerStalledNotification))
        }
    }
    /**
     Event handler that is called when the Server notifies a refusal on the client attempt to open a new connection or the interruption of a streaming connection.
     */
    func client(_ client: LSLightstreamerClient, didReceiveServerError errorCode: Int, withMessage errorMessage: String?) {
        marketLSDelegate?.lightstreamerDidReceiveError(errorMessage: errorMessage)
    }
}
