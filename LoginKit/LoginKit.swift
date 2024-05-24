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

// swiftlint:disable function_parameter_count
// swiftlint:disable line_length

import Foundation
import XsollaSDKUtilities
import UIKit

public typealias LoginOperationId = String

public final class LoginKit
{
    public static let shared = LoginKit(apiBasePath: "https://login.xsolla.com/api")

    public var authCodeExtractor: AuthCodeExtracting = AuthCodeExtractor()
    
    public var authTokenExtractor: AuthTokenExtracting = AuthTokenExtractor()

    private var api: LoginAPIProtocol
    private var modelFactory: ModelFactoryProtocol
    private var errorTranslator: ErrorTranslatorProtocol

    public init(apiBasePath: String)
    {
        let requestPerformer = XSDKNetwork(sessionConfiguration: XSDKNetwork.defaultSessionConfiguration)
        let responseProcessor = LoginAPIResponseProcessor()
        let api = LoginAPI(apiBasePath: apiBasePath, requestPerformer: requestPerformer, responseProcessor: responseProcessor)
        let modelFactory = LoginKitModelFactory()
        let errorTranslator = LoginKitErrorTranslator()

        self.api = api
        self.modelFactory = modelFactory
        self.errorTranslator = errorTranslator
    }
}

@available(iOS 13.4, *)
extension LoginKit
{

    /**
     Authenticates the user via a social network.

     - Parameters:
       - providerName: Name of the social network connected to Login in Publisher Account.
       Can have the following values: `amazon`, `apple`, `baidu`, `battlenet`, `discord`, `facebook`, `github`, `google`, `kakao`, `linkedin`, `mailru`, `microsoft`, `msn`, `naver`, `ok`, `paypal`, `psn`, `reddit`, `steam`, `twitch`, `twitter`, `vimeo`, `vk`, `wechat`, `weibo`, `yahoo`, `yandex`, `youtube`, `xbox`.
       If you store user data in [PlayFab](https://developers.xsolla.com/doc/login/how-to/users-storage-playfab), only `twitch` is available.
       - oAuth2Params: Instance of **OAuth2Params**.
       - jwtParams: Instance of **JWTGenerationParams**.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
     */
    public func authBySocialNetwork(_ providerName: String,
                                    oAuth2Params: OAuth2Params,
                                    jwtParams: JWTGenerationParams,
                                    presentationContextProvider: WebAuthenticationSession.PresentationContextProviding,
                                    completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        guard
            let redirectUri = oAuth2Params.redirectUri,
            let urlComponents = URLComponents(string: redirectUri),
            let callbackScheme = urlComponents.scheme,
            ["http", "https"].contains(callbackScheme) != true
        else
        {
            let error = LoginKitError.invalidRedirectUrl("Invalid callback URL in OAuth parameters")
            completion(.failure(error))
            return
        }

        getLinkForSocialAuth(providerName: providerName, oAuth2Params: oAuth2Params)
        { result in

            if case .failure(let error) = result { completion(.failure(error)) }

            if case .success(let url) = result
            {
                self.getAccessCodeFromWebAuthenticationSession(with: url,
                                                          callbackScheme: callbackScheme,
                                                          presentationContextProvider: presentationContextProvider)
                { result in

                    if case .failure(let error) = result { completion(.failure(error)) }

                    if case .success(let code) = result
                    {
                        self.generateJWT(with: code, jwtParams: jwtParams)
                        { result in
                            completion(result)
                        }
                    }
                }
            }
        }
    }
    
    /**
     Authenticates the user via xsolla widget.

     - Parameters:
       - loginProjectId: Login project ID from [Publisher Account](https://publisher.xsolla.com/).
       - oAuth2Params: Instance of **OAuth2Params**.
       - jwtParams: Instance of **JWTGenerationParams**.
       - locale: Login widget UI language. Supported languages: Arabic (ar_AE), Bulgarian (bg_BG), Czech (cz_CZ), Filipino (fil-PH), English (en_XX), German (de_DE), Spanish (es_ES), French (fr_FR), Hebrew (he_IL), Indonesian (id-ID), Italian (it_IT), Japanese (ja_JP), Khmer (km-KH), Korean (ko_KR), Lao language ( lo-LA), Myanmar (my-MM), NepaliPolish (ne-NP), (pl_PL), Portuguese (pt_BR), Romanian (ro_RO), Russian (ru_RU), Thai (th_TH), Turkish (tr_TR), Vietnamese (vi_VN), Chinese Simplified (zh_CN), Chinese Traditional (zh_TW).
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
     */
    public func authWithXsollaWidget(loginProjectId: String,
                                     oAuth2Params: OAuth2Params,
                                     jwtParams: JWTGenerationParams,
                                     locale: String? = nil,
                                     presentationContextProvider: WebAuthenticationSession.PresentationContextProviding,
                                     completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        guard
            let redirectUri = oAuth2Params.redirectUri,
            let urlComponents = URLComponents(string: redirectUri),
            let callbackScheme = urlComponents.scheme,
            ["http", "https"].contains(callbackScheme) != true
        else
        {
            let error = LoginKitError.invalidRedirectUrl("Invalid callback URL in OAuth parameters")
            completion(.failure(error))
            return
        }

        var stringUrl = "https://login-widget.xsolla.com/latest/?projectId=\(loginProjectId)&client_id=\(String(oAuth2Params.clientId))&response_type=\(oAuth2Params.responseType)&state=\(oAuth2Params.state)"
        
        if let locale = locale 
        {
            stringUrl += "&locale=\(locale)"
        }
        if let redirectUri = oAuth2Params.redirectUri
        {
            stringUrl += "&redirect_uri=\(redirectUri)"
        }
        if let scope = oAuth2Params.scope
        {
            stringUrl += "&scope=\(scope)"
        }
        
        let url = URL(string: stringUrl)
        
        getAccessCodeFromWebAuthenticationSession(with: url!,
                                                  callbackScheme: callbackScheme,
                                                  presentationContextProvider: presentationContextProvider)
        { result in

            if case .failure(let error) = result { completion(.failure(error)) }

            if case .success(let code) = result
            {
                self.getAccessToken(with: code, jwtParams: jwtParams, completion: completion)
            }
        }
    }

