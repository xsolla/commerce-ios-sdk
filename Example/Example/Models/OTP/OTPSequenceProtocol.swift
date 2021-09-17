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

typealias OTPRequestPayload = String
typealias OTPOperationId = String
typealias OTPRequestState = String
typealias OTPConfirmationCode = String

protocol OTPSequenceProtocol
{
    var codeExpirationInterval: TimeInterval { get }
    var operationId: OTPOperationId? { get }
    var payload: OTPRequestPayload? { get }

    func invalidateSession()

    @discardableResult
    func sendOTPRequest(payload: OTPRequestPayload,
                        state: OTPRequestState,
                        confirmationLink: String?,
                        sendConfirmationLink: Bool,
                        completion: @escaping (Result<OTPOperationId, Error>) -> Void) -> OTPRequestState

    func validatePayload(_ payload: OTPRequestPayload) -> Bool

    func validateOTPCode(_ code: OTPConfirmationCode,
                         completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)

    func startListeningConfirmationCode(completion: @escaping (Result<OTPConfirmationCode, Error>) -> Void)
}

extension OTPSequenceProtocol
{
    @discardableResult
    func sendOTPRequest(payload: OTPRequestPayload,
                        state: OTPRequestState,
                        confirmationLink: String? = nil,
                        sendConfirmationLink: Bool = false,
                        completion: @escaping (Result<OTPOperationId, Error>) -> Void) -> OTPRequestState
    {
        sendOTPRequest(payload: payload,
                       state: state, 
                       confirmationLink: confirmationLink,
                       sendConfirmationLink: sendConfirmationLink,
                       completion: completion)
    }
}
