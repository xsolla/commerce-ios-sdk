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

class OTPPhoneSequence: OTPBaseSequence
{
    @discardableResult
    override func sendOTPRequest(payload: OTPRequestPayload,
                                 state: OTPRequestState,
                                 confirmationLink: String?,
                                 completion: @escaping (Result<LoginOperationId, Error>) -> Void) -> OTPRequestState
    {
        invalidateSession()

        let oauthParams = createOauthParams(state: state)

        sdk.startAuthByPhone(oAuth2Params: oauthParams,
                             phoneNumber: payload,
                             linkUrl: confirmationLink,
                             sendLink: AppConfig.sendPhoneOTPConfirmationLink)
        { [weak self] result in

            switch result
            {
                case .success(let operationId): do
                {
                    self?.startSession(payload: payload,
                                       operationId: operationId,
                                       codeExpirationDuration: self?.defaultCodeExpirationDuration ?? 0)

                    completion(.success(operationId))
                }

                case .failure(let error): completion(.failure(error))
            }
        }

        return state
    }

    override func validateOTPCode(_ code: String,
                                  completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        guard let operationId = operationId else { completion(.failure(OTPSequenceError.invalidOperationId)); return }
        guard let payload = payload else { completion(.failure(OTPSequenceError.invalidPayload)); return }

        guard codeExpirationInterval > 0 else { completion(.failure(OTPSequenceError.expiredCode)); return }

        let jwtParams = JWTGenerationParams(clientId: clientId, redirectUri: AppConfig.redirectUrl)

        sdk.completeAuthByPhone(clientId: clientId,
                                code: code,
                                phoneNumber: payload,
                                operationId: operationId,
                                jwtParams: jwtParams)
        { result in

            switch result
            {
                case .success(let tokenInfo): completion(.success(tokenInfo))
                case .failure(let error): completion(.failure(error))
            }
        }
    }
}
