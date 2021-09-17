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

enum OTPSequenceError: Error
{
    // Provided operationId is no equal to stored operationId, params: (provided operationId, stored operationId)
    case operationIdMismatch(OTPOperationId, OTPOperationId?)

    // Operation ID is not set or invalid
    case invalidOperationId

    // OTP Code is expired
    case expiredCode

    // OTP Code is invalid
    case invalidOTPCode

    // Access code is not found in redirectUrl or invalid
    case authCodeExtractionFailure

    // Access token failed to extract from LoginUrl
    case tokenNotFound

    // Entered phone number or email is invalid
    case invalidPayload

    // Invalid or unknown OTP sequence 
    case invalidOTPSequence
}

extension OTPSequenceError: LocalizedError
{
    public var errorDescription: String?
    {
        switch self
        {
            case .operationIdMismatch: return L10n.OTPSequenceError.operationIdMismatch
            case .invalidOperationId: return L10n.OTPSequenceError.invalidOperationId
            case .expiredCode: return L10n.OTPSequenceError.expiredCode
            case .invalidOTPCode: return L10n.OTPSequenceError.invalidOTPCode
            case .authCodeExtractionFailure: return L10n.OTPSequenceError.invalidAccessCode
            case .tokenNotFound: return L10n.OTPSequenceError.tokenNotFound
            case .invalidPayload: return L10n.OTPSequenceError.invalidPayload
            case .invalidOTPSequence: return L10n.OTPSequenceError.invalidOTPSequence
        }
    }
}
