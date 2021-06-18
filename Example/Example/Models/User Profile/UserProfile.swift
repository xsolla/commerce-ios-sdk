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

protocol UserProfileListener: AnyObject
{
    func userProfileDidUpdateDetails(_ userProfile: UserProfileProtocol)
    func userProfileDidResetPassword()
}

extension UserProfileListener
{
    func userProfileDidUpdateDetails(_ userProfile: UserProfileProtocol) {}
    func userProfileDidResetPassword() {}
}

protocol UserProfileDetailsProvider: AnyObject
{
    var userDetails: UserProfileDetails? { get }
}

protocol UserProfileProtocol: UserProfileDetailsProvider
{
    var state: UserProfileState { get }

    func fetchUserDetails(completion: ((Result<UserProfileDetails, Error>) -> Void)?)
    func updateUserDetails(with userMandatoryDetails: UserProfileMandatoryDetailsProtocol,
                           completion: ((Result<UserProfileDetails, Error>) -> Void)?)

    func uploadUserPicture(url: URL, completion: ((Result<String, Error>) -> Void)?)
    func removeUserPicture(completion: ((Error?) -> Void)?)
    func resetPassword(completion: ((Error?) -> Void)?)
    
    @discardableResult
    func addListener(_ listener: UserProfileListener) -> UUID
    func removeListener(uuid: UUID)
}

enum UserProfileState
{
    case initial
    case loading
    case loaded
}

class UserProfile: UserProfileProtocol
{
    // MARK: - UserProfileProtocol

    var state: UserProfileState = .initial { didSet { onUserDetailsDidUpdate() } }

    var listeners = NSMapTable<NSString, AnyObject>(keyOptions: .copyIn, valueOptions: .weakMemory)
    
    var userDetails: UserProfileDetails?

    func fetchUserDetails(completion: ((Result<UserProfileDetails, Error>) -> Void)?)
    {
        dependencies.asyncUtility.fetchUserProfileDetails()
        .then
        { details in
            self.userDetails = details
            self.state = .loaded
            completion?(.success(details))
        }
        .catch { error in completion?(.failure(error)) }
    }

    func updateUserDetails(with userMandatoryDetails: UserProfileMandatoryDetailsProtocol,
                           completion: ((Result<UserProfileDetails, Error>) -> Void)?)
    {
        var userPhone: String?

        if let phone = userMandatoryDetails.phone, !phone.isEmpty, phone != userDetails?.phone { userPhone = phone }
        
        state = .loading
        dependencies.asyncUtility.createPromisesChain()
            .then  { self.dependencies.asyncUtility.uploadPhone(userPhone) }
            .then  { self.dependencies.asyncUtility.uploadMandatoryDetails(userMandatoryDetails) }
            .then
            { details in
                self.userDetails = details
                self.state = .loaded
                completion?(.success(details))
            }
            .catch { error in completion?(.failure(error)) }
    }

    func uploadUserPicture(url: URL, completion: ((Result<String, Error>) -> Void)?)
    {
        state = .loading
        dependencies.asyncUtility.uploadUserPicture(url: url)
            .then
            { link in
                self.userDetails?.picture = link
                self.state = .loaded
                completion?(.success(link))
            }
            .catch  { error in completion?(.failure(error)) }
    }

    func removeUserPicture(completion: ((Error?) -> Void)?)
    {
        state = .loading
        dependencies.asyncUtility.removeUserPicture()
            .then
            {
                self.userDetails?.picture = nil
                self.state = .loaded
                completion?(nil)
            }
            .catch  { error in completion?(error) }
    }
    
    func resetPassword(completion: ((Error?) -> Void)?)
    {
        guard let username = userDetails?.username
        else
        {
            completion?(NSError())
            return
        }
        
        dependencies.asyncUtility.resetPassword(username: username)
            .then
            {
                self.onUserProfileDidResetPassword()
                completion?(nil)
            }
            .catch { error in completion?(error) }
    }
    
    private func onUserDetailsDidUpdate()
    {
        for case let listener as UserProfileListener in listeners.dictionaryRepresentation().values
        {
            listener.userProfileDidUpdateDetails(self)
        }
    }
    
    private func onUserProfileDidResetPassword()
    {
        for case let listener as UserProfileListener in listeners.dictionaryRepresentation().values
        {
            listener.userProfileDidResetPassword()
        }
    }

    // MARK: - Initialization

    let dependencies: Dependencies

    init(dependencies: Dependencies)
    {
        self.dependencies = dependencies
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}

extension UserProfile
{
    func addListener(_ listener: UserProfileListener) -> UUID
    {
        let uuid = UUID()
        listeners.setObject(listener, forKey: uuid.uuidString as NSString)
        return uuid
    }
    
    func removeListener(uuid: UUID)
    {
        listeners.removeObject(forKey: uuid.uuidString as NSString)
    }
}

extension UserProfile
{
    struct Dependencies
    {
        let asyncUtility: UserProfileAsyncUtilityProtocol
    }
}
