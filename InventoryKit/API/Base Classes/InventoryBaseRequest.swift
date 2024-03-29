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
import UIKit
import XsollaSDKUtilities

class InventoryBaseRequest<ParamsType: RequestParams>: APIBaseRequest
{
    let params: ParamsType

    init(params: ParamsType, apiConfiguration: APIConfigurationProtocol)
    {
        logger.debug(.initialization, domain: .inventoryKit) { String(describing: Self.self) }
        
        self.params = params
        super.init(apiConfiguration: apiConfiguration)
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .inventoryKit) { deinitingType }
    }
    
    override var headers: APIBaseRequest.HTTPHeaders
    {
        var headers = defaultHeaders

        headers.merge(authHeaders) { (_, new) in new }
        headers.merge(specialHeaders) { (_, new) in new }
        headers.merge(analyticsHeaders) { (_, new) in new }

        return headers
    }
    
    override var queryParameters: APIBaseRequest.QueryParameters
    {
        var parameters = defaultParameters

        parameters.merge(specialQueryParameters) { (_, new) in new }
        parameters.merge(analyticsQueryParams) { (_, new) in new }

        return parameters
    }
    
    // MARK: Analytics Parameters
    
    var analyticsQueryParams: APIBaseRequest.QueryParameters
    {
        var params: APIBaseRequest.QueryParameters = [
            "engine": "ios",
            "engine_v": iOSVersion,
            "sdk": InventoryAnalyticsUtils.sdk,
            "sdk_v": InventoryAnalyticsUtils.sdkVersion]
        
        if !InventoryAnalyticsUtils.gameEngine.isEmpty
        {
            params["game_engine"] = InventoryAnalyticsUtils.gameEngine
        }
        
        if !InventoryAnalyticsUtils.gameEngineVersion.isEmpty
        {
            params["game_engine_v"] = InventoryAnalyticsUtils.gameEngineVersion
        }
        
        return params
    }
    
    var analyticsHeaders: APIBaseRequest.HTTPHeaders
    {
        var headers: APIBaseRequest.HTTPHeaders = [
            "X-ENGINE": "IOS",
            "X-ENGINE-V": iOSVersion.uppercased(),
            "X-SDK": InventoryAnalyticsUtils.sdk.uppercased(),
            "X-SDK-V": InventoryAnalyticsUtils.sdkVersion.uppercased()]
        
        if !InventoryAnalyticsUtils.gameEngine.isEmpty
        {
            headers["X-GAME-ENGINE"] = InventoryAnalyticsUtils.gameEngine.uppercased()
        }
        
        if !InventoryAnalyticsUtils.gameEngineVersion.isEmpty
        {
            headers["X-GAME-ENGINE-V"] = InventoryAnalyticsUtils.gameEngineVersion.uppercased()
        }
        
        return headers
    }
    
    private var iOSVersion: String { UIDevice.current.systemVersion }
}
