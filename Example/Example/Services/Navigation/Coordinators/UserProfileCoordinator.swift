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

protocol UserProfileCoordinatorProtocol: Coordinator, Finishable { }

class UserProfileCoordinator: BaseCoordinator<UserProfileCoordinator.Dependencies,
                                              UserProfileCoordinator.Params>,
                              UserProfileCoordinatorProtocol
{
    var loginAsync: LoginAsyncUtilityProtocol { params.loginAsyncUtility }

    override func start()
    {
        showStartVC()
    }

    // MARK: - View Controllers

    func showStartVC()
    {
        let userProfile = dependencies.userProfile
        let viewController = dependencies.viewControllerFactory.createUserProfileVC(params: .none)

        viewController.selectAvatarButtonHandler =
        { [weak self] controller in

            self?.showUserProfileAvatarSelectorVC()
        }

        viewController.upgradeProfileRequestHandler =
        { [weak self] controller in

            self?.showUpgradeAccountVC(profileVC: controller, profile: userProfile)
        }

        viewController.manageDevicesRequestHandler =
        { [weak self] controller in

            self?.showDevicesListVC(userProfile)
        }

        viewController.linkSocialNetworkRequestHandler =
        { [weak self] controller, network in

            self?.linkSocialNetwork(network, for: userProfile, in: controller)
        }

        viewController.saveProfileDataRequestHandler =
        { [weak self] controller in

            controller.setState(.loading(nil), animated: true)

            userProfile.updateUserDetails(with: controller.userProfileMandatoryDetails)
            { result in

                if case .success(let details) = result
                {
                    controller.setState(.normal, animated: true)
                    controller.setup(profileDetails: details)
                }

                if case .failure(let error) = result
                {
                    controller.setState(.error(nil), animated: true)
                    self?.showErrorAlert(error: error, in: controller)
                }
            }
        }

        viewController.resetPasswordButtonHandler =
        { [weak self] controller in

            userProfile.resetPassword
            { error in
                guard let error = error else { return }
                self?.showErrorAlert(error: error, in: controller)
            }
        }

        fetchUserProfile(userProfile, in: viewController)

        pushViewController(viewController, pushMode: .replaceCurrent)
    }

    func showUserProfileAvatarSelectorVC()
    {
        if currentViewController is UserProfileAvatarSelectorVCProtocol { return }

        let userProfile = dependencies.userProfile
        let viewController = dependencies.viewControllerFactory.createUserProfileAvatarSelectorVC(params: .none)

        viewController.removeAvatarButtonHandler =
        { [weak self] controller in

            controller.setState(.loading(nil), animated: true)

            userProfile.removeUserPicture
            { error in

                if let error = error
                {
                    controller.setState(.error(nil), animated: true)
                    self?.showErrorAlert(error: error, in: controller)
                    return
                }

                controller.setState(.normal, animated: true)
                controller.updateUserAvatar(link: nil)
                self?.updateUserProfileVC()
            }
        }

        viewController.selectAvatarButtonHandler =
        { [weak self] controller in

            guard
                let index = controller.selectedAvatarIndex,
                let url = Bundle.main.url(forResource: "avatar_\(index)", withExtension: "png")
            else
            { return }

            controller.setState(.loading(nil), animated: true)

            userProfile.uploadUserPicture(url: url)
            { result in

                switch result
                {
                case .failure(let error): do
                    {
                        controller.setState(.error(nil), animated: true)
                        self?.showErrorAlert(error: error, in: controller)
                    }
                case .success(let link): do
                    {
                        controller.setState(.normal, animated: true)
                        controller.updateUserAvatar(link: link)
                        self?.updateUserProfileVC()
                    }
                }
            }
        }

        viewController.updateUserAvatar(link: userProfile.userDetails?.picture)
        presentViewController(viewController, completion: nil)
    }

    func showUpgradeAccountVC(profileVC: UserProfileVCProtocol, profile: UserProfileProtocol)
    {
        if currentViewController is UpgradeAccountVCProtocol { return }

        let viewController = dependencies.viewControllerFactory.createUpgradeAccountVC(params: .none)

        viewController.actionRequestHandler =
        { [weak self] viewController, button in

            let model = viewController.model

            viewController.setState(.loading(nil), animated: true)

            self?.loginAsync.upgradeAccount(withUsername: model.username,
                                            password: model.password,
                                            email: model.email,
                                            promoEmailAgreement: false)
            .then
            { _ in

                guard let self = self else { return }

                self.popViewController()
                self.fetchUserProfile(profile, in: profileVC)
            }
            .catch
            { error in
                viewController.setState(.error(nil), animated: true)
                self?.showErrorAlert(error: error, in: viewController)
            }

        }

        pushViewController(viewController, pushMode: .push)
    }

    // MARK: - Fetches & Updates

    func fetchUserProfile(_ profile: UserProfileProtocol, in viewController: UserProfileVCProtocol? = nil)
    {
        viewController?.setState(.loading(nil), animated: true)

        profile.fetchUserDetails
        { [weak self] result in

            if case .success(let details) = result
            {
                viewController?.setState(.normal, animated: true)
                viewController?.setup(profileDetails: details)

                self?.fetchUserLinkedSocialNetworks(profile, in: viewController)
            }

            if case .failure(let error) = result
            {
                viewController?.setState(.error(nil), animated: true)
                if let viewController = viewController { self?.showErrorAlert(error: error, in: viewController) }
            }
        }
    }

    func fetchUserLinkedSocialNetworks(_ profile: UserProfileProtocol, in viewController: UserProfileVCProtocol? = nil)
    {
        profile.fetchLinkedSocialNetworks
        { [weak self] result in

            if case .success(let networks) = result
            {
                viewController?.setup(linkedSocialNetworks: networks)

                self?.fetchUserConnectedDevices(profile, in: viewController)
            }

            if case .failure(let error) = result
            {
                viewController?.setState(.error(nil), animated: true)
                if let viewController = viewController { self?.showErrorAlert(error: error, in: viewController) }
            }
        }
    }

    func fetchUserConnectedDevices(_ profile: UserProfileProtocol, in viewController: UserProfileVCProtocol? = nil)
    {
        profile.fetchConnectedDevices
        { [weak self] result in

            if case .success(let devices) = result
            {
                viewController?.setup(connectedDevices: devices)
            }

            if case .failure(let error) = result
            {
                viewController?.setState(.error(nil), animated: true)
                if let viewController = viewController { self?.showErrorAlert(error: error, in: viewController) }
            }
        }
    }

    func updateUserProfileVC()
    {
        guard let userDetails = dependencies.userProfile.userDetails else { return }

        userProfileVC?.setup(profileDetails: userDetails)
    }

    // MARK: - Social networks

    func linkSocialNetwork(_ network: SocialNetwork,
                           for userProfile: UserProfileProtocol,
                           in viewController: UserProfileVCProtocol? = nil)
    {
        viewController?.setState(.loading(nil), animated: true)

        loginAsync.getSocialNetworksLinkingURL(for: network, callbackUrl: AppConfig.redirectUrl)
        .then
        { url in
            viewController?.setState(.normal, animated: true)

            let useragent = self.getUseragent(for: network)
            self.linkSocialNetwork(with: url, useragent: useragent, for: userProfile, in: viewController)
        }
        .catch
        { error in
            viewController?.setState(.error(nil), animated: true)
            if let viewController = viewController { self.showErrorAlert(error: error, in: viewController) }
        }
    }

    func linkSocialNetwork(with url: URL,
                           useragent: String?,
                           for userProfile: UserProfileProtocol,
                           in viewController: UserProfileVCProtocol? = nil)
    {
        let params = WebFlowURLCallbackListenableVCFactoryParams(useragent: useragent)
        let webViewController =
        dependencies.viewControllerFactory.createWebFlowURLCallbackListenableVC(params: params)

        let request = URLRequest(url: url)
        let callbackUrl = URL(string: AppConfig.redirectUrl)!

        webViewController.startFlow(with: request, callbackUrl: callbackUrl)
        { [weak self, weak webViewController] result in

            webViewController?.dismiss(animated: true, completion: nil)

            var socialNetworkLiningError: Error?

            // Finging network errors reported by WKView
            if case .failure(let error) = result
            {
                socialNetworkLiningError = error
            }

            // Finding errors reported by Xsolla Login (parsed from url query)
            if case .success(let url) = result, let error = LoginKit.shared.authCodeExtractor.extractError(url: url)
            {
                socialNetworkLiningError = error
            }

            if let error = socialNetworkLiningError
            {
                viewController?.setState(.error(nil), animated: true)
                if let viewController = viewController { self?.showErrorAlert(error: error, in: viewController) }
            }
            else
            {
                viewController?.setState(.normal, animated: true)
                self?.fetchUserProfile(userProfile, in: viewController)
                self?.fetchUserLinkedSocialNetworks(userProfile, in: viewController)
            }
        }

        presentViewController(webViewController, completion: nil)
    }

    // MARK: - Devices

    func showDevicesListVC(_ profile: UserProfileProtocol)
    {
        if currentViewController is ConnectedDevicesListVCProtocol { return }

        let viewController = dependencies.viewControllerFactory.createDevicesListVC(params: .none)

        viewController.removeDeviceHandler =
        { [weak self, weak viewController, weak profile] deviceItem in
            guard let profile = profile, let viewController = viewController else { return }

            self?.showUnlinkDeviceAlert(in: viewController)
            {
                self?.handleUnlinkDevice(deviceId: deviceItem.deviceId,
                                         viewController: viewController,
                                         profile: profile)
            }
        }

        viewController.setup(with: getConnectedDevicesListDataSource(for: profile))

        pushViewController(viewController, pushMode: .push)
    }

    func handleUnlinkDevice(deviceId: String,
                            viewController: ConnectedDevicesListVCProtocol,
                            profile: UserProfileProtocol)
    {
        viewController.setState(.loading(nil), animated: true)

        profile.unlinkDevice(deviceId: deviceId)
        { [weak self, weak profile, weak viewController] result in
            guard let self = self, let profile = profile, let viewController = viewController else { return }

            if case .success = result
            {
                if profile.userConnectedDevices.isEmpty
                {
                    self.userProfileVC?.setup(connectedDevices: [])
                    self.popViewController()
                }

                viewController.setState(.normal, animated: true)
                viewController.setup(with: self.getConnectedDevicesListDataSource(for: profile))
            }

            if case .failure(let error) = result
            {
                viewController.setState(.error(nil), animated: true)
                self.showErrorAlert(error: error, in: viewController)
            }
        }
    }

    // MARK: - Utility

    private var userProfileVC: UserProfileVCProtocol?
    {
        guard let controllers = presenter?.viewControllers else { return nil }

        for viewController in controllers
        {
            if let viewController = viewController as? UserProfileVCProtocol { return viewController }
        }

        return nil
    }

    func getConnectedDevicesListDataSource(for profile: UserProfileProtocol) -> ConnectedDevicesListDataSourceProtocol
    {
        let factory = self.dependencies.datasourceFactory
        let removable = profile.userDetails.map { !$0.isAnonymous } ?? false
        let params =
        ConnectedDevicesListDataSourceFactoryParams(devices: profile.userConnectedDevices,
                                                    removable: removable)

        let dataSource = factory.createConnectedDevicesListDataSource(params: params)

        return dataSource
    }

    func getUseragent(for network: SocialNetwork) -> String?
    {
        // swiftlint:disable line_length
        switch network
        {
        case .google, .youtube: return "Mozilla/5.0 (Linux; Android 10; Redmi Note 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Mobile Safari/537.36"
        case .qq: return "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36"
        default: return nil
        }
        // swiftlint:enable line_length
    }

    private func showErrorAlert(error: Error, in viewController: UIViewController)
    {
        let alert = UIAlertController(title: L10n.Alert.Error.common,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: L10n.Alert.Action.ok, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    func showUnlinkDeviceAlert(in viewController: UIViewController, confirmationHandler: @escaping () -> Void)
    {
        let alert = UIAlertController(title: L10n.Alert.UnlinkDevice.title,
                                      message: L10n.Alert.UnlinkDevice.message,
                                      preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: L10n.Alert.UnlinkDevice.confinmButton,
                                      style: .destructive,
                                      handler: { _ in confirmationHandler() }))

        alert.addAction(UIAlertAction(title: L10n.Alert.Action.cancel, style: .default, handler: nil ))

        viewController.present(alert, animated: true, completion: nil)
    }
    // MARK: - Initialization

    override init(presenter: Presenter?, dependencies: Dependencies, params: Params)
    {
        super.init(presenter: presenter, dependencies: dependencies, params: params)
        dependencies.userProfile.addListener(self)
    }
}

extension UserProfileCoordinator: UserProfileListener
{
    func userProfileDidUpdateDetails(_ userProfile: UserProfileProtocol)
    {
        guard userProfile.state == .loaded else { return }

        updateUserProfileVC()
    }

    func userProfileDidResetPassword()
    {
        let alert = UIAlertController(title: L10n.Alert.PasswordRecover.Success.title,
                                      message: L10n.Alert.PasswordRecover.Success.message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: L10n.Alert.Action.ok, style: .default, handler: nil)
        alert.addAction(alertAction)
        presenter?.present(alert, animated: true, completion: nil)
    }
}

extension UserProfileCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let userProfile: UserProfileProtocol
    }

    struct Params
    {
        let loginAsyncUtility: LoginAsyncUtilityProtocol
        let xsollaSDK: XsollaSDKProtocol
    }
}
