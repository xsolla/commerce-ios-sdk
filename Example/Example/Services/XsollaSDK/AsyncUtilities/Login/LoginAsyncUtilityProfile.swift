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

extension LoginAsyncUtility: LoginAsyncUtilityProfileProtocol
{
    // MARK: - Fetch user profile data

    func fetchUserProfileDetails() -> Promise<UserProfileDetails>
    {
        let api = self.api

        return Promise<UserProfileDetails>
        { fulfill, reject in

            api.getCurrentUserDetails
            { result in

                switch result
                {
                    case .success(let details): fulfill(details)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    // MARK: - Upload user details

    func uploadMandatoryDetails(_ details: UserProfileMandatoryDetailsProtocol) -> Promise<UserProfileDetails>
    {
        let loginKitUserGender: UserProfileDetails.Gender? =
        {
            switch details.gender
            {
                case .female: return .female
                case .male: return .male
                case .other: return .other
                case .unspecified: return .unspecified
                default: return nil
            }
        }()

        let api = self.api

        return Promise<UserProfileDetails>
        { fulfill, reject in

            api.updateCurrentUserDetails(birthday: details.birthday,
                                         firstName: details.firstName,
                                         lastName: details.lastName,
                                         nickname: details.nickname,
                                         gender: loginKitUserGender)
            { result in

                switch result
                {
                    case .success(let userDetails): fulfill(userDetails)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func uploadPhone(_ phone: String?) -> Promise<Void>
    {
        let api = self.api

        return Promise<Void>
        { fulfill, reject in

            guard let phone = phone else { fulfill(()); return }

            api.updateCurrentUserPhone(phoneNumber: phone)
            { result in

                switch result
                {
                    case .success: fulfill(())
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func uploadUserPicture(url: URL) -> Promise<String>
    {
        let api = self.api

        return Promise<String>
        { fulfill, reject in

            api.uploadUserPicture(imageURL: url)
            { result in

                switch result
                {
                    case .success(let imageLink): fulfill(imageLink)
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    func removeUserPicture() -> Promise<Void>
    {
        let api = self.api

        return Promise<Void>
        { fulfill, reject in

            api.deleteUserPicture
            { result in

                switch result
                {
                    case .success: fulfill(())
                    case .failure(let error): reject(error)
                }
            }
        }
    }

    // MARK: - Upgrade

    func upgradeAccount(withUsername username: String,
                        password: String,
                        email: String,
                        promoEmailAgreement: Bool,
                        redirectUri: String?) -> Promise<Bool>
    {
        let api = self.api

        return Promise<Bool>
        { fulfill, reject in

            api.addUsernameAndPassword(username: username,
                                       password: password,
                                       email: email,
                                       promoEmailAgreement: promoEmailAgreement,
                                       redirectUri: redirectUri)
            { result in

                switch result
                {
                    case .success(let emailConfirmationRequired): fulfill(emailConfirmationRequired)
                    case .failure(let error): reject(error)
                }
            }
        }
    }
}
