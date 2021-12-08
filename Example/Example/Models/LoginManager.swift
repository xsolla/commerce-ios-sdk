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

typealias AccessToken = String
typealias LoginAuthCode = String
typealias RedirectUrlString = String
typealias RefreshToken = String

enum LoginManagerError: Error
{
    case expiredToken
    case tokenUpdateFailure
    case accessTokenNotFound
    case refreshTokenNotFound
    case invalidToken
}

protocol LoginInfoProvider
{
    var userLogedIn: Bool { get }
}

protocol AccessTokenProvider
{
    func getAccessToken(completion: @escaping (Result<AccessToken, LoginManagerError>) -> Void)
}

protocol LoginManagerProtocol: AnyObject, LoginInfoProvider
{
    var delegate: LoginManagerDelegate? { get set }

    func login(accessToken: AccessToken, refreshToken: RefreshToken?, expireDate: Date?, notifyDelegate: Bool)
    func login(tokenInfo: AccessTokenInfo, notifyDelegate: Bool)

    func logout()
}

extension LoginManagerProtocol
{
    func login(accessToken: AccessToken, refreshToken: RefreshToken?, expireDate: Date?, notifyDelegate: Bool = true)
    {
        login(accessToken: accessToken,
              refreshToken: refreshToken,
              expireDate: expireDate,
              notifyDelegate: notifyDelegate)
    }

    func login(tokenInfo: AccessTokenInfo, notifyDelegate: Bool = true)
    {
        login(accessToken: tokenInfo.accessToken,
              refreshToken: tokenInfo.refreshToken,
              expireDate: tokenInfo.expireDate,
              notifyDelegate: notifyDelegate)
    }
}

protocol LoginManagerDelegate: AnyObject
{
    func loginManager(_ loginManager: LoginManagerProtocol, didInvalidateAccessToken withError: LoginManagerError?)
    func loginManagerDidLogin(_ loginManager: LoginManagerProtocol)
}

/// WARNING!
/// We strongly recommend to avoid storing sensitive personal data, including various authorization tokens, in UserDefalts in your real application, keychain is best suited for this for security reasons. We intentionally use UserDefaults in the demo application, but don't do it in a real project!

class LoginManager: LoginManagerProtocol
{
    static let shared = LoginManager()

    weak var delegate: LoginManagerDelegate?

    func logout()
    {
        invalidateAccessToken(withError: nil)
    }

    private var accessToken: AccessToken?
    {
        set { UserDefaults.standard.set(newValue, forKey: Keys.accessToken) }
        get { UserDefaults.standard.string(forKey: Keys.accessToken) }
    }

    private var refreshToken: RefreshToken?
    {
        set { UserDefaults.standard.set(newValue, forKey: Keys.refreshToken) }
        get { UserDefaults.standard.string(forKey: Keys.refreshToken) }
    }

    private var tokenExpireDate: Date?
    {
        set { UserDefaults.standard.set(newValue, forKey: Keys.tokenExpireDate) }
        get { UserDefaults.standard.value(forKey: Keys.tokenExpireDate) as? Date }
    }

    func login(accessToken: AccessToken, refreshToken: RefreshToken?, expireDate: Date?, notifyDelegate: Bool)
    {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpireDate = expireDate

        if notifyDelegate { delegate?.loginManagerDidLogin(self) }
    }

    private func invalidateAccessToken(withError error: LoginManagerError?)
    {
        guard UserDefaults.standard.object(forKey: Keys.accessToken) != nil else { return }

        UserDefaults.standard.removeObject(forKey: Keys.accessToken)
        UserDefaults.standard.removeObject(forKey: Keys.refreshToken)
        UserDefaults.standard.removeObject(forKey: Keys.tokenExpireDate)

        delegate?.loginManager(self, didInvalidateAccessToken: error)
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
            invalidateAccessToken(withError: .refreshTokenNotFound)
            completion(.failure(.refreshTokenNotFound))
            return
        }
        
        let jwtParams = JWTGenerationParams(grantType: .refreshToken,
                                            clientId: AppConfig.oAuth2ClientId,
                                            refreshToken: refreshToken,
                                            clientSecret: nil,
                                            redirectUri: AppConfig.redirectUrl)

        LoginKit.shared.generateJWT(with: nil, jwtParams: jwtParams)
        { [weak self] result in

            guard let self = self else
            {
                completion(.failure(.tokenUpdateFailure))
                return
            }

            switch result
            {
                case .success(let tokenInfo): do
                {
                    var tokenExpireDate: Date?
                    if let expiresIn = tokenInfo.expiresIn { tokenExpireDate = Date() + Double(expiresIn) }

                    self.login(accessToken: tokenInfo.accessToken,
                               refreshToken: tokenInfo.refreshToken,
                               expireDate: tokenExpireDate,
                               notifyDelegate: false)

                    completion(.success(()))
                }

                case .failure: do
                {
                    self.invalidateAccessToken(withError: .tokenUpdateFailure)
                    completion(.failure(.tokenUpdateFailure))
                }
            }
        }
    }
    
    private func getAccessToken(withUpdateAttempt: Bool,
                                completion: @escaping (Result<AccessToken, LoginManagerError>) -> Void)
    {
        guard let token = accessToken
        else
        {
            invalidateAccessToken(withError: .accessTokenNotFound)
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
                invalidateAccessToken(withError: .expiredToken)
                completion(.failure(.expiredToken))
                return
            }

            updateToken
            { [weak self] _ in
                self?.getAccessToken(withUpdateAttempt: false, completion: completion)
            }
        }
    }
}

extension LoginManager: AccessTokenProvider
{
    func getAccessToken(completion: @escaping (Result<AccessToken, LoginManagerError>) -> Void)
    {
        getAccessToken(withUpdateAttempt: true, completion: completion)
    }
}

extension LoginManager: XsollaSDKAuthorizationErrorDelegate
{
    func xsollaSDK(_ xsollaSDK: XsollaSDK, didFailAuthorizationWithError error: Error)
    {
        switch error
        {
            case LoginKitError.invalidToken: invalidateAccessToken(withError: .invalidToken)
            
            default:  invalidateAccessToken(withError: nil)
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
