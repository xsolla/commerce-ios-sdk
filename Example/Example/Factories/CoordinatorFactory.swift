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

// swiftlint:disable line_length
// swiftlint:disable type_name

import UIKit

protocol CoordinatorFactoryProtocol
{
    func createMainContainerCoordinator(presenter: Presenter?,
                                        params: MainContainerCoordinatorFactoryParams) -> ContainerCoordinatorProtocol
    
    func createMainContentCoordinator(presenter: Presenter?,
                                      params: MainContentCoordinatorFactoryParams) -> MainCoordinatorProtocol
    
    func createAuthenticationCoordinator(presenter: Presenter?,
                                         params: AuthenticationCoordinatorFactoryParams) -> AuthenticationCoordinatorProtocol

    func createAuthenticationOTPCoordinator(presenter: Presenter?,
                                            params: AuthenticationOTPCoordinatorFactoryParams) -> AuthenticationOTPCoordinatorProtocol
}

class CoordinatorFactory: CoordinatorFactoryProtocol
{
    // MARK: - Public
    
    func createMainContainerCoordinator(presenter: Presenter?,
                                        params: MainContainerCoordinatorFactoryParams) -> ContainerCoordinatorProtocol
    {
        let coordinatorDependencies = ContainerCoordinator.Dependencies(coordinatorFactory: self,
                                                                            viewControllerFactory: self.params.viewControllerFactory,
                                                                            modelFactory: self.params.modelFactory,
                                                                            xsollaSDK: self.params.xsollaSDK,
                                                                            asyncUtilsFactory: self.params.asyncUtilsFactory,
                                                                            accessTokenProvider: params.accessTokenProvider,
                                                                            deepLinkManager: params.deepLinkManager)
        
        let coordinator = ContainerCoordinator(presenter: presenter,
                                                   dependencies: coordinatorDependencies,
                                                   params: .none)
        
        return coordinator
    }
    
    func createMainContentCoordinator(presenter: Presenter?,
                                      params: MainContentCoordinatorFactoryParams) -> MainCoordinatorProtocol
    {
        let coordinatorDependencies = MainCoordinator.Dependencies(coordinatorFactory: self,
                                                                          viewControllerFactory: self.params.viewControllerFactory,
                                                                          datasourceFactory: self.params.datasourceFactory,
                                                                          asyncUtilsFactory: self.params.asyncUtilsFactory,
                                                                          modelFactory: self.params.modelFactory,
                                                                          store: self.params.store,
                                                                          userProfile: params.userProfile)
        
        let coordinator = MainCoordinator(presenter: presenter,
                                                 dependencies: coordinatorDependencies,
                                                 params: .init(loginAsyncUtility: params.loginAsyncUtility,
                                                               xsollaSDK: self.params.xsollaSDK))
        
        return coordinator
    }
    
    func createAuthenticationCoordinator(presenter: Presenter?,
                                         params: AuthenticationCoordinatorFactoryParams) -> AuthenticationCoordinatorProtocol
    {
        let coordinatorDependencies = AuthenticationCoordinator.Dependencies(coordinatorFactory: self,
                                                                             viewControllerFactory: self.params.viewControllerFactory,
                                                                             xsollaSDK: self.params.xsollaSDK,
                                                                             loginManager: params.loginManager,
                                                                             loginAsyncUtility: params.loginAsyncUtility,
                                                                             modelFactory: self.params.modelFactory)

        let coordinator = AuthenticationCoordinator(presenter: presenter,
                                                    dependencies: coordinatorDependencies,
                                                    params: .none)
        
        return coordinator
    }

    func createAuthenticationOTPCoordinator(presenter: Presenter?,
                                            params: AuthenticationOTPCoordinatorFactoryParams) -> AuthenticationOTPCoordinatorProtocol
    {
        let otpSequence: OTPSequenceProtocol =
        {
            switch params.otpType
            {
                case .email: return OTPEmailSequence(sdk: self.params.xsollaSDK)
                case .phone: return OTPPhoneSequence(sdk: self.params.xsollaSDK)
            }
        }()

        var configuration: OTPSequenceConfiguration =
        {
            switch params.otpType
            {
                case .email: return OTPSequenceConfiguration.email
                case .phone: return OTPSequenceConfiguration.phone
            }
        }()

        configuration.configurePayloadTextField =
        { textField in

            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.smartDashesType = .no
            textField.smartQuotesType = .no
            textField.spellCheckingType = .no

            switch params.otpType
            {
                case .email: textField.keyboardType = .default
                case .phone: textField.keyboardType = .phonePad
            }
        }

        configuration.configureCodeTextField =
        { textField in

            textField.keyboardType = .numberPad

            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.smartDashesType = .no
            textField.smartQuotesType = .no
            textField.spellCheckingType = .no
        }

        let coordinatorDependencies = AuthenticationOTPCoordinator.Dependencies(coordinatorFactory: self,
                                                                                viewControllerFactory: self.params.viewControllerFactory,
                                                                                xsollaSDK: self.params.xsollaSDK,
                                                                                loginAsyncUtility: params.loginAsyncUtility,
                                                                                loginManager: params.loginManager,
                                                                                otpSequence: otpSequence,
                                                                                configuration: configuration)

        let coordinator = AuthenticationOTPCoordinator(presenter: presenter,
                                                       dependencies: coordinatorDependencies,
                                                       params: .none)

        return coordinator
    }

    // MARK: - Private
    
    private let params: Params
    
    init(params: Params)
    {
        self.params = params
    }
}

extension CoordinatorFactory
{
    struct Params
    {
        let viewControllerFactory: ViewControllerFactoryProtocol
        let asyncUtilsFactory: AsyncUtilsFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let xsollaSDK: XsollaSDKProtocol
        let store: StoreProtocol
    }
}

struct MainContainerCoordinatorFactoryParams
{
    let accessTokenProvider: AccessTokenProvider
    let deepLinkManager: DeepLinkManagerProtocol
}

struct AuthenticationCoordinatorFactoryParams
{
    let loginManager: LoginManagerProtocol
    let loginAsyncUtility: LoginAsyncUtilityProtocol
}

struct  MainContentCoordinatorFactoryParams
{
    let userProfile: UserProfileProtocol
    let loginAsyncUtility: LoginAsyncUtilityProtocol
}

struct  AuthenticationOTPCoordinatorFactoryParams
{
    let otpType: OTPType
    let loginManager: LoginManagerProtocol
    let loginAsyncUtility: LoginAsyncUtilityProtocol

    enum OTPType
    {
        case phone
        case email
    }
}