    func getAccessTokenFromWebAuthenticationSession(with url: URL,
                                                    callbackScheme: String,
                                                    presentationContextProvider: WebAuthenticationSession.PresentationContextProviding,
                                                    completion: @escaping (Result<String, Error>) -> Void)
    {
        startWebAuthenticationSession(with: url,
                                      callbackScheme: callbackScheme,
                                      presentationContextProvider: presentationContextProvider)
        { result in

            completion(self.authCodeExtractor.extract(from: result))
        }
    }

    func getAccessCodeFromWebAuthenticationSession(with url: URL,
                                                   callbackScheme: String,
                                                   presentationContextProvider: WebAuthenticationSession.PresentationContextProviding,
                                                   completion: @escaping (Result<String, Error>) -> Void)
    {
        startWebAuthenticationSession(with: url,
                                      callbackScheme: callbackScheme,
                                      presentationContextProvider: presentationContextProvider)
        { result in

            completion(self.authCodeExtractor.extract(from: result))
        }
    }

    func startWebAuthenticationSession(with url: URL,
                                       callbackScheme: String,
                                       presentationContextProvider: WebAuthenticationSession.PresentationContextProviding,
                                       completion: @escaping (Result<URL, Error>) -> Void)
    {

        let session = WebAuthenticationSession(url: url,
                                               callbackScheme: callbackScheme,
                                               presentationContextProvider: presentationContextProvider,
                                               completionHandler: completion)
        session.start()

    }
}

extension LoginKit
{

    /**
     Exchanges an authorization code to the JWT. The value of the authorization code is received from the redirect URL that should be passed in the `from` parameter.
     - Parameters
       - from: Mapped result. Should contain a redirect URL string in case of success and `Error` in case of failure.
       - jwtParams: Instance of **JWTGenerationParams**.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
    */
    func getAccessToken(from result: Result<String, Error>,
                        jwtParams: JWTGenerationParams,
                        completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        switch authCodeExtractor.extract(from: result)
        {
            case .failure(let error):
                completion(.failure(error))

            case .success(let code):
                getAccessToken(with: code, jwtParams: jwtParams, completion: completion)
        }
    }

    func getAccessToken(with code: String,
                        jwtParams: JWTGenerationParams,
                        completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        generateJWT(with: code, jwtParams: jwtParams)
        { result in
            completion(result)
        }
    }

