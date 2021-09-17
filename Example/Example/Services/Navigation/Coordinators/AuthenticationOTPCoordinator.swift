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

import XsollaSDKLoginKit
import UIKit

protocol AuthenticationOTPCoordinatorProtocol: Coordinator, Finishable { }

class AuthenticationOTPCoordinator: BaseCoordinator<AuthenticationOTPCoordinator.Dependencies,
                                                    AuthenticationCoordinator.Params>,
                                    AuthenticationOTPCoordinatorProtocol
{
    override func start()
    {
        showStartVC()
    }

    func showStartVC()
    {
        let params = OTPStartVCFactoryParams(configuration: dependencies.configuration)
        let viewController = dependencies.viewControllerFactory.createOTPStartVC(params: params)

        viewController.actionButtonHandler =
        { [unowned self] viewController, view in

            guard let payload = viewController.codeRequestData, self.validate(payload: payload) else
            {
                showError(OTPSequenceError.invalidPayload)
                return
            }

            viewController.setState(.loading(view), animated: true)

            dependencies.otpSequence.sendOTPRequest(payload: payload,
                                                    state: UUID().uuidString,
                                                    confirmationLink: AppConfig.confirmationLink,
                                                    sendConfirmationLink: true)
            { [weak self] result in

                if case .success(let opertionId) = result
                {
                    viewController.setState(.normal, animated: true)
                    self?.showInputCodeVC(payload: payload, operationId: opertionId)
                }

                if case .failure(let error) = result
                {
                    viewController.setState(.error(nil), animated: true)
                    logger.error { error }
                    showError(error)
                }
            }
        }

        presenter?.pushViewController(viewController, animated: true)
    }

    func showInputCodeVC(payload: OTPRequestPayload, operationId: OTPOperationId)
    {
        let params = OTPInputCodeVCFactoryParams(configuration: dependencies.configuration)
        let viewController = dependencies.viewControllerFactory.createOTPInputCodeVC(params: params)

        viewController.codeExpirationInterval =
        { [weak self] in guard let self = self else { return 0 }

            return self.dependencies.otpSequence.codeExpirationInterval
        }

        viewController.resendCodeButtonHandler =
        { [unowned self] viewController in

            self.dependencies.otpSequence.sendOTPRequest(payload: payload,
                                                         state: UUID().uuidString,
                                                         confirmationLink: AppConfig.confirmationLink,
                                                         sendConfirmationLink: true)
            { result in

                if case .success = result
                {
                    viewController.startTimer()
                    self.startListeningConfirmationCode(in: viewController, payload: payload, operationId: operationId)
                }

                if case .failure(let error) = result
                {
                    logger.error { error }
                    showError(error)
                }
            }
        }

        viewController.actionButtonHandler =
        { [unowned self] viewController, view in

            guard let code = viewController.code else
            {
                showError(OTPSequenceError.invalidOTPCode)
                return
            }

            self.validateCode(code, payload: payload, operationId: operationId, in: viewController, view: view)
        }

        startListeningConfirmationCode(in: viewController, payload: payload, operationId: operationId)

        presenter?.pushViewController(viewController, animated: true)
        viewController.startTimer()
    }

    func validateCode(_ code: String,
                      payload: OTPRequestPayload,
                      operationId: OTPOperationId,
                      in viewController: OTPInputCodeVCProtocol,
                      view: UIView?)
    {
        viewController.setState(.loading(view), animated: true)

        if backgroundTask == .invalid { registerBackgroundTask() }

        self.dependencies.otpSequence.validateOTPCode(code)
        { [weak self] result in

            switch result
            {
                case .success(let tokenInfo):

                    let interval = TimeInterval(tokenInfo.expiresIn ?? 3600)
                    self?.dependencies.loginManager.login(accessToken: tokenInfo.accessToken,
                                                    refreshToken: tokenInfo.refreshToken,
                                                    expireDate: Date(timeIntervalSinceNow: interval))

                    viewController.setState(.normal, animated: true)

                case .failure(let error):
                    viewController.setState(.error(nil), animated: true)
                    self?.showError(error)
            }

            if let backgroundTask = self?.backgroundTask, backgroundTask != .invalid { self?.endBackgroundTask() }
        }
    }

    func startListeningConfirmationCode(in viewController: OTPInputCodeVCProtocol,
                                        payload: OTPRequestPayload,
                                        operationId: OTPOperationId)
    {
        dependencies.otpSequence.startListeningConfirmationCode
        { [weak self] result in

            if case .success(let code) = result, let self = self
            {
                viewController.setState(.loading(nil), animated: true)
                self.validateCode(code, payload: payload, operationId: operationId, in: viewController, view: nil)
            }
        }
    }

    func validate(payload: OTPRequestPayload) -> Bool
    {
        return dependencies.otpSequence.validatePayload(payload)
    }

    func showError(_ error: Error)
    {
        guard let alertVC = createAlertViewController(with: error) else { return }
        presenter?.present(alertVC, animated: true, completion: nil)
    }

    func createAlertViewController(with error: Error) -> UIAlertController?
    {
        guard let error = parseError(error) else { return nil }

        let alertVC = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertVC.addAction(action)

        return alertVC
    }

    func parseError(_ error: Error) -> (title: String?, message: String?)?
    {
        switch error
        {
            case OTPSequenceError.invalidPayload: return ("Error", dependencies.configuration.l10n.invalidPayloadError)
            default: break
        }

        return ("Error", error.localizedDescription)
    }

    // MARK: - Background tasks

    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    func registerBackgroundTask()
    {
        backgroundTask = UIApplication.shared.beginBackgroundTask
        { [weak self] in
            self?.endBackgroundTask()
        }
    }

    func endBackgroundTask()
    {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
}

extension AuthenticationOTPCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let xsollaSDK: XsollaSDKProtocol
        let loginAsyncUtility: LoginAsyncUtilityProtocol
        let loginManager: LoginManagerProtocol
        let otpSequence: OTPSequenceProtocol
        let configuration: OTPSequenceConfiguration
    }

    typealias Params = EmptyParams
}
