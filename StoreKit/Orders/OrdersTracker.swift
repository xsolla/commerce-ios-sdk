// Copyright 2021-present Xsolla (USA), Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at q
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing and permissions and

import Foundation
import SwiftCentrifuge
import UIKit

class OrderStatusListener
{
    var token: String
    var timer: Timer?
    public var onStatusUpdate: ((_ status: String) -> Void)?
    public var onFailure: (() -> Void)?
    
    init(_ paymentToken: String)
    {
        token = paymentToken
    }
}

class OrdersTracker
{
    private var storeApi: StoreAPIProtocol
    private var projectId: Int = -1
    private var authToken: String = ""
    private var initialized: (() -> Void)?
    
    private static var centrifugoEndpoint: String = "wss://ws-store.xsolla.com/connection/websocket"
    private static var shortPollingTimeout: TimeInterval = 3.0 // 3 sec
    
    var centrifugeClient: CentrifugeClient?
    var listeners = [Int: OrderStatusListener]()
    var completedOrders = [Int]()
    
    init(storeApi: StoreAPIProtocol) 
    {
        self.storeApi = storeApi
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.disconnectClient(_:)), 
                                                     name: UIApplication.willResignActiveNotification,
                                                     object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.connectClient(_:)),
                                                     name: UIApplication.didBecomeActiveNotification,
                                                     object: nil)
        
    }
    
    func initializeCentrifuge(projectId: Int, authToken: String, initialized: (() -> Void)?)
    {
        print("initializeCentrifuge")
        if centrifugeClient == nil
        {
            self.projectId = projectId
            self.authToken = authToken
            self.initialized = initialized
            
            let data = ["auth": authToken, "project_id": projectId] as [String: Any]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return }
        
            let config = CentrifugeClientConfig(
                data: jsonData,
                tokenGetter: nil,
                logger: nil
            )
        
            self.centrifugeClient = CentrifugeClient(endpoint: OrdersTracker.centrifugoEndpoint,
                                                     config: config,
                                                     delegate: self)
            self.centrifugeClient?.connect()
            
        }
    }
    
    func addToTracking(projectId: Int,
                       authToken: String,
                       orderId: Int,
                       paymentToken: String,
                       initialized: (() -> Void)?,
                       completion: @escaping (Result<String, Error>) -> Void)
    {
        if centrifugeClient != nil
        {
            if centrifugeClient!.state != CentrifugeClientState.connected
            {
                self.initialized = initialized
                centrifugeClient!.connect()
            } else
            {
                initialized?()
            }
        } else
        {
            initializeCentrifuge(projectId: projectId, authToken: authToken, initialized: initialized)
        }
        
        let listener = OrderStatusListener(paymentToken)
        listener.onStatusUpdate =
        { status in
            let result: Result<String, Error> = .success(status)
            completion(result)
        }
        
        listener.onFailure = 
        {
            let error: Error = NSError(domain: "com.xsolla",
                                       code: 0,
                                       userInfo: [NSLocalizedDescriptionKey: "Network error"])
            let result: Result<String, Error> = .failure(error)
            completion(result)
        }
        
        listeners[orderId] = listener
    }
    
    func switchToShortPolling()
    {
        print("switchToShortPolling")
        for (key, value) in listeners
        {
            startOrderShortPolling(listener: value, orderId: key)
        }
        listeners.removeAll()
    }
    
    func startOrderShortPolling(listener: OrderStatusListener,
                                orderId: Int)
    {
        let authorizationType = StoreAuthorizationType.authorized(accessToken: authToken )
        storeApi.getOrder(projectId: projectId, orderId: String(orderId), authorizationType: authorizationType)
        { [weak self] result in
            switch result
            {
                case .success(let response): do
                {
                    if response.status != nil
                    {
                        if !["done", "canceled"].contains(response.status)
                        {
                            listener.timer?.invalidate()
                            listener.timer = Timer.scheduledTimer(withTimeInterval: OrdersTracker.shortPollingTimeout,
                                                               repeats: false)
                            { _ in
                                self?.startOrderShortPolling(listener: listener,
                                                             orderId: orderId)
                            }
                        } else 
                        {
                            self?.completedOrders.append(orderId)
                        }
                        listener.onStatusUpdate?(response.status!)
                    } else
                    {
                        listener.onFailure?()
                    }
                }
                    
                case .failure(_): do
                {
                    listener.timer?.invalidate()
                    listener.timer = Timer.scheduledTimer(withTimeInterval: OrdersTracker.shortPollingTimeout, 
                                                       repeats: false)
                    { _ in
                        self?.startOrderShortPolling(listener: listener, 
                                                     orderId: orderId)
                    }
                }
            }
        }
    }
    
    @objc func disconnectClient(_ notification: Notification)
    {
        if centrifugeClient != nil
        {
            if centrifugeClient!.state == CentrifugeClientState.connected
            {
                centrifugeClient?.disconnect()
            }
        }
    }
    
    @objc func connectClient(_ notification: Notification)
    {
        if centrifugeClient != nil && listeners.count != 0
        {
            if centrifugeClient!.state != CentrifugeClientState.connected
            {
                centrifugeClient!.connect()
            }
        }
    }
}

extension OrdersTracker: CentrifugeClientDelegate
{
    func onConnected(_ c: CentrifugeClient, _ e: CentrifugeConnectedEvent)
    {
        print("connected with id", e.client)
        if initialized != nil
        {
            initialized?()
            initialized = nil
        }
    }
    
    func onDisconnected(_ c: CentrifugeClient, _ e: CentrifugeDisconnectedEvent)
    {
        print("disconnected with code", e.code, "and reason", e.reason)
    }
    
    func onConnecting(_ c: CentrifugeClient, _ e: CentrifugeConnectingEvent)
    {
        print("connecting with code", e.code, "and reason", e.reason)
    }

    func onPublication(_ client: CentrifugeClient, _ event: CentrifugeServerPublicationEvent)
    {
        print("server-side publication from", event.channel, "offset", event.offset)
        if !event.data.isEmpty
        {
            do
            {
                let jsonObject = try JSONSerialization.jsonObject(with: event.data, options: [])
                if let jsonDict = jsonObject as? [String: Any]
                {
                    let orderId = jsonDict["order_id"] as? Int
                    let status = jsonDict["status"] as? String
                    if let orderListener = listeners[orderId!]
                    {
                        orderListener.onStatusUpdate?(status!)
                        if ["done", "canceled"].contains(status)
                        {
                            listeners.removeValue(forKey: orderId!)
                            completedOrders.append(orderId!)
                        }
                    } else
                    {
                        if !completedOrders.contains(orderId!)
                        {
                            print("Listener for orderId \(orderId!) not found")
                        }
                    }
                }
            } catch
            {
                switchToShortPolling()
                centrifugeClient = nil
            }
        }
    }
       
    func onError(_ client: CentrifugeClient, _ event: CentrifugeErrorEvent)
    {
        print("client error \(event.error)")
        if client.state == CentrifugeClientState.connected || client.state == CentrifugeClientState.connecting
        {
            switchToShortPolling()
        }
        
        if initialized != nil
        {
            initialized?()
            initialized = nil
        }
        centrifugeClient = nil
    }
}