    /**
     Logs the user out and deletes the user session according to the value of the sessions parameter. Call the `Check user authentication` method to see if the user is logged in.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - sessionType: Instance of **LogoutSessionType**.
       - completion: Completion with `Result`: Void on success and Error on failure.
     */
    public func logUserOut(accessToken: String, sessionType: LogoutSessionType, completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.logUserOut(accessToken: accessToken, sessionType: sessionType)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Authenticates the user by the specified username/email and password.
     To finish user authentication, get the user JWT by the `generateJWT` method.
     - Parameters:
       - username: Username or email address.
       - password: User password.
       - oAuth2Params: Instance of **OAuth2Params**.
       - jwtParams: Instance of **JWTGenerationParams**.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
    */
    public func authByUsernameAndPassword(username: String,
                                          password: String,
                                          oAuth2Params: OAuth2Params,
                                          jwtParams: JWTGenerationParams,
                                          completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        api.authByUsernameAndPassword(username: username, password: password, oAuth2Params: oAuth2Params)
        { [translator = errorTranslator] result in

            if case .failure(let error) = result { completion(.failure(translator.translateError(error))) }
            if case .success(let response) = result
            {
                self.getAccessToken(from: .success(response.loginUrl),
                                    jwtParams: jwtParams,
                                    completion: completion)
            }
        }
    }

    /**
     Gets the link for authentication via the social network. The link is valid for 10 minutes.
     You can get the link by this method and add it to your button for authentication via a social network.
     - Parameters:
       - providerName: Name of the social network connected to Login in Publisher Account.
         Can have the following values: `amazon`, `apple`, `baidu`, `battlenet`, `discord`, `facebook`, `github`, `google`, `kakao`, `linkedin`, `mailru`, `microsoft`, `msn`, `naver`, `o`*, `paypal`, `psn`, `reddit`, `steam`, `twitch`, `twitter`, `vimeo`, `vk`, `wechat`, `weibo`, `yahoo`, `yandex`, `youtube`, `xbox`.
         If you store user data in [PlayFab](https://developers.xsolla.com/doc/login/how-to/users-storage-playfab), only 'twitch' is available.
       - oAuth2Params: Instance of **OAuth2Params**.
       - completion: Completion with `Result`: URL string in case of success and `Error` in case of failure. URL string is URL for authentication via social network.
    */
    public func getLinkForSocialAuth(providerName: String,
                                     oAuth2Params: OAuth2Params,
                                     completion: @escaping (Result<URL, Error>) -> Void)
    {
        api.getLinkForSocialAuth(providerName: providerName,
                                 clientId: oAuth2Params.clientId,
                                 state: oAuth2Params.state,
                                 responseType: oAuth2Params.responseType,
                                 scope: oAuth2Params.scope,
                                 redirectUri: oAuth2Params.redirectUri)
        { [translator = errorTranslator] result in

            switch result
            {
                case .success(let responseModel): do
                {
                    guard let url = URL(string: responseModel.url)
                    else
                    {
                        completion(.failure(LoginKitError.failedURLExtraction))
                        return
                    }
                    completion(.success(url))
                }

                case .failure(let error): completion(.failure(translator.translateError(error)))
            }
        }
    }

    /**
     Authenticates the user with the access token using social network credentials.
     - Parameters:
       - oAuth2Params: Instance of **OAuth2Params**.
       - jwtParams: Instance of **JWTGenerationParams**.
       - providerName: "Name of the social network connected to Login in Publisher Account. Can have the following values: 'facebook', 'google', 'linkedin', 'twitter', 'discord', 'naver', 'baidu', and 'wechat'.
       - socialNetworkAccessToken: Access token received from a social network.
       - socialNetworkAccessTokenSecret: Secret token received from the authorization request. **Required** for Twitter only.
       - socialNetworkOpenId: ID received from a social network. **Required** for WeChat only.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
     */
    public func authBySocialNetwork(oAuth2Params: OAuth2Params,
                                    jwtParams: JWTGenerationParams,
                                    providerName: String,
                                    socialNetworkAccessToken: String,
                                    socialNetworkAccessTokenSecret: String?,
                                    socialNetworkOpenId: String?,
                                    completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        api.authBySocialNetwork(oAuth2Params: oAuth2Params,
                                providerName: providerName,
                                socialNetworkAccessToken: socialNetworkAccessToken,
                                socialNetworkAccessTokenSecret: socialNetworkAccessTokenSecret,
                                socialNetworkOpenId: socialNetworkOpenId)
        { [translator = errorTranslator] result in

            if case .failure(let error) = result { completion(.failure(translator.translateError(error))) }
            if case .success(let response) = result
            {
                self.getAccessToken(from: .success(response.loginUrl),
                                    jwtParams: jwtParams,
                                    completion: completion)
            }
        }
    }

    /**
     Unlinks social network from current user account.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - providerName: Social network for decoupling. **Required**. Can be `amazon`, `apple`, `baidu`, `battlenet`, `discord`, `facebook`, `github`, `google`, `instagram`, `kakao`, `linkedin`, `mailru`, `microsoft`, `msn`, `naver`, `ok`, `paradox`, `paypal`, `psn`, `qq`, `reddit`, `steam`, `twitch`, `twitter`, `vimeo`, `vk`, `wechat`, `weibo`, `yahoo`, `yandex`, `youtube`, `xbox`, `playstation`.
        - completion: Closure with `Result`: `Void` in case of success and `Error` in case of failure.
     */
    public func deleteLinkedNetwork(accessToken: String,
                                    providerName: String,
                                    completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.deleteLinkedNetwork(accessToken: accessToken, providerName: providerName)
        { [translator = errorTranslator] result in

            if case .failure(let error) = result { completion(.failure(translator.translateError(error))) }
            if case .success = result
            {
                completion(.success(()))
            }
        }
    }

    /**
     This method can be used in the following scripts:
     * To exchange the user authorization code for a JWT.
     * To refresh the JWT when it is expired if your application needs access to the Login API beyond the JWT expiration period. Works only if `scope=offline` in the registration or authentication method.
     * To get the server JWT without user participation.

     - Parameters:
       - authCode: User authorization code that will be exchanged to a JWT. **Required** if `grant_type=authorization_code`.
       - jwtParams: Instance of **JWTGenerationParams**.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
    */
    public func generateJWT(with authCode: String?,
                            jwtParams: JWTGenerationParams,
                            completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        api.generateJWT(with: authCode, jwtParams: jwtParams)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getAccessTokenInfo(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Creates a new user.
     * If you store user data at Xsolla side or in the custom storage, the user will receive an [account confirmation email](https://developers.xsolla.com/doc/login/how-to/email-customization/).
     * If you store user data at PlayFab, you can set up sending the account confirmation email to the user.
     [Use the PlayFab instruction](https://developers.xsolla.com/doc/login/references/playfab-storage/#recipes_users_storage_playfab_how_it_works_registration_confirmation) for this.

     [See Selecting a User Data Storage instruction](https://developers.xsolla.com/doc/login/references/users-storages-comparison/) for more information about user data storages.

     - Parameters:
       - params: Instance of **RegisterNewUserParams**.
       - oAuth2Params: Instance of **OAuth2Params**.
       - jwtParams: Instance of **JWTGenerationParams**.
       - locale: Language of the email being sent after this call in the `<language code>_<country code>` format. Xsolla standard texts localized in 20 languages. The following languages are supported: Arabic (ar_AE), Bulgarian (bg_BG), Czech (cz_CZ), English (en_XX), German (de_DE), Spanish (es_ES), French (fr_FR), Hebrew (he_IL), Italian (it_IT), Japanese (ja_JP), Korean (ko_KR), Polish (pl_PL), Portuguese (pt_BR), Romanian (ro_RO), Russian (ru_RU), Thai (th_TH), Turkish (tr_TR), Vietnamese (vi_VN), Chinese Simplified (zh_CN), Chinese Traditional (zh_TW). If you don’t pass the user’s locale, the language is determined from the IP address or the browser’s language.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
     */
    public func registerNewUser(params: RegisterNewUserParams,
                                oAuth2Params: OAuth2Params,
                                jwtParams: JWTGenerationParams,
                                locale: String? = nil,
                                completion: @escaping (Result<AccessTokenInfo?, Error>) -> Void)
    {
        api.registerNewUser(params: params, oAuth2Params: oAuth2Params, locale: locale)
        { [translator = errorTranslator] result in

            if case .success(let response) = result
            {
                if let urlString = response.loginUrl
                {
                    self.getAccessToken(from: .success(urlString), jwtParams: jwtParams)
                    { result in

                        completion(result.map { $0 })
                    }
                }
                else
                {
                    completion(.success(nil))
                }
            }

            if case .failure(let error) = result { completion(.failure(translator.translateError(error))) }
        }
    }

    /**
     Resets the user password with user confirmation.
     If the user data is kept in the Xsolla data storage or on your side, users receive a password change confirmation email.
     If the user data is kept in the PlayFab storage, password reset is done on the PlayFab side.
     To get more information, see the Selecting a user data storage instruction.

     The workflow of using this method:

     1. The application opens a form so the user can enter their email or username.
     2. The user enters their email or username.
     3. The application sends this request to the Xsolla Login server.
     4. The Xsolla Login server sends a confirmation email to the user.
     5. The user follows the link in the email and proceeds to the form for setting a new password.
     6. The user enters a new password and clicks Set new password.
     7. The application sends the Confirm password reset request to the Xsolla Login server.
     8. If you use your own password reset form, use the Confirm password reset method to reset the user password.

     - Parameters:
        - loginProjectId: Login project ID from [Publisher Account](https://publisher.xsolla.com/).
        - username: Email address to send the password change verification email to.
        - loginUrl: URL to redirect the user to after account confirmation, successful authentication, two-factor authentication configuration, or password reset confirmation. Must be identical to the **Callback URL** specified in **your Login project > General settings > URL** section of [Publisher Account](https://publisher.xsolla.com/). **Required** if there are several Callback URLs.
        - locale: Language of the email being sent after this call in the `<language code>_<country code>` format. Xsolla standard texts localized in 20 languages. The following languages are supported: Arabic (ar_AE), Bulgarian (bg_BG), Czech (cz_CZ), English (en_XX), German (de_DE), Spanish (es_ES), French (fr_FR), Hebrew (he_IL), Italian (it_IT), Japanese (ja_JP), Korean (ko_KR), Polish (pl_PL), Portuguese (pt_BR), Romanian (ro_RO), Russian (ru_RU), Thai (th_TH), Turkish (tr_TR), Vietnamese (vi_VN), Chinese Simplified (zh_CN), Chinese Traditional (zh_TW). If you don’t pass the user’s locale, the language is determined from the IP address or the browser’s language.
        - completion: Completion with `Result` without content.
    */
    public func resetPassword(loginProjectId: String,
                              username: String,
                              loginUrl: String?,
                              locale: String? = nil,
                              completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.resetPassword(loginProjectId: loginProjectId, username: username, loginUrl: loginUrl, locale: locale)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Starts user authentication via email and sends a confirmation code to the user email address. The code will be valid for 3 minutes.

     This method is called only with the `Complete auth by email` method.

     The workflow of using this method:

     1. The application opens an authentication form so the user can enter their email address.
     2. The user enters their email address.
     3. The application sends this request to the Xsolla Login server: a. If the parameter `send_link` is `true`, after this request, you should send the `Get confirmation code` request to make email contain the confirmation code and link. b. If the parameter `send_link` is `false` or not passed, the email will contain the confirmation code only.
     4. The Xsolla Login server sends the email and returns the ID of the confirmation code.
     5. The application shows a field so the user can fill in the confirmation code.
     6. The user enters the received confirmation code or follows the link.
     7. The application sends the `Complete auth by email` request with the received ID to the Xsolla Login server.
     8. The user is considered as authorized.

     - Parameters:
       - oAuth2Params: Instance of **OAuth2Params**.
       - email: User email address.
       - linkUrl: URL to redirect the user to the status authentication page. **Required** if the parameter `send_link` is `true`.
       - sendLink: Whether a link with the confirmation code is sent via email. The login link can be used instead of the confirmation code. If the parameter is `true`, the link is sent via email.
       - locale: Language of the email being sent after this call in the `<language code>_<country code>` format. Xsolla standard texts localized in 20 languages. The following languages are supported: Arabic (ar_AE), Bulgarian (bg_BG), Czech (cz_CZ), English (en_XX), German (de_DE), Spanish (es_ES), French (fr_FR), Hebrew (he_IL), Italian (it_IT), Japanese (ja_JP), Korean (ko_KR), Polish (pl_PL), Portuguese (pt_BR), Romanian (ro_RO), Russian (ru_RU), Thai (th_TH), Turkish (tr_TR), Vietnamese (vi_VN), Chinese Simplified (zh_CN), Chinese Traditional (zh_TW). If you don’t pass the user’s locale, the language is determined from the IP address or the browser’s language.
       - completion: Completion with `operationId` in case of success.
    */
    public func startAuthByEmail(oAuth2Params: OAuth2Params,
                                 email: String,
                                 linkUrl: String?,
                                 sendLink: Bool,
                                 locale: String? = nil,
                                 completion: @escaping (Result<LoginOperationId, Error>) -> Void)
    {
        api.startAuthByEmail(oAuth2Params: oAuth2Params,
                             email: email,
                             linkUrl: linkUrl,
                             sendLink: sendLink,
                             locale: locale)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0.operationId }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Completes user authentication via an email and a confirmation code.
     This method is called only with the `startAuthByEmail` method.

     The workflow of using this method:

     1. The application opens an authentication form so the user can enter their email address.
     2. The user enters their email address.
     3. The application sends the `startAuthByEmail` request to the Xsolla Login server.
     4. The Xsolla Login server sends an email to the user and returns the ID of the confirmation code.
     5. The application shows a field so the user can fill in the confirmation code.
     6. The user enters the received confirmation code.
     7. The application sends this request to the Xsolla Login server with the received ID.
     8. The user is considered as authorized.

     - Parameters:
       - clientId: Your application ID from [Publisher Account](https://publisher.xsolla.com/). You will get it after sending the request to enable the OAuth 2.0 protocol.
       - code: Сonfirmation code.
       - email: User email address.
       - operationId: ID of the confirmation code.
       - jwtParams: Instance of **JWTGenerationParams**.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
    */

    public func completeAuthByEmail(clientId: Int,
                                    code: String,
                                    email: String,
                                    operationId: LoginOperationId,
                                    jwtParams: JWTGenerationParams,
                                    completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        api.completeAuthByEmail(clientId: clientId, code: code, email: email, operationId: operationId)
        { [translator = errorTranslator] result in

            if case .failure(let error) = result { completion(.failure(translator.translateError(error))) }
            if case .success(let response) = result
            {
                self.getAccessToken(from: .success(response.loginURL),
                                    jwtParams: jwtParams,
                                    completion: completion)
            }
        }
    }

    /**
     Starts user authentication via a phone number and sends a confirmation code to the user phone number.
     This method is called only with the `completeAuthByPhone` method.

     The workflow of using this method:

     1. The application opens an authentication form so the user can enter their phone number.
     2. The user enters their phone number.
     3. The application sends this request to the Xsolla Login server.
     4. The Xsolla Login server sends a confirmation code to the phone number and returns the ID of the confirmation code.
     5. The application shows a field so the user can fill in the confirmation code.
     6. The user enters the received confirmation code.
     7. The application sends the `completeAuthByPhone` request with the received ID to the Xsolla Login server.
     8. The user is considered as authorized.

     - Parameters:
        - oAuth2Params: Instance of **OAuth2Params**.
        - phoneNumber: User phone number.
        - linkUrl: URL to redirect the user to the status authentication page. **Required** if the parameter `send_link` is `true`.
        - sendLink: Whether a link is sent with the confirmation code in the SMS. The link can be used instead of the confirmation code to log in. If the parameter is `true`, the link is sent in the SMS.
        - completion: Completion with `operationId` on success.
    */
    public func startAuthByPhone(oAuth2Params: OAuth2Params,
                                 phoneNumber: String,
                                 linkUrl: String?,
                                 sendLink: Bool,
                                 completion: @escaping (Result<LoginOperationId, Error>) -> Void)
    {
        api.startAuthByPhone(oAuth2Params: oAuth2Params, phoneNumber: phoneNumber, linkUrl: linkUrl, sendLink: sendLink)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0.operationId }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Completes user authentication via a phone number and a confirmation code.
     This method is called only with the `startAuthByPhone` method.

     The workflow of using this method:

     1. The application opens an authentication form so the user can enter their phone number.
     2. The user enters their phone number.
     3. The application sends the `startAuthByPhone` request to the Xsolla Login server.
     4. The Xsolla Login server sends a confirmation code to the phone number and returns the ID of the confirmation code.
     5. The application shows a field so the user can fill in the confirmation code.
     6. The user enters the received confirmation code.
     7. The application sends this request to the Xsolla Login server.
     8. The user is considered as authorized.

     - Parameters:
        - clientId: Your application ID from [Publisher Account](https://publisher.xsolla.com/).
          You will get it after sending the request to enable the OAuth 2.0 protocol.
        - code: Confirmation code.
        - phoneNumber]: User phone number.
        - operationId: ID of the confirmation code.
        - jwtParams: Instance of **JWTGenerationParams**.
        - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
    */
    public func completeAuthByPhone(clientId: Int,
                                    code: String,
                                    phoneNumber: String,
                                    operationId: LoginOperationId,
                                    jwtParams: JWTGenerationParams,
                                    completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        api.completeAuthByPhone(clientId: clientId, code: code, operationId: operationId, phoneNumber: phoneNumber)
        { [translator = errorTranslator] result in

            if case .failure(let error) = result { completion(.failure(translator.translateError(error))) }
            if case .success(let response) = result
            {
                self.getAccessToken(from: .success(response.loginURL),
                                    jwtParams: jwtParams,
                                    completion: completion)
            }
        }
    }

    /**
     Waits until the user follows the link provided via email or SMS and returns a confirmation code for authentication. If you send this request and don't get the code after 20 seconds, an error occurs. In this case, resend the request immediately. The lifetime of the code is 3 minutes.

     The workflow of using this method:

     1. The application opens an authentication form so the user can enter their email address.
     2. The user enters their email address.
     3. The application sends the `Start auth by email or phone number` (JWT or OAuth 2.0) request to the Xsolla Login server: a. If the parameter `send_link` is `true`, after this request, you should send this same request to make an email or SMS contain the confirmation code and link. b. If the parameter `send_link` is `false` or not passed, the email will contain the confirmation code only.
     4. The Xsolla Login server sends an email or SMS to the user and returns the ID of the confirmation code.
     5. The application shows a field so the user can fill in the confirmation code.
     6. The user enters the received confirmation code or follows the link.
     7. The application sends the `Complete auth by email or phone number` (JWT or OAuth 2.0) request with the received ID to the Xsolla Login server.
     8. The user is considered as authorized.
    */

    public func getConfirmationCode(projectId: String,
                                    login: String,
                                    operationId: LoginOperationId,
                                    completion: @escaping (Result<String, Error>) -> Void)
    {
        api.getConfirmationCode(projectId: projectId, login: login, operationId: operationId, completion: completion)
    }

    /**
     Authenticates a user via a specific device ID.
     - Parameters:
       - deviceId: Device ID. For iOS, it is an [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc) property.
       - device: Manufacturer and model name of the device.
       - oAuth2Params: Instance of **OAuth2Params**.
       - jwtParams: Instance of **JWTGenerationParams**.
       - completion: Completion with `Result`: `AccessTokenInfo` in case of success and `Error` in case of failure.
    */
    public func authWithDeviceId(deviceId: String,
                                 device: String,
                                 oAuth2Params: OAuth2Params,
                                 jwtParams: JWTGenerationParams,
                                 completion: @escaping (Result<AccessTokenInfo, Error>) -> Void)
    {
        api.authWithDeviceId(oAuth2Params: oAuth2Params, device: device, deviceId: deviceId)
        { [translator = errorTranslator] result in

            if case .failure(let error) = result { completion(.failure(translator.translateError(error))) }
            if case .success(let response) = result
            {
                self.getAccessToken(from: .success(response.loginURL),
                                    jwtParams: jwtParams,
                                    completion: completion)
            }
        }
    }
    /**
     Resends an account confirmation email to a user. To complete account confirmation, the user should follow the link in the email.
     - Parameters:
       - clientId: Your application ID. Get it after [creating an OAuth 2.0 client](https://developers.xsolla.com/doc/login/features/connecting-oauth2/).
       - redirectUri: URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation. Must be identical to the **Callback URL** specified in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **General settings** > **URL**. **Required** if there are several Callback URLs.
       - state: Value used for additional user verification. Often used to mitigate [CSRF Attacks](https://en.wikipedia.org/wiki/Cross-site_request_forgery). The value will be returned in the response. Must be longer than 8 characters.
       - username: Username or user email address.
       - locale: Language of the email being sent after this call in the `<language code>_<country code>` format. Xsolla standard texts localized in 20 languages. The following languages are supported: Arabic (ar_AE), Bulgarian (bg_BG), Czech (cz_CZ), English (en_XX), German (de_DE), Spanish (es_ES), French (fr_FR), Hebrew (he_IL), Italian (it_IT), Japanese (ja_JP), Korean (ko_KR), Polish (pl_PL), Portuguese (pt_BR), Romanian (ro_RO), Russian (ru_RU), Thai (th_TH), Turkish (tr_TR), Vietnamese (vi_VN), Chinese Simplified (zh_CN), Chinese Traditional (zh_TW). If you don’t pass the user’s locale, the language is determined from the IP address or the browser’s language.
       - completion: Completion void in case of success or error in case of failure.
    */
    public func resendConfirmationLink(clientId: Int,
                                       redirectUri: String,
                                       state: String,
                                       username: String,
                                       locale: String? = nil,
                                       completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.resendConfirmationLink(clientId: clientId, redirectUri: redirectUri, state: state, username: username, locale: locale)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets a list of user’s devices.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - completion: Completion with an array of `DeviceInfo` in case of success.
    */
    public func getUserDevices(accessToken: String, completion: @escaping (Result<[DeviceInfo], Error>) -> Void)
    {
        api.getUserDevices(accessToken: accessToken)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getDevicesInfo(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Links the specified device to the user account. To enable authentication via device ID and linking, contact your Account Manager.
     - Parameters:
       - device: Manufacturer and model name of the device.
       - deviceId: Device ID. For iOS, it is an [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc) property.
       - accessToken: Access token. By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         Alternatively, you can use the Pay Station access token.
         You can [generate your own token](https://developers.xsolla.com/pay-station-api/current/token/create-token).
       - completion: Completion with an empty response in case of success.
    */
    public func linkDeviceToAccount(device: String,
                                    deviceId: String,
                                    accessToken: String,
                                    completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.linkDeviceToAccount(device: device, deviceId: deviceId, accessToken: accessToken)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Unlinks the specified device from the user account. To enable authentication via device ID and unlinking, contact your Account Manager.
     - Parameters:
       - deviceId: Device ID. For iOS, it is an [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc) property.
       - accessToken: Access token. By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         Alternatively, you can use the Pay Station access token.
         You can [generate your own token](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui).
       - completion: Completion with an empty response in case of success.
    */
    public func unlinkDeviceFromAccount(deviceId: String,
                                        accessToken: String,
                                        completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.unlinkDeviceFromAccount(deviceId: deviceId, accessToken: accessToken)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Adds the username/email and password authentication to the existing user account. This method is called if the account is created via a device ID or phone number.
     - Parameters:
       - username: Username.
       - password: User password.
       - email: User email address.
       - promoEmailAgreement: User consent to receive the newsletter.
       - accessToken: Access token. By default, the Xsolla Login User JWT (Bearer token) is used for authorization. Alternatively, you can use the Pay Station access token. You can [generate your own token](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui).
           - redirectUri: URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation. Must be identical to the **Callback URL** specified in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **General settings** > **URL**. **Required** if there are several Callback URLs.
           - completion: Completion with information whether the user has to confirm the email address or not in case of success.
    */
    public func addUsernameAndPassword(username: String,
                                       password: String,
                                       email: String,
                                       promoEmailAgreement: Bool,
                                       accessToken: String,
                                       redirectUri: String?,
                                       completion: @escaping ((Result<Bool, Error>) -> Void))
    {
        api.addUsernameAndPassword(accessToken: accessToken,
                                   username: username,
                                   password: password,
                                   email: email,
                                   promoEmailAgreement: promoEmailAgreement,
                                   redirectUri: redirectUri)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0.emailConfirmationRequired }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Creates the code for linking the `platform account` to the existing `main account` when the user logs in to the game via a gaming console.
     The call is used with the `Link accounts by code request` method.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: Completion with `Result`: `Code` on success and Error on failure.
     */
    public func createCodeForLinkingAccounts(accessToken: String,
                                             completion: @escaping (Result<String, Error>) -> Void)
    {
        api.createCodeForLinkingAccounts(accessToken: accessToken)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0 }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets the user information from their public profile by user ID.
     - Parameters:
       - userId: User ID. You can find it in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **Users**.
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: Instance of `UserPublicProfile` on success.
     */
    public func getUserPublicProfile(userId: String,
                                     accessToken: String,
                                     completion: @escaping (Result<UserPublicProfile, Error>) -> Void)
    {
        api.getUserPublicProfile(userId: userId, accessToken: accessToken)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getUserPublicProfile(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets details of the user authenticated by the JWT.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: Instance of **LoginUserDetails** on success.
    */
    public func getCurrentUserDetails(accessToken: String,
                                      completion: @escaping (Result<UserProfileDetails, Error>) -> Void)
    {
        api.getCurrentUserDetails(accessToken: accessToken)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getUserProfileDetails(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Updates the details of the authenticated user by the JWT.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: Instance of **LoginUserDetails** in case of success.
    */
    public func updateCurrentUserDetails(accessToken: String,
                                         birthday: Date? = nil,
                                         firstName: String? = nil,
                                         lastName: String? = nil,
                                         nickname: String? = nil,
                                         gender: UserProfileDetails.Gender? = nil,
                                         completion: @escaping (Result<UserProfileDetails, Error>) -> Void)
    {
        var birthdayString: String?
        if let birthday = birthday
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            birthdayString = dateFormatter.string(from: birthday)
        }

        api.updateCurrentUserDetails(accessToken: accessToken,
                                     birthday: birthdayString,
                                     firstName: firstName,
                                     lastName: lastName,
                                     gender: gender?.rawValue,
                                     nickname: nickname)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getUserProfileDetails(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets the email of the authenticated user by the JWT.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: User's email in case of success.
    */
    public func getUserEmail(accessToken: String,
                             completion: @escaping (Result<String?, Error>) -> Void)
    {
        api.getUserEmail(accessToken: accessToken)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0.currentEmail }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Deletes the profile picture of the authenticated user by the JWT.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: Empty response in case of success.
    */
    public func deleteUserPicture(accessToken: String, completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.deleteUserPicture(accessToken: accessToken)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Uploads the profile picture of the authenticated user by the JWT.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - imageURL: URL of a picture to be uploaded.
       - completion: Picture link in case of success.
    */
    public func uploadUserPicture(accessToken: String,
                                  imageURL: URL,
                                  completion: @escaping (Result<String, Error>) -> Void)
    {
        api.uploadUserPicture(accessToken: accessToken, imageURL: imageURL)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0.picture }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets the phone number of the authenticated user by the JWT.
     The phone number in this method is used only for passing two-factor authentication.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: Empty response in case of success.
    */
    public func getCurrentUserPhone(accessToken: String,
                                    completion: @escaping (Result<String?, Error>) -> Void)
    {
        api.getCurrentUserPhone(accessToken: accessToken)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0.phoneNumber }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Updates the phone number of the authenticated user by the JWT.
     The phone number in this method is used only for passing two-factor authentication.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - phoneNumber: Updated user phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers)
       - completion: User phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers) in case of success.
    */
    public func updateCurrentUserPhone(accessToken: String,
                                       phoneNumber: String,
                                       completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.updateCurrentUserPhone(accessToken: accessToken, phoneNumber: phoneNumber)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Deletes the phone number of the authenticated user by the JWT.
     The phone number in this method is used only for passing two-factor authentication.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - phoneNumber: User phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers)
       - completion: Empty response in case of success.
    */
    public func deleteCurrentUserPhone(accessToken: String,
                                       phoneNumber: String,
                                       completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.deleteCurrentUserPhone(accessToken: accessToken, phoneNumber: phoneNumber)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets a list of users added as friends of the authenticated user.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - listType: Friend list type parameter.
       - sortType: Parameter that is used for sorting.
       - sortOrderType: Sorting order parameter.
       - after: Parameter that is used for API pagination.
       - limit: Limit of the result.
       - completion: Instance of **FriendsList** in case of success.
    */
    public func getCurrentUserFriends(accessToken: String,
                                      listType: FriendsListType,
                                      sortType: FriendsListSortType,
                                      sortOrderType: FriendsListOrderType,
                                      after: String?,
                                      limit: Int? = nil,
                                      completion: @escaping (Result<FriendsList, Error>) -> Void)
    {
        api.getCurrentUserFriends(accessToken: accessToken,
                                  listType: listType.rawValue,
                                  sortType: sortType.rawValue,
                                  sortOrder: sortOrderType.rawValue,
                                  after: after,
                                  limit: limit)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getFriendsList(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Updates the friend list of the authenticated user.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - after: Parameter that is used for API pagination.
       - actionType: Type of the friend list updating action.
       - userID: ID of the user to change relationships with.
       - completion: Empty response in case of success.
    */
    public func updateCurrentUserFriends(accessToken: String,
                                         actionType: FriendsListUpdateAction,
                                         userID: String,
                                         completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.updateCurrentUserFriends(accessToken: accessToken,
                                     action: actionType.rawValue,
                                     userID: userID)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets links for authentication via the social networks enabled in **your Login project > General settings > Social Networks** section of `Publisher Account`. The links are valid for 10 minutes.

     You can get the link by this call and add it to your button for authentication via a social network.

     - Parameters:
     - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
     - locale: Region in the `<language code>_<country code>` format, where:
       * `language code`: language code in the [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) format;
       * `country code`: country/region code in the [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) format.
       The list of the links will be sorted from most to least used social networks according to the variable value.
     - completion: Instance of **LinksForSocialAuth** in case of success and Error in case of failure.
     */
    public func getLinksForSocialAuth(accessToken: String,
                                      locale: String?,
                                      completion: @escaping (Result<LinksForSocialAuth, Error>) -> Void)
    {
        api.getLinksForSocialAuth(accessToken: accessToken, locale: locale)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getLinksForSocialAuth(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Updates the friend list of the authenticated user.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - completion: Array of `UserSocialNetworkInfo` in case of success.
    */
    public func getLinkedNetworks(accessToken: String,
                                  completion: @escaping (Result<[UserSocialNetworkInfo], Error>) -> Void)
    {
        api.getLinkedNetworks(accessToken: accessToken)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getUserSocialNetworkInfos(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets the URL to link the social network to the user account. The social network should be used for authentication.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - providerName: Name of the social network connected to Login in Publisher Account.
         Can be: *amazon*, *apple*, *baidu*, *battlenet*, *discord*, *facebook*, *github*, *google*, *kakao*, *linkedin*,
         *mailru*, *microsoft*, *msn*, *naver*, *ok*, *paypal*, *psn*, *reddit*, *steam*, *twitch*, *twitter*, *vimeo*, *vk*,
         *wechat*, *weibo*, *yahoo*, *yandex*, *youtube*, *xbox*.
       - loginURL: URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation. Must be identical to the **Callback URL** specified in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **General settings** > **URL**. **Required** if there are several Callback URLs.
       - completion: URL used for authenticating the user via the social network in case of success.
    */

    public func getURLToLinkSocialNetworkToAccount(accessToken: String,
                                                   providerName: String,
                                                   loginURL: String,
                                                   completion: @escaping (Result<String, Error>) -> Void)
    {
        api.getURLToLinkSocialNetworkToAccount(accessToken: accessToken, providerName: providerName, loginURL: loginURL)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0.url }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets a list of user friends from a social provider.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - platform: Name of the chosen social provider which you can enable in your [Publisher Account](https://publisher.xsolla.com/) > your Login project > **Social connections**.
         If you do not specify it, the method gets friends from all social providers.
       - offset: Number of the elements from which the list is generated.
       - limit: Maximum number of friends that are returned at a time.
       - withLoginId: Whether the social friends are from your game.
       - completion: Instance of **SocialNetworkFriendsList** in case of success.
    */
    public func getSocialNetworkFriends(accessToken: String,
                                        platform: String,
                                        offset: Int,
                                        limit: Int,
                                        withLoginId: Bool,
                                        completion: @escaping (Result<SocialNetworkFriendsList, Error>) -> Void)
    {
        api.getSocialNetworkFriends(accessToken: accessToken,
                                    platform: platform,
                                    offset: offset,
                                    limit: limit,
                                    withLoginId: withLoginId)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getSocialNetworkFriendsList(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Begins data processing to update a list of user’s friends from a social provider.
     Note that there may be a delay in data processing because of the Xsolla Login server or provider server high loads.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - platform: Name of the chosen social provider which you can enable in your [Publisher Account](https://publisher.xsolla.com/) > your Login project > **Social connections**.
         If you do not specify it, the method gets friends from all social providers.
       - completion: Empty result in case of success.
    */
    public func updateSocialNetworkFriends(accessToken: String,
                                           platform: String,
                                           completion: @escaping (Result<Void, Error>) -> Void)
    {
        api.updateSocialNetworkFriends(accessToken: accessToken, platform: platform)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Searches users by the `nickname` parameter and gets a list of them. Search can be performed instantly when the user starts entering the search parameter.

     The workflow of using this call:

     1. The user enters a nickname or tag, or nickname and tag.
     2. The Xsolla Login server searches for users in the Login project data of the user who initiated a search.

     The current user can execute this call only one time per second.

     - Parameters:
       - nickname: The search string that may contain:
         * nickname only. Search is performed by substring at the beginning of the nickname.
         * tag only, is used with \"#\" at the beginning. Search is performed by substring at the beginning of the tag.
         * nickname and tag together, is used with \"#\" and without space. Search is performed by full nickname and substring at the beginning of the tag.
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - offset: Number of the elements from which the list is generated.
       - limit: Maximum number of users that are returned at a time.
       - completion: Completion with `Result`: **SearchUsersByNicknameResult** in case of success and Error in case of failure.
     */
    public func searchUsersByNickname(nickname: String,
                                      accessToken: String,
                                      offset: Int?,
                                      limit: Int?,
                                      completion: @escaping (Result<SearchUsersByNicknameResult, Error>) -> Void)
    {
        api.searchUsersByNickname(nickname: nickname, accessToken: accessToken, offset: offset, limit: limit)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getSearchUsersByNicknameResult(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    // MARK: - User Attributes

    /**
     Gets a list of particular users attributes. Returns only attributes with the `client` value of the `attr_type` parameter.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - keys: List of attributes’ keys which you want to get. If you do not specify them, it returns all user attributes.
       - publisherProjectId: Project ID from Publisher Account which you want to get attributes for.
         If you do not specify it, it returns attributes without the value of this parameter.
       - userId: User ID which attributes you want to get. Returns only attributes with the `public` value of the `permission` parameter.
         If you do not specify it or put your user ID there, it returns only your attributes with any value for the `permission` parameter.
        - completion: Array of `UserAttribute` in case of success.
    */
    public func getClientUserAttributes(accessToken: String,
                                        keys: [String]?,
                                        publisherProjectId: Int?,
                                        userId: String?,
                                        completion: @escaping (Result<[UserAttribute], Error>) -> Void)
    {
        api.getClientUserAttributes(accessToken: accessToken,
                                    keys: keys,
                                    publisherProjectId: publisherProjectId,
                                    userId: userId)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getUserAttributes(response: $0) }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Gets a list of particular user read-only attributes. Returns only attributes with the `client` value of the `attr_type` parameter which was set only for reading.
     - Parameters:
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - keys: List of attributes’ keys which you want to get. If you do not specify them, it returns all user’s attributes.
       - publisherProjectId: Project ID from Publisher Account which you want to get attributes for.
         If you do not specify it, it returns attributes without the value of this parameter.
       - userId: User ID which attributes you want to get. Returns only attributes with the `public` value of the `permission` parameter.
         If you do not specify it or put your user ID there, it returns only your attributes with any value for the `permission` parameter.
       - completion: Array of `UserAttribute` in case of success.
    */
    public func getClientUserReadOnlyAttributes(accessToken: String,
                                                keys: [String]?,
                                                publisherProjectId: Int?,
                                                userId: String?,
                                                completion: @escaping (Result<[UserAttribute], Error>) -> Void)
    {
        api.getClientUserReadOnlyAttributes(accessToken: accessToken,
                                            keys: keys,
                                            publisherProjectId: publisherProjectId,
                                            userId: userId)
        { [factory = modelFactory, translator = errorTranslator] result in

            completion(result
                .map { factory.getUserAttributes(response: $0) }
                .mapError { translator.translateError($0) }
            )

            switch result
            {
                case .success(let response): completion(.success(response.map { UserAttribute(fromResponse: $0) }))
                case .failure(let error): completion(.failure(translator.translateError(error)))
            }
        }
    }

    /**
     Updates and creates particular user attributes.
     - Parameters:
        - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
        - attributes: List of attributes of the specified game.
          To add an attribute that does not exist, set this attribute to the `key` parameter.
          To update `value` of the attribute, specify its `key` parameter and set new `value`.
          You can change several attributes at a time.
        - publisherProjectId: Project ID from Publisher Account which you want to get attributes for.
          If you do not specify it, it returns attributes without the value of this parameter.
        - removingKeys: List of attributes which you want to delete. If you specify the same attribute in `attributes` parameter, it will not be deleted.
        - completion: Empty response in case of success.
    */
    public func updateClientUserAttributes(accessToken: String,
                                           attributes: [UserAttribute]?,
                                           publisherProjectId: Int?,
                                           removingKeys: [String]?,
                                           completion: @escaping (Result<Void, Error>) -> Void)
    {
        let requestUserAttributes = attributes?.map
        {
            UpdateClientUserAttributesRequest.Body.Attribute(key: $0.key, permission: $0.permission, value: $0.value)
        }

        api.updateClientUserAttributes(accessToken: accessToken,
                                       attributes: requestUserAttributes,
                                       publisherProjectId: publisherProjectId,
                                       removingKeys: removingKeys)
        { [translator = errorTranslator] result in

            completion(result
                .map { _ in () }
                .mapError { translator.translateError($0) }
            )
        }
    }

    /**
     Checks user’s age for a particular region. The age requirements depend on the region. Service determines the user’s location by the IP address.
     - Parameters:
       - birthday: User’s birth date in the `YYYY-MM-DD` format.
       - accessToken: User JWT obtained during authorization using Xsolla Login ([Bearer token](https://developers.xsolla.com/api/login/overview/#section/Authentication/Getting-a-user-token)). **Required**.
       - loginProjectId: Login ID from Publisher Account.
       - completion: Completion with `Result`: Boolean value `accepted`, shows whether the user reached the required age or not in case of success, Error in case of failure.
     */
    public func checkUserAge(birthday: String,
                             accessToken: String,
                             loginId: String,
                             completion: @escaping (Result<Bool, Error>) -> Void)
    {
        api.checkUserAge(birthday: birthday, accessToken: accessToken, loginId: loginId)
        { [translator = errorTranslator] result in

            completion(result
                .map { $0 }
                .mapError { translator.translateError($0) }
            )
        }
    }
}
