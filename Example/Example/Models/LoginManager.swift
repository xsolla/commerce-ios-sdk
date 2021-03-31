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

enum LoginManagerError: Error
{
    case tokenHasExpired
    case cannotUpdateToken
    case accessTokenNotFound
    case refreshTokenNotFound
}

protocol LoginInfoProvider
{
    var userLogedIn: Bool { get }
}

protocol LoginManagerProtocol: LoginInfoProvider
{
    var currentUserInfo: AppUserInfo? { get }

    var delegate: LoginManagerDelegate? { get set }

    func login(accessToken: String, refreshToken: String?, expireDate: Date?)
    func logout()

    func setCurrentUserInfo(_ userInfo: AppUserInfo)

    func getAccessToken(withUpdateAttempt: Bool, completion: @escaping (Result<String, LoginManagerError>) -> Void)
}

protocol LoginManagerDelegate: AnyObject
{
    func tokenInfoNotFound(_ error: LoginManagerError)
}

/// WARNING!
/// We strongly recommend to avoid storing sensitive personal data, including various authorization tokens, in UserDefalts in your real application, keychain is best suited for this for security reasons. We intentionally use UserDefaults in the demo application, but don't do it in a real project!

class LoginManager: LoginManagerProtocol
{
    static let shared = LoginManager()

    var currentUserInfo: AppUserInfo?

    weak var delegate: LoginManagerDelegate?

    func logout()
    {
        UserDefaults.standard.removeObject(forKey: Keys.accessToken)
        UserDefaults.standard.removeObject(forKey: Keys.refreshToken)
        UserDefaults.standard.removeObject(forKey: Keys.tokenExpireDate)
    }

    private var accessToken: String?
    {
        set { UserDefaults.standard.set(newValue, forKey: Keys.accessToken) }
        get { UserDefaults.standard.string(forKey: Keys.accessToken) }
    }

    private var refreshToken: String?
    {
        set { UserDefaults.standard.set(newValue, forKey: Keys.refreshToken) }
        get { UserDefaults.standard.string(forKey: Keys.refreshToken) }
    }

    private var tokenExpireDate: Date?
    {
        set { UserDefaults.standard.set(newValue, forKey: Keys.tokenExpireDate) }
        get { UserDefaults.standard.value(forKey: Keys.tokenExpireDate) as? Date }
    }

    func login(accessToken: String, refreshToken: String?, expireDate: Date?)
    {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpireDate = expireDate
    }

    func setCurrentUserInfo(_ userInfo: AppUserInfo)
    {
        currentUserInfo = userInfo
    }

    func getAccessToken(withUpdateAttempt: Bool, completion: @escaping (Result<String, LoginManagerError>) -> Void)
    {
        guard let token = accessToken
        else
        {
            delegate?.tokenInfoNotFound(.accessTokenNotFound)
            completion(.failure(.accessTokenNotFound))
            return
        }

        let expireDate = tokenExpireDate ?? Date()

        if expireDate > Date()
        {
            completion(.success(token))
        }
        else
        {
            guard withUpdateAttempt else
            {
                delegate?.tokenInfoNotFound(.tokenHasExpired)
                completion(.failure(.tokenHasExpired))
                return
            }

            updateToken
            { [weak self] _ in
                self?.getAccessToken(withUpdateAttempt: false, completion: completion)
            }
        }
    }

    private init() { }
}

extension LoginManager: LoginInfoProvider
{
    var userLogedIn: Bool
    {
        accessToken != nil
    }
}

extension LoginManager
{
    private func updateToken(completion: @escaping (Result<Void, LoginManagerError>) -> Void)
    {
        guard let refreshToken = refreshToken else
        {
            delegate?.tokenInfoNotFound(.refreshTokenNotFound)
            completion(.failure(.refreshTokenNotFound))
            return
        }

        LoginKit.shared.generateJWT(grantType: .refreshToken,
                                    clientId: AppConfig.loginClientId,
                                    refreshToken: refreshToken,
                                    clientSecret: nil,
                                    redirectUri: AppConfig.redirectURL,
                                    authCode: nil)
        { [weak self] result in
            switch result
            {
                case .success(let tokenInfo): do
                {
                    var tokenExpireDate: Date?
                    if let expiresIn = tokenInfo.expiresIn { tokenExpireDate = Date() + Double(expiresIn) }

                    self?.login(accessToken: tokenInfo.accessToken,
                                refreshToken: tokenInfo.refreshToken,
                                expireDate: tokenExpireDate)

                    completion(.success(()))
                }

                case .failure: do
                {
                    self?.delegate?.tokenInfoNotFound(.cannotUpdateToken)
                    completion(.failure(.cannotUpdateToken))
                }
            }
        }
    }
}

extension LoginManager
{
    enum Keys
    {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let tokenExpireDate = "tokenExpireDate"
    }
}
