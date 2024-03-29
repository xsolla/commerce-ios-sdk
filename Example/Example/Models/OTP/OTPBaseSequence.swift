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

import UIKit
import XsollaSDKLoginKit

class OTPBaseSequence: OTPSequenceProtocol
{
    typealias CodeRequestResult = Result<OTPConfirmationCode, Error>

    var operationId: LoginOperationId?
    var payload: OTPRequestPayload?

    func startListeningConfirmationCode(completion: @escaping (Result<OTPConfirmationCode, Error>) -> Void)
    {
        guard !isCodeExpired else { completion(.failure(OTPSequenceError.expiredCode)); return }
        guard let operationId = operationId else { completion(.failure(OTPSequenceError.invalidOperationId)); return }
        guard let payload = payload else { completion(.failure(OTPSequenceError.invalidPayload)); return }

        if backgroundTask == .invalid { registerBackgroundTask() }

        sdk.getConfirmationCode(projectId: AppConfig.loginId, login: payload, operationId: operationId)
        { [weak self] result in

            if let backgroundTask = self?.backgroundTask, backgroundTask != .invalid { self?.endBackgroundTask() }
            self?.processCodeRequestResult(result, for: operationId, payload: payload, completion: completion)
        }
    }

    var isCodeExpired: Bool
    {
        guard let codeRequestDate = codeRequestDate else { return true }

        return Date() > codeRequestDate.addingTimeInterval(codeExpirationDuration)
    }

    func processCodeRequestResult(_ result: CodeRequestResult,
                                  for operationId: LoginOperationId,
                                  payload: String,
                                  completion: @escaping (CodeRequestResult) -> Void)
    {
        guard
            let actualOperationId = self.operationId,
            let actualPayload = self.payload,
            actualOperationId == operationId,
            actualPayload == payload
        else
        {
            completion(.failure(OTPSequenceError.invalidOTPSequence))
            return
        }

        if case .success(let code) = result
        {
            completion(.success(code))
        }

        if case .failure(let error) = result
        {
            logger.error { error }

            if isCodeExpired { completion(.failure(OTPSequenceError.expiredCode)) }
            else             { startListeningConfirmationCode(completion: completion) }
        }
    }

    @discardableResult
    func sendOTPRequest(payload: OTPRequestPayload,
                        state: OTPRequestState,
                        confirmationLink: String?,
                        completion: @escaping (Result<LoginOperationId, Error>) -> Void) -> OTPRequestState
    {
        fatalError("Must be overriden in subclass")
    }

    func validateOTPCode(_ code: OTPConfirmationCode,
                         completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        fatalError("Must be overriden in subclass")
    }

    func validatePayload(_ payload: OTPRequestPayload) -> Bool
    {
        return !payload.isEmpty
    }

    var sdk: XsollaSDKProtocol
    var sendConfirmationLink: Bool = true
    var confirmationLink: String? = AppConfig.passwordlessConfirmationUrl

    var clientId: Int { AppConfig.oAuth2ClientId }

    func startSession(payload: String, operationId: LoginOperationId, codeExpirationDuration: TimeInterval)
    {
        invalidateSession()

        self.payload = payload
        self.operationId = operationId
        self.codeExpirationDuration = codeExpirationDuration
        self.codeRequestDate = Date()
    }

    func invalidateSession()
    {
        operationId = nil
        payload = nil
        codeRequestDate = nil
        codeExpirationDuration = defaultCodeExpirationDuration
    }

    func createOauthParams(state: OTPRequestState) -> OAuth2Params
    {
        OAuth2Params(clientId: clientId,
                     state: state,
                     scope: "offline",
                     redirectUri: AppConfig.redirectUrl)
    }

    // MARK: - Code expiration interval

    var defaultCodeExpirationDuration: TimeInterval { 180 }
    var codeExpirationDuration: TimeInterval = 0
    var codeRequestDate: Date?

    var codeExpirationInterval: TimeInterval
    {
        guard let date = codeRequestDate else { return 0 }

        return max(codeExpirationDuration - Date().timeIntervalSince(date), 0)
    }

    // MARK: - Background tasks

    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func registerBackgroundTask()
    {
        backgroundTask = UIApplication.shared.beginBackgroundTask
        { [weak self] in
            self?.endBackgroundTask()
        }
    }

    func endBackgroundTask()
    {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    init(sdk: XsollaSDKProtocol)
    {
        self.sdk = sdk
    }
}
