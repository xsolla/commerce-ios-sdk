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

class OTPEmailSequence: OTPBaseSequence
{
    @discardableResult
    override func sendOTPRequest(payload: OTPRequestPayload,
                                 state: OTPRequestState,
                                 confirmationLink: String?,
                                 sendConfirmationLink: Bool,
                                 completion: @escaping (Result<OTPOperationId, Error>) -> Void) -> OTPRequestState
    {
        invalidateSession()

        let oauthParams = createOauthParams(state: state)

        sdk.startAuthByEmail(oAuth2Params: oauthParams,
                             email: payload,
                             linkUrl: confirmationLink,
                             sendLink: sendConfirmationLink)
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

    override func validateOTPCode(_ code: OTPConfirmationCode,
                                  completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        guard let operationId = operationId else { completion(.failure(OTPSequenceError.invalidOperationId)); return }
        guard let payload = payload else { completion(.failure(OTPSequenceError.invalidPayload)); return }

        guard codeExpirationInterval > 0 else { completion(.failure(OTPSequenceError.expiredCode)); return }

        sdk.completeAuthByEmail(clientId: clientId, code: code, email: payload, operationId: operationId)
        { [weak self, operationId, payload] result in

            guard
                let actualOperationId = self?.operationId,
                let actualPayload = self?.payload,
                actualOperationId == operationId,
                actualPayload == payload
            else
            {
                completion(.failure(OTPSequenceError.invalidOTPSequence))
                return
            }

            switch result
            {
                case .success(let loginUrl): self?.getAccessToken(from: loginUrl, completion: completion)
                case .failure(let error): completion(.failure(error))
            }
        }
    }
}
