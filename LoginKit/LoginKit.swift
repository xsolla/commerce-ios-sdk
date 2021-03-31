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

import Foundation
import XsollaSDKUtilities

public typealias LoginKitResult<T> = Result<T, Error>
public typealias LoginKitCompletion<T> = (LoginKitResult<T>) -> Void

public final class LoginKit
{
    public static let shared = LoginKit()

    private var api: LoginAPIProtocol

    convenience init()
    {
        let requestPerformer = XSDKNetwork(sessionConfiguration: XSDKNetwork.defaultSessionConfiguration)
        let responseProcessor = LoginAPIResponseProcessor()
        let api = LoginAPI(requestPerformer: requestPerformer, responseProcessor: responseProcessor)

        self.init(api: api)
    }

    init(api: LoginAPIProtocol)
    {
        self.api = api
    }
}

extension LoginKit
{
    /**
     Authenticates the user by the username/email and password specified.
     To finish user authentication, get the user JWT by sending the **Generate JWT** request.
     - Parameters:
        - username: Username/email
        - password: Password
        - oAuth2Params: Instance of **OAuth2Params**
        - completion: Completion with `Result`: URL string on success and Error on failure.
        URL string generated from **redirectUri** of **OAuth2Params** with additional parameters.
        The **code** parameter is the user authentication code which must be exchanged to JWT
    */
    public func authByUsernameAndPassword(username: String,
                                          password: String,
                                          oAuth2Params: OAuth2Params,
                                          completion: @escaping LoginKitCompletion<String>)
    {
        api.authByUsernameAndPassword(username: username, password: password, oAuth2Params: oAuth2Params)
        { result in

            switch result
            {
                case .success(let response): completion(.success(response.loginUrl))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Authenticates the user by the username/email and password and returns a JWT.
     Exchanging the code to a JWT via the **Generate JWT** method isn't needed.
     - Parameters:
        - username: Username/email.
        - password: Password.
        - clientId: Your application ID from [Publisher Account](https://publisher.xsolla.com/).
     You will get it after sending the request to enable the OAuth 2.0 protocol.
        - scope: Scope is a mechanism in OAuth 2.0 to limit an application's access to a user's account.
        Can be:
            * **email** for [Auth via social network](https://developers.xsolla.com/login-api/oauth-20/oauth-20-auth-via-social-network)
            or [Get link for social auth](https://developers.xsolla.com/login-api/oauth-20/oauth-20-get-link-for-social-auth)
            methods to request an email from the user additionally.
            * **offline** to use `refresh_token` from [Generate JWT](https://developers.xsolla.com/login-api/oauth-20/generate-jwt)
            method to refresh the JWT when it is expired.
            * **playfab** to write SessionTicket to the session_ticket claim of the JWT if you store user data on the PlayFab side.
            If you process your own values of the **scope** parameter, and the values aren't mentioned above, you can set them when using this method.
        - completion: Completion with `AuthInfo` on success and Error on failure.
     */
    public func authByUsernameAndPasswordJWT(username: String,
                                             password: String,
                                             clientId: Int,
                                             scope: String?,
                                             completion: @escaping LoginKitCompletion<AccessTokenInfo>)
    {
        api.authByUsernameAndPasswordJWT(username: username, password: password, clientId: clientId, scope: scope)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let authInfo = AccessTokenInfo(accessToken: responseModel.accessToken,
                                                   expiresIn: responseModel.expiresIn,
                                                   refreshToken: responseModel.refreshToken,
                                                   tokenType: responseModel.tokenType)
                    completion(.success(authInfo))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets the link for authentication via the social network. The link is valid for 10 minutes.
     You can get the link by this method and add it to your button for authentication via a social network.
     - Parameters:
        - providerName: Name of the social network connected to Login in Publisher Account.
        Can be: *amazon*, *apple*, *baidu*, *battlenet*, *discord*, *facebook*, *github*, *google*, *kakao*, *linkedin*,
     *mailru*, *microsoft*, *msn*, *naver*, *ok*, *paypal*, *psn*, *reddit*, *steam*, *twitch*, *twitter*, *vimeo*, *vk*,
     *wechat*, *weibo*, *yahoo*, *yandex*, *youtube*, *xbox*.
     If you store user data in [PlayFab](https://developers.xsolla.com/doc/login/how-to/users-storage-playfab),
     only 'twitch' is available.
        - oauth2params: Instance of **OAuth2Params**
        - completion: Completion with `Result`: URL string on success and Error on failure. URL string is URL for authentication via social network.
     */
    public func getLinkForSocialAuth(providerName: String,
                                     oauth2params: OAuth2Params,
                                     completion: @escaping LoginKitCompletion<URL>)
    {
        api.getLinkForSocialAuth(providerName: providerName,
                                 clientId: oauth2params.clientId,
                                 state: oauth2params.state,
                                 responseType: oauth2params.responseType,
                                 scope: oauth2params.scope,
                                 redirectUri: oauth2params.redirectUri)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    guard let url = URL(string: responseModel.url)
                    else
                    {
                        completion(.failure(LoginKitError.cannotParseURLFromResponse))
                        return
                    }
                    completion(.success(url))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Authenticates the user with the access token using social network credentials.
     - Parameters:
        - oAuth2Params: Instance of **OAuth2Params**
        - providerName: "Name of the social network connected to Login in Publisher Account. Can have the following values:
     'facebook', 'google', 'linkedin', 'twitter', 'discord', 'naver', 'baidu', and 'wechat'.
        - socialNetworkAccessToken: Access token received from a social network.
        - socialNetworkAccessTokenSecret: Secret token received from the authorization request. Required for Twitter only.
        - socialNetworkOpenId: ID received from a social network. Required for WeChat only.
        - completion: Completion with `Result`: URL string on success and Error on failure.
     URL string generated from **redirectUri** of **OAuth2Params** with additional parameters.
     The **code** parameter is the user authentication code which must be exchanged for a JWT.
     */
    public func authBySocialNetwork(oAuth2Params: OAuth2Params,
                                    providerName: String,
                                    socialNetworkAccessToken: String,
                                    socialNetworkAccessTokenSecret: String?,
                                    socialNetworkOpenId: String?,
                                    completion: @escaping LoginKitCompletion<String>)
    {
        api.authBySocialNetwork(oAuth2Params: oAuth2Params,
                                providerName: providerName,
                                socialNetworkAccessToken: socialNetworkAccessToken,
                                socialNetworkAccessTokenSecret: socialNetworkAccessTokenSecret,
                                socialNetworkOpenId: socialNetworkOpenId)
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel.loginUrl))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     This method can be used in the following scripts:
    * To exchange the user authentication code for a JWT.
    * To refresh the JWT when it is expired if your application needs access to the Login API beyond the JWT expiration period.
     Works only if scope=offline in the registration or authentication method.
    * To get the server JWT without user participation.
     - Parameters:
        - grantType: The type of getting the JWT. Can be:
            * **authorization_code** to exchange the code received in the [method](https://developers.xsolla.com/login-api/methods/oauth-20/oauth-20-auth-by-username-and-password/) to JWT
            The value of the `authCode` parameter must be specified.
            * **refresh_token** to get the refreshed JWT when the previous value is expired. The value of the `refreshToken` parameter must be specified.
            * **client_credentials** to get the server JWT without user participation, the values of the `clientId` and `clientSecret` parameters must be specified.
        - clientId: Your application ID from [Publisher Account](https://publisher.xsolla.com/).
            You will get it after sending the request to enable the OAuth 2.0 protocol.
        - refreshToken: The `refreshToken` value received in the response to the last call of this method. Required if `grant_type=refresh_token`.
        - clientSecret: Your secret key hashed according to the [bcrypt](https://en.wikipedia.org/wiki/Bcrypt) algorithm.
            You got it after sending the request to enable OAuth 2.0. To get your secret key again, contact your Account Manager.
        - redirectUri: URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation.
            To set up this parameter, contact your Account Manager.
        - authCode: User authentication code that will be exchanged to a JWT. Required if `grant_type=authorization_code`.
        - completion: Completion with `AuthInfo` on success and Error on failure.
     */
    public func generateJWT(grantType: TokenGrantType,
                            clientId: Int,
                            refreshToken: String?,
                            clientSecret: String?,
                            redirectUri: String?,
                            authCode: String?,
                            completion: @escaping LoginKitCompletion<AccessTokenInfo>)
    {
        api.generateJWT(grantType: grantType.rawValue,
                        clientId: clientId,
                        refreshToken: refreshToken,
                        clientSecret: clientSecret,
                        redirectUri: redirectUri,
                        authCode: authCode)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let authInfo = AccessTokenInfo(accessToken: responseModel.accessToken,
                                                   expiresIn: responseModel.expiresIn,
                                                   refreshToken: responseModel.refreshToken,
                                                   tokenType: responseModel.tokenType)
                    completion(.success(authInfo))
                }

                case .failure(let error):
                    completion(.failure(error.processed))
            }
        }
    }

    /**
     Creates a new user.
     * If you store user data on the Xsolla side or in the custom storage, the user will receive an account confirmation [email](https://developers.xsolla.com/doc/login/how-to/email-customization/).
     * If you store user data on the PlayFab side, you can set up sending the account confirmation email to the user.
     Use the [PlayFab instruction](https://developers.xsolla.com/doc/login/how-to/users-storage-playfab/#recipes_users_storage_playfab_how_it_works_registration_confirmation/) for this.

     See [Selecting a User Data Storage instruction](https://developers.xsolla.com/doc/login/features/users-storage/) for more information about user data storages.

     - Parameters:
        - oAuth2Params: Instance of **OAuth2Params**.
        - username: Username.
        - password: Password.
        - email: Email.
        - acceptConsent: Whether the user gave consent to processing of their personal data.
        - fields: Parameters for advanced user registration. To use this feature, contact your Account Manager.
        - promoEmailAgreement: User's consent to receive the newsletter.
        - completion: Completion with `Result`: URL string on success and Error on failure.
            URL string generated from **redirectUri** of **OAuth2Params** with additional parameters.
            The **code** parameter is the user authentication code which must be exchanged for a JWT.
     */
    public func registerNewUser(oAuth2Params: OAuth2Params,
                                username: String,
                                password: String,
                                email: String,
                                acceptConsent: Bool?,
                                fields: [String: String]?,
                                promoEmailAgreement: Int?,
                                completion: @escaping LoginKitCompletion<URL?>)
    {
        api.registerNewUser(oAuth2Params: oAuth2Params,
                            username: username,
                            password: password,
                            email: email,
                            acceptConsent: acceptConsent,
                            fields: fields,
                            promoEmailAgreement: promoEmailAgreement)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    if let urlString = responseModel.loginUrl, let url = URL(string: urlString)
                    {
                        completion(.success(url))
                    }
                    else
                    {
                        completion(.success(nil))
                    }
                }

                case .failure(let error): completion(.failure(error.processed))
            }
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
        - username: Email to send the password change verification message to.
        - loginUrl: URL to redirect the user to after account confirmation, successful authentication, two-factor authentication configuration, or password reset confirmation.
     Must be identical to the **Callback URL** specified in **your Login project > General settings > URL** section of [Publisher Account](https://publisher.xsolla.com/).
     Required if there are several Callback URLs.
        - completion: Completion with `Result` without content.
     */
    public func resetPassword(loginProjectId: String,
                              username: String,
                              loginUrl: String?,
                              completion: @escaping LoginKitCompletion<Void>)
    {
        api.resetPassword(loginProjectId: loginProjectId, username: username, loginUrl: loginUrl)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets details of the user authenticated by the JWT.
     - Parameters:
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
     You can use the Pay Station Access Token as an alternative.
     You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - completion: Instance of `LoginUserDetails` on success.
     */
    public func getCurrentUserDetails(accessToken: String,
                                      completion: @escaping LoginKitCompletion<LoginUserDetails>)
    {
        api.getCurrentUserDetails(accessToken: accessToken)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let userDetails = LoginUserDetails(fromGetCurrentUserDetailsResponse: responseModel)
                    completion(.success(userDetails))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }
}

private extension Error
{
    var processed: Error
    {
        if case .parameters(_, let model) = self as? APIError<LoginAPIErrorModel>
        {
            return LoginKitError(code: model?.code) ?? self
        }

        return self
    }
}

public enum LoginKitError: Error
{
    case cannotParseURLFromResponse

    internal init?(code: Int?)
    {
        switch code
        {
            default: return nil
        }
    }
}
