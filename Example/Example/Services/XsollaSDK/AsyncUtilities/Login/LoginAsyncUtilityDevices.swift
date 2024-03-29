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
import XsollaSDKLoginKit
import Promises

extension LoginAsyncUtility: LoginAsyncUtilityDevicesProtocol
{
    @discardableResult
    func fetchUserConnectedDevices() -> Promise<[DeviceInfo]>
    {
        let api = self.api

        return Promise<[DeviceInfo]>
        { fulfill, reject in

            api.getUserConnectedDevices
            { result in

                switch result
                {
                    case .success(let devices): fulfill(devices)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func unlinkDevice(deviceId: String) -> Promise<Void>
    {
        let api = self.api

        return Promise<Void>
        { fulfill, reject in

            api.unlinkDeviceFromAccount(deviceId: deviceId)
            { result in

                switch result
                {
                    case .success: fulfill(())
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func linkDevice(deviceName name: String, deviceId: String) -> Promise<Void>
    {
        let api = self.api

        return Promise<Void>
        { fulfill, reject in

            api.linkDeviceToAccount(device: name, deviceId: deviceId)
            { result in

                switch result
                {
                    case .success: fulfill(())
                    case .failure(let error): reject(error)
                }
            }
        }
    }
}
