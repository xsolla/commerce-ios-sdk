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
       - clientId: Your application ID from [Publisher Account](https://publisher.xsolla.com/). You will get it after sending the request to enable the OAuth 2.0 protocol.
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
         Can be: *amazon*, *apple*, *baidu*, *battlenet*, *discord*, *facebook*, *github*, *google*, *kakao*, *linkedin*, *mailru*, *microsoft*, *msn*, *naver*, *ok*, *paypal*, *psn*, *reddit*, *steam*, *twitch*, *twitter*, *vimeo*, *vk*, *wechat*, *weibo*, *yahoo*, *yandex*, *youtube*, *xbox*.
         If you store user data in [PlayFab](https://developers.xsolla.com/doc/login/how-to/users-storage-playfab), only 'twitch' is available.
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
                        completion(.failure(LoginKitError.failedURLExtraction))
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
       - providerName: "Name of the social network connected to Login in Publisher Account. Can have the following values: 'facebook', 'google', 'linkedin', 'twitter', 'discord', 'naver', 'baidu', and 'wechat'.
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
     * To refresh the JWT when it is expired if your application needs access to the Login API beyond the JWT expiration period. Works only if scope=offline in the registration or authentication method.
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
        - loginUrl: URL to redirect the user to after account confirmation, successful authentication, two-factor authentication configuration, or password reset confirmation. Must be identical to the **Callback URL** specified in **your Login project > General settings > URL** section of [Publisher Account](https://publisher.xsolla.com/). Required if there are several Callback URLs.
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
       - oAuth2Params: Instance of `OAuth2Params`.
       - email: User email address.
       - linkUrl: URL to redirect the user to the status authentication page. **Required** if the parameter `send_link` is `true`.
       - sendLink: Whether a link is sent in an email with the confirmation code. The link can be used instead of the confirmation code to log in. If the parameter is `true`, the link is sent in an email.
       - completion: Completion with `operationId` on success.
    */
    public func startAuthByEmail(oAuth2Params: OAuth2Params,
                                 email: String,
                                 linkUrl: String?,
                                 sendLink: Bool,
                                 completion: @escaping LoginKitCompletion<String>)
    {
        api.startAuthByEmail(oAuth2Params: oAuth2Params, email: email, linkUrl: linkUrl, sendLink: sendLink)
        { result in
            switch result
            {
                case .success(let response): completion(.success(response.operationId))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Completes user authentication via email and a confirmation code.
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
       - completion: Completion with `loginURL` on success.
    */
    public func completeAuthByEmail(clientId: Int,
                                    code: String,
                                    email: String,
                                    operationId: String,
                                    completion: @escaping LoginKitCompletion<String>)
    {
        api.completeAuthByEmail(clientId: clientId, code: code, email: email, operationId: operationId)
        { result in
            switch result
            {
                case .success(let response): completion(.success(response.loginURL))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Starts user authentication via phone number and sends a confirmation code to the user phone number.
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
        - oAuth2Params: Instance of `OAuth2Params`.
        - phoneNumber: User phone number.
        - linkUrl: URL to redirect the user to the status authentication page. **Required** if the parameter `send_link` is `true`.
        - sendLink: Whether a link is sent with the confirmation code in the SMS. The link can be used instead of the confirmation code to log in. If the parameter is `true`, the link is sent in the SMS.
        - completion: Completion with `operationId` on success.
    */
    public func startAuthByPhone(oAuth2Params: OAuth2Params,
                                 phoneNumber: String,
                                 linkUrl: String?,
                                 sendLink: Bool,
                                 completion: @escaping LoginKitCompletion<String>)
    {
        api.startAuthByPhone(oAuth2Params: oAuth2Params, phoneNumber: phoneNumber, linkUrl: linkUrl, sendLink: sendLink)
        { result in
            switch result
            {
                case .success(let response): completion(.success(response.operationId))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Completes user authentication via the phone number and a confirmation code.
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
        - completion: Completion with `loginURL` on success.
    */
    public func completeAuthByPhone(clientId: Int,
                                    code: String,
                                    phoneNumber: String,
                                    operationId: String,
                                    completion: @escaping LoginKitCompletion<String>)
    {
        api.completeAuthByPhone(clientId: clientId, code: code, operationId: operationId, phoneNumber: phoneNumber)
        { result in
            switch result
            {
                case .success(let response): completion(.success(response.loginURL))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Waits until the user follows the link provided via email or SMS and returns the confirmation code for authentication. If you made this request and didn't get the code after 20 seconds, an error occurred. In this case, resend the request immediately. The lifetime of the code is 3 minutes.

     The workflow of using this method:

     1. The application opens an authentication form so the user can enter their email address.
     2. The user enters their email address.
     3. The application sends the `Start auth by email or phone number` (JWT or OAuth 2.0) request to the Xsolla Login server: a. If the parameter `send_link` is `true`, after this request, you should send this same request to make email or SMS contain the confirmation code and link. b. If the parameter `send_link` is `false` or not passed, the email will contain the confirmation code only.
     4. The Xsolla Login server sends an email or SMS to the user and returns the ID of the confirmation code.
     5. The application shows a field so the user can fill in the confirmation code.
     6. The user enters the received confirmation code or follows the link.
     7. The application sends the `Complete auth by email or phone number` (JWT or OAuth 2.0) request with the received ID to the Xsolla Login server.
     8. The user is considered as authorized.
    */
    public func getConfirmationCode(projectId: String,
                                    login: String,
                                    operationId: String,
                                    completion: @escaping LoginKitCompletion<String>)
    {
        api.getConfirmationCode(projectId: projectId, login: login, operationId: operationId, completion: completion)
    }

    /**
     Authenticates a user via a specific device ID.
     - Parameters:
       - oAuth2Params: Instance of `OAuth2Params`.
       - device: Manufacturer and model name of the device.
       - deviceId: Device ID. For iOS, it is an [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc) property.
       - completion: Completion with `operationId` on success.
    */
    public func authWithDeviceId(oAuth2Params: OAuth2Params,
                                 device: String,
                                 deviceId: String,
                                 completion: @escaping LoginKitCompletion<String>)
    {
        api.authWithDeviceId(oAuth2Params: oAuth2Params, device: device, deviceId: deviceId)
        { result in
            switch result
            {
                case .success(let response): completion(.success(response.loginURL))
                case .failure(let error): completion(.failure(error.processed))
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
       - completion: Completion void on success or error on failure.
    */
    public func resendConfirmationLink(clientId: Int,
                                       redirectUri: String,
                                       state: String,
                                       username: String,
                                       completion: @escaping LoginKitCompletion<Void>)
    {
        api.resendConfirmationLink(clientId: clientId, redirectUri: redirectUri, state: state, username: username)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a list of user’s devices.
     - Parameters:
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
          You can use the Pay Station Access Token as an alternative.
          You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - completion: Completion with array of `DeviceInfo` on success.
    */
    public func getUserDevices(accessToken: String, completion: @escaping LoginKitCompletion<[DeviceInfo]>)
    {
        api.getUserDevices(accessToken: accessToken)
        { result in
            switch result
            {
                case .success(let response): completion(.success(response.map { DeviceInfo(apiResponse: $0) }))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Links the specified device to the user account. To enable authentication via device ID and linking, contact your Account Manager.
     - Parameters:
       - device: Manufacturer and model name of the device.
       - deviceId: Device ID. For iOS, it is an [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc) property.
       - accessToken: Access token. By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         Alternatively, you can use the Pay Station access token.
         You can generate your own token ([learn more](https://developers.xsolla.com/pay-station-api/current/token/create-token)).
       - completion: Completion with empty response on success.
    */
    public func linkDeviceToAccount(device: String,
                                    deviceId: String,
                                    accessToken: String,
                                    completion: @escaping LoginKitCompletion<Void>)
    {
        api.linkDeviceToAccount(device: device, deviceId: deviceId, accessToken: accessToken)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Unlinks the specified device from the user account. To enable authentication via device ID and unlinking, contact your Account Manager.
     - Parameters:
       - deviceId: Device ID. For iOS, it is an [identifierForVendor](https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc) property.
       - accessToken: Access token. By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         Alternatively, you can use the Pay Station access token.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - completion: Completion with empty response on success.
    */
    public func unlinkDeviceFromAccount(deviceId: String,
                                        accessToken: String,
                                        completion: @escaping LoginKitCompletion<Void>)
    {
        api.unlinkDeviceFromAccount(deviceId: deviceId, accessToken: accessToken)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Adds the username/email and password authentication to the existing user account. This method is called if the account is created via device ID or phone number.
     - Parameters:
       - username: Username.
       - password: User password.
       - email: User email address.
       - promoEmailAgreement: User consent to receive the newsletter.
       - accessToken: Access token. By default, the Xsolla Login User JWT (Bearer token) is used for authorization. Alternatively, you can use the Pay Station access token. You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
           - redirectUri: URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation. Must be identical to the **Callback URL** specified in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **General settings** > **URL**. **Required** if there are several Callback URLs.
           - completion: Completion with information whether the user has to confirm the email address or not on success.
    */
    public func addUsernameAndPassword(username: String,
                                       password: String,
                                       email: String,
                                       promoEmailAgreement: Bool,
                                       accessToken: String,
                                       redirectUri: String?,
                                       completion: @escaping (LoginKitCompletion<Bool>))
    {
        api.addUsernameAndPassword(accessToken: accessToken,
                                   username: username,
                                   password: password,
                                   email: email,
                                   promoEmailAgreement: promoEmailAgreement,
                                   redirectUri: redirectUri)
        { result in
            switch result
            {
                case .success(let response): completion(.success(response.emailConfirmationRequired))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets details of the user authenticated by the JWT.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - completion: Instance of `LoginUserDetails` on success.
    */
    public func getCurrentUserDetails(accessToken: String,
                                      completion: @escaping LoginKitCompletion<UserProfileDetails>)
    {
        api.getCurrentUserDetails(accessToken: accessToken)
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let userDetails = UserProfileDetails(fromGetCurrentUserDetailsResponse: responseModel)
                    completion(.success(userDetails))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Updates the details of the authenticated user by the JWT.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - completion: Instance of `LoginUserDetails` on success.
    */
    public func updateCurrentUserDetails(accessToken: String,
                                         birthday: Date? = nil,
                                         firstName: String? = nil,
                                         lastName: String? = nil,
                                         nickname: String? = nil,
                                         gender: UserProfileDetails.Gender? = nil,
                                         completion: @escaping LoginKitCompletion<UserProfileDetails>)
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
        { result in
            switch result
            {
                case .success(let responseModel): do
                {
                    let userDetails = UserProfileDetails(fromGetCurrentUserDetailsResponse: responseModel)
                    completion(.success(userDetails))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets the email of the authenticated user by the JWT.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - completion: user's email on success.
    */
    public func getUserEmail(accessToken: String,
                             completion: @escaping LoginKitCompletion<String?>)
    {
        api.getUserEmail(accessToken: accessToken)
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel.currentEmail))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Deletes the profile picture of the authenticated user by the JWT.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - completion: Empty response on success.
    */
    public func deleteUserPicture(accessToken: String, completion: @escaping LoginKitCompletion<Void>)
    {
        api.deleteUserPicture(accessToken: accessToken)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Uploads the profile picture of the authenticated user by the JWT.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - imageURL: URL of image to be uploaded.
       - completion: Picture link on success.
    */
    public func uploadUserPicture(accessToken: String,
                                  imageURL: URL,
                                  completion: @escaping LoginKitCompletion<String>)
    {
        api.uploadUserPicture(accessToken: accessToken, imageURL: imageURL)
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel.picture))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets the phone number of the authenticated user by the JWT.
     The phone number in this method is used only for passing two-factor authentication.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - completion: Empty response on success.
    */
    public func getCurrentUserPhone(accessToken: String,
                                    completion: @escaping LoginKitCompletion<String?>)
    {
        api.getCurrentUserPhone(accessToken: accessToken)
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(responseModel.phoneNumber))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Updates the phone number of the authenticated user by the JWT.
     The phone number in This method is used only for passing two-factor authentication.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - phoneNumber: Updated user phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers)
       - completion: User phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers) on success.
    */
    public func updateCurrentUserPhone(accessToken: String,
                                       phoneNumber: String,
                                       completion: @escaping LoginKitCompletion<Void>)
    {
        api.updateCurrentUserPhone(accessToken: accessToken, phoneNumber: phoneNumber)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Deletes the phone number of the authenticated user by the JWT.
     The phone number in This method is used only for passing two-factor authentication.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - phoneNumber: User phone number according to [national conventions](https://en.wikipedia.org/wiki/National_conventions_for_writing_telephone_numbers)
       - completion: Empty response on success.
    */
    public func deleteCurrentUserPhone(accessToken: String,
                                       phoneNumber: String,
                                       completion: @escaping LoginKitCompletion<Void>)
    {
        api.deleteCurrentUserPhone(accessToken: accessToken, phoneNumber: phoneNumber)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a list of users added as friends of the authenticated user.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - listType: Friend list type parameter.
       - sortType: Sorting parameter.
       - sortOrderType: Sorting order parameter
       - after: Parameter that is used for API pagination.
       - limit: Limit of the result.
       - completion: Instance of `FriendsList` on success.
    */
    public func getCurrentUserFriends(accessToken: String,
                                      listType: FriendsListType,
                                      sortType: FriendsListSortType,
                                      sortOrderType: FriendsListOrderType,
                                      after: String?,
                                      limit: Int? = nil,
                                      completion: @escaping LoginKitCompletion<FriendsList>)
    {
        api.getCurrentUserFriends(accessToken: accessToken,
                                  listType: listType.rawValue,
                                  sortType: sortType.rawValue,
                                  sortOrder: sortOrderType.rawValue,
                                  after: after,
                                  limit: limit)
        { result in
            switch result
            {
                case .success(let responseModel): completion(.success(FriendsList(fromResponse: responseModel)))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Updates the friend list of the authenticated user.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token (learn more [here](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - after: Parameter that is used for API pagination.
       - actionType: Type of the friend list updating action.
       - userID: ID of the user to change relationships with.
       - completion: Empty response on success.
    */
    public func updateCurrentUserFriends(accessToken: String,
                                         actionType: FriendsListUpdateAction,
                                         userID: String,
                                         completion: @escaping LoginKitCompletion<Void>)
    {
        api.updateCurrentUserFriends(accessToken: accessToken,
                                     action: actionType.rawValue,
                                     userID: userID)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Updates the friend list of the authenticated user.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - completion: Array of `UserSocialNetworkInfo` on success.
    */
    public func getLinkedNetworks(accessToken: String,
                                  completion: @escaping LoginKitCompletion<[UserSocialNetworkInfo]>)
    {
        api.getLinkedNetworks(accessToken: accessToken)
        { result in
            switch result
            {
                case .success(let response): do
                {
                    let userSocialNetworInfos = response.map { UserSocialNetworkInfo(fromResponse: $0) }
                    completion(.success(userSocialNetworInfos))
                }

                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets the URL to link the social network to the user account. The social network should be used for authentication.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - providerName: Name of the social network connected to Login in Publisher Account.
         Can be: *amazon*, *apple*, *baidu*, *battlenet*, *discord*, *facebook*, *github*, *google*, *kakao*, *linkedin*,
         *mailru*, *microsoft*, *msn*, *naver*, *ok*, *paypal*, *psn*, *reddit*, *steam*, *twitch*, *twitter*, *vimeo*, *vk*,
         *wechat*, *weibo*, *yahoo*, *yandex*, *youtube*, *xbox*.
       - loginURL: URL to redirect the user to after account confirmation, successful authentication, or password reset confirmation. Must be identical to the **Callback URL** specified in [Publisher Account](https://publisher.xsolla.com/) > your Login project > **General settings** > **URL**. **Required** if there are several Callback URLs.
       - completion: URL used for authenticating the user via the social network on success.
    */
    public func getURLToLinkSocialNetworkToAccount(accessToken: String,
                                                   providerName: String,
                                                   loginURL: String,
                                                   completion: @escaping LoginKitCompletion<String>)
    {
        api.getURLToLinkSocialNetworkToAccount(accessToken: accessToken, providerName: providerName, loginURL: loginURL)
        { result in

            switch result
            {
                case .success(let response): completion(.success(response.url))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a list of user friends from a social provider.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - platform: Name of the chosen social provider which you can enable in your [Publisher Account](https://publisher.xsolla.com/) > your Login project > **Social connections**.
         If you do not specify it, the call gets friends from all social providers.
       - offset: Number of the elements from which the list is generated.
       - limit: Maximum number of friends that are returned at a time.
       - withLoginId: Whether the social friends are from your game.
       - completion: Instance of `SocialNetworkFriendsList` on success.
    */
    public func getSocialNetworkFriends(accessToken: String,
                                        platform: String,
                                        offset: Int,
                                        limit: Int,
                                        withLoginId: Bool,
                                        completion: @escaping LoginKitCompletion<SocialNetworkFriendsList>)
    {
        api.getSocialNetworkFriends(accessToken: accessToken,
                                    platform: platform,
                                    offset: offset,
                                    limit: limit,
                                    withLoginId: withLoginId)
        { result in
            switch result
            {
                case .success(let response): completion(.success(SocialNetworkFriendsList(fromResponse: response)))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Begins processing to update a list of user’s friends from a social provider.
     Note that there may be a delay in data processing because of the Xsolla Login server or provider server high loads.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - platform: Name of the chosen social provider which you can enable in your [Publisher Account](https://publisher.xsolla.com/) > your Login project > **Social connections**.
         If you do not specify it, the call gets friends from all social providers.
       - completion: Empty result on success.
    */
    public func updateSocialNetworkFriends(accessToken: String,
                                           platform: String,
                                           completion: @escaping LoginKitCompletion<Void>)
    {
        api.updateSocialNetworkFriends(accessToken: accessToken, platform: platform)
        { result in
            switch result
            {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    // MARK: - User Attributes

    /**
     Gets a list of particular users attributes. Returns only attributes with the `client` value of the `attr_type` parameter.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - keys: List of attributes’ keys which you want to get. If you do not specify them, it returns all user attributes.
       - publisherProjectId: Project ID from Publisher Account which you want to get attributes for.
         If you do not specify it, it returns attributes without the value of this parameter.
       - userId: User ID which attributes you want to get. Returns only attributes with the `public` value of the `permission` parameter.
         If you do not specify it or put your user ID there, it returns only your attributes with any value for the `permission` parameter.
        - completion: Array of `UserAttribute` on success.
    */
    public func getClientUserAttributes(accessToken: String,
                                        keys: [String]?,
                                        publisherProjectId: Int?,
                                        userId: String?,
                                        completion: @escaping LoginKitCompletion<[UserAttribute]>)
    {
        api.getClientUserAttributes(accessToken: accessToken,
                                    keys: keys,
                                    publisherProjectId: publisherProjectId,
                                    userId: userId)
        { result in

            switch result
            {
                case .success(let response): completion(.success(response.map { UserAttribute(fromResponse: $0) }))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Gets a list of particular user read-only attributes. Returns only attributes with the `client` value of the `attr_type` parameter which was set only for reading.
     - Parameters:
       - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
         You can use the Pay Station Access Token as an alternative.
         You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
       - keys: List of attributes’ keys which you want to get. If you do not specify them, it returns all user’s attributes.
       - publisherProjectId: Project ID from Publisher Account which you want to get attributes for.
         If you do not specify it, it returns attributes without the value of this parameter.
       - userId: User ID which attributes you want to get. Returns only attributes with the `public` value of the `permission` parameter.
         If you do not specify it or put your user ID there, it returns only your attributes with any value for the `permission` parameter.
       - completion: Array of `UserAttribute` on success.
    */
    public func getClientUserReadOnlyAttributes(accessToken: String,
                                                keys: [String]?,
                                                publisherProjectId: Int?,
                                                userId: String?,
                                                completion: @escaping LoginKitCompletion<[UserAttribute]>)
    {
        api.getClientUserReadOnlyAttributes(accessToken: accessToken,
                                            keys: keys,
                                            publisherProjectId: publisherProjectId,
                                            userId: userId)
        { result in

            switch result
            {
                case .success(let response): completion(.success(response.map { UserAttribute(fromResponse: $0) }))
                case .failure(let error): completion(.failure(error.processed))
            }
        }
    }

    /**
     Updates and creates particular user attributes.
     - Parameters:
        - accessToken: By default, the Xsolla Login User JWT (Bearer token) is used for authorization.
          You can use the Pay Station Access Token as an alternative.
          You can generate your own token ([learn more](https://developers.xsolla.com/api/v2/getting-started/#api_token_ui)).
        - attributes: List of attributes of the specified game.
          To add an attribute that does not exist, set this attribute to the `key` parameter.
          To update `value` of the attribute, specify its `key` parameter and set new `value`.
          You can change several attributes at a time.
        - publisherProjectId: Project ID from Publisher Account which you want to get attributes for.
          If you do not specify it, it returns attributes without the value of this parameter.
        - removingKeys: List of attributes which you want to delete. If you specify the same attribute in `attributes` parameter, it will not be deleted.
        - completion: Empty response on success.
    */
    public func updateClientUserAttributes(accessToken: String,
                                           attributes: [UserAttribute]?,
                                           publisherProjectId: Int?,
                                           removingKeys: [String]?,
                                           completion: @escaping LoginKitCompletion<Void>)
    {
        let requestUserAttributes = attributes?.map
        {
            UpdateClientUserAttributesRequest.Body.Attribute(key: $0.key, permission: $0.permission, value: $0.value)
        }

        api.updateClientUserAttributes(accessToken: accessToken,
                                       attributes: requestUserAttributes,
                                       publisherProjectId: publisherProjectId,
                                       removingKeys: removingKeys)
        { result in

            switch result
            {
                case .success: completion(.success(()))
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

        if case .forbidden(_, let model) = self as? APIError<LoginAPIErrorModel>
        {
            return LoginKitError(code: model?.code) ?? self
        }

        if case .unauthorized(_, let model) = self as? APIError<LoginAPIErrorModel>
        {
            return LoginKitError(code: model?.code) ?? self
        }

        return self
    }
}

public enum LoginKitError: Error
{
    case failedURLExtraction
    case invalidToken

    internal init?(code: Int?)
    {
        switch code
        {
            case 10017: self = .invalidToken
            case 2016: self = .invalidToken

            default: return nil
        }
    }
}
