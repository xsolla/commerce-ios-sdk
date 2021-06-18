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

protocol MainContentCoordinatorProtocol: Coordinator, Finishable
{
    var reloadRequestHandler: (() -> Void)? { get set }
    
    func show(screen: MainContentCoordinator.Screen)
}

class MainContentCoordinator: BaseCoordinator<MainContentCoordinator.Dependencies,
                                              MainContentCoordinator.Params>,
                              MainContentCoordinatorProtocol
{
    var reloadRequestHandler: (() -> Void)?

    // MARK: - Models
    
    private var inventoryList: InventoryList?
    private var virtualCurrencyList: VirtualCurrencyList?
    private var virtualItemsList: VirtualItemsList?
    private var virtualItemsActionHandler: VirtualItemsActionHandler?
    private var userCharacter: UserCharacterProtocol?
    
    private func invalidateAllModels()
    {
        inventoryList = nil
        virtualCurrencyList = nil
        virtualItemsList = nil
        virtualItemsActionHandler = nil
        userCharacter = nil
    }

    func show(screen: Screen)
    {
        switchToScreen(screen)
    }
    
    // MARK: - Screens
    
    func showUserProfileScreen()
    {
        if currentViewController is UserProfileVCProtocol { return }

        let userProfile = dependencies.userProfile
        let viewController = dependencies.viewControllerFactory.createUserProfileVC(params: .none)

        viewController.selectAvatarButtonHandler =
        { [weak self] controller in

            self?.showUserProfileAvatarSelectorVC()
        }

        viewController.saveButtonHandler =
        { [weak self] controller in

            controller.setState(.loading(nil), animated: true)

            userProfile.updateUserDetails(with: controller.userProfileMandatoryDetails)
            { result in

                if case .success(let details) = result
                {
                    controller.setState(.normal, animated: true)
                    controller.setup(userProfileDetails: details)
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

        viewController.setState(.loading(nil), animated: true)

        let controller = viewController

        userProfile.fetchUserDetails
        { [weak self] result in

            if case .success(let details) = result
            {
                controller.setState(.normal, animated: true)
                controller.setup(userProfileDetails: details)
            }

            if case .failure(let error) = result
            {
                controller.setState(.error(nil), animated: true)
                self?.showErrorAlert(error: error, in: controller)
            }
        }

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

    func updateUserProfileVC()
    {
        guard
            let userDetails = dependencies.userProfile.userDetails,
            let controllers = presenter?.viewControllers
        else
            { return }

        for viewController in controllers where viewController is UserProfileVCProtocol
        {
            (viewController as? UserProfileVCProtocol)?.setup(userProfileDetails: userDetails)
        }
    }
    
    func showInventoryScreen()
    {
        if currentViewController is InventoryVCProtocol { return }

        invalidateAllModels()
        
        let dataSource = dependencies.datasourceFactory.createInventoryListDatasource(params: .none)
        
        let params = InventoryVCBuildParams(dataSource: dataSource)
        let viewController = dependencies.viewControllerFactory.createInventoryVC(params: params)
        
        let inventoryList =
            dependencies.modelFactory.createInventoryList(params: .init(loadStateListener: viewController,
                                                                        dataSource: dataSource))
        
        inventoryList.orderPaymentHandler =
        { [weak self] createdOrder in
            self?.showPaymentBrowser(paymentToken: createdOrder.paymentToken, isSandbox: createdOrder.isSandbox)
            {
                self?.inventoryList?.requestData()
            }
        }
        
        self.inventoryList = inventoryList
        
        inventoryList.requestData()
        
        pushViewController(viewController, pushMode: .replaceCurrent)
    }
    
    func showVirtualItemsScreen()
    {
        if currentViewController is VirtualItemsVCProtocol { return }
        
        invalidateAllModels()
        
        let dataSource = dependencies.datasourceFactory.createVirtualItemsListDatasource(params: .none)
        
        let viewController =
            dependencies.viewControllerFactory.createVirtualItemsVC(params: .init(dataSource: dataSource))
        
        let virtualItemsList =
            dependencies.modelFactory.createVirtualItemsList(params: .init(loadStateListener: viewController,
                                                                           dataSource: dataSource))
        self.virtualItemsList = virtualItemsList
        
        self.virtualItemsActionHandler =
            dependencies.modelFactory.createVirtualItemsActionHandler(params: .init(dataSource: dataSource,
                                                                                    viewController: viewController,
                                                                                    virtualItemsList: virtualItemsList,
                                                                                    store: dependencies.store))
        self.virtualItemsActionHandler?.bundlePreviewRequest =
        { [weak self] bundle in guard let self = self else { return }
            
            let bundleDataSource =
                self.dependencies.datasourceFactory.createBundlePreviewDataSource(params: .init(bundle: bundle))
            
            self.previewBundle(dataSource: bundleDataSource)
        }
        
        self.virtualItemsActionHandler?.reloadDataRequest =
        { [weak self, weak virtualItemsList] in
            
            virtualItemsList?.requestData()
            self?.reloadRequestHandler?()
        }
        
        self.virtualItemsActionHandler?.orderPaymentHandler =
        { [weak self] createdOrder in
            self?.showPaymentBrowser(paymentToken: createdOrder.paymentToken, isSandbox: createdOrder.isSandbox)
        }
        
        virtualItemsList.requestData()
        
        pushViewController(viewController, pushMode: .replaceCurrent)
    }
    
    func previewBundle(dataSource: BundlePreviewDataSource)
    {
        let viewController =
            dependencies.viewControllerFactory.createBundlePreviewVC(params: .init(dataSource: dataSource))
        
        presentViewController(viewController, completion: nil)
    }
    
    func showVirtualCurrencyScreen()
    {
        if currentViewController is VirtualCurrencyVCProtocol { return }
     
        invalidateAllModels()
        
        let dataSource = dependencies.datasourceFactory.createVirtualCurrencyListDatasource(params: .none)
        
        let viewController =
            dependencies.viewControllerFactory.createVirtualCurrencyVC(params: .init(dataSource: dataSource))
        
        let virtualCurrencyList =
            dependencies.modelFactory.createVirtualCurrencyList(params: .init(loadStateListener: viewController,
                                                                              dataSource: dataSource))
        
        virtualCurrencyList.orderPaymentHandler =
        { [weak self] createdOrder in
            
            self?.showPaymentBrowser(paymentToken: createdOrder.paymentToken, isSandbox: createdOrder.isSandbox)
            {
                self?.reloadRequestHandler?()
            }
        }
        
        self.virtualCurrencyList = virtualCurrencyList
        
        virtualCurrencyList.requestData()
        
        pushViewController(viewController, pushMode: .replaceCurrent)
    }

    func showCharacterScreen()
    {
        if currentViewController is CharacterVCProtocol { return }

        invalidateAllModels()

        // Data sources

        let actionHandler: UserAttributesListDataSource.ActionHandler =
        { [weak self] action in

            switch action
            {
                case .add: self?.showAttributeEditorScreen(userAttribute: nil)
                case .edit(let attribute): self?.showAttributeEditorScreen(userAttribute: attribute)
            }
        }

        let datasourceFactory = dependencies.datasourceFactory

        let customDataSource =
            datasourceFactory.createUserAttributesListDataSource(params: .custom(actionHandler: actionHandler))

        let readonlyDataSource =
            datasourceFactory.createUserAttributesListDataSource(params: .readonly(actionHandler: actionHandler))

        // View controller
        let characterVCdParams = CharacterVCBuildParams(customDataSource: customDataSource,
                                                            readonlyDataSource: readonlyDataSource,
                                                            userProfile: dependencies.userProfile)
        let viewController = dependencies.viewControllerFactory.createCharacterVC(params: characterVCdParams)

        // Model
        let userCharacterParams = UserCharacterBuildParams(projectId: AppConfig.projectId,
                                                           userDetailsProvider: dependencies.userProfile,
                                                           loadStateListener: viewController,
                                                           customAttributesDataSource: customDataSource,
                                                           readonlyAttributesDataSource: readonlyDataSource)

        let userCharacter = dependencies.modelFactory.createUserCharacter(params: userCharacterParams)

        userCharacter.fetchUserAttributes()

        self.userCharacter = userCharacter

        pushViewController(viewController, pushMode: .replaceCurrent)
    }

    func showAttributeEditorScreen(userAttribute: UnifiedUserAttribute? = nil)
    {
        if currentViewController is AttributeEditorVCProtocol { return }

        let viewController =
            dependencies.viewControllerFactory.createAttributeEditorVC(params: .init(userAttribute: userAttribute))

        viewController.saveAttributeRequestHandler =
        { [weak self] attributeEditorVC in

            guard
                let attribute = attributeEditorVC.userAttribute,
                let userCharacter = self?.userCharacter
            else
                { return }

            userCharacter.updateUserAttributes([attribute])
            attributeEditorVC.dismiss(animated: true)
        }

        viewController.removeAttributeRequestHandler =
        { [weak self] attributeEditorVC in

            guard
                let attribute = attributeEditorVC.userAttribute,
                let userCharacter = self?.userCharacter
            else
                { return }

            userCharacter.removeUserAttributes([attribute])
            attributeEditorVC.dismiss(animated: true)
        }

        presentViewController(viewController, completion: nil)
    }

    // MARK: - Private
    
    var currentViewController: UIViewController? { presenter?.viewControllers.last }
    
    private func switchToScreen(_ screen: Screen)
    {
        switch screen
        {
            case .account: showUserProfileScreen()
            case .character: showCharacterScreen()
            case .inventory: showInventoryScreen()
            case .virtualItems: showVirtualItemsScreen()
            case .virtualCurrency: showVirtualCurrencyScreen()
        }
    }
    
    private func showPaymentBrowser(paymentToken: String, isSandbox: Bool, onSuccessCompletion: (() -> Void)? = nil)
    {
        let paystationVC = PaystationVC()
        
        paystationVC.onSuccessPurchase =
        { vc in
            vc.dismiss(animated: true, completion: nil)
            onSuccessCompletion?()
        }
        
        paystationVC.configuration = .init(paymentToken: paymentToken,
                                           redirectURL: AppConfig.paymentsRedirectURL,
                                           isSandbox: isSandbox)
        
        paystationVC.modalPresentationStyle = .formSheet
        presenter?.present(paystationVC, animated: true, completion: nil)
    }

    private func showErrorAlert(error: Error, in viewController: UIViewController)
    {
        let alert = UIAlertController(title: L10n.Alert.Error.common,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: L10n.Alert.Action.ok, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    override init(presenter: Presenter?, dependencies: Dependencies, params: Params)
    {
        super.init(presenter: presenter, dependencies: dependencies, params: params)
        dependencies.userProfile.addListener(self)
    }
}

extension MainContentCoordinator: UserProfileListener
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

extension MainContentCoordinator
{
    enum Screen
    {
        case account
        case character
        case inventory
        case virtualItems
        case virtualCurrency
    }
}

extension MainContentCoordinator
{
    struct Dependencies
    {
        let coordinatorFactory: CoordinatorFactoryProtocol
        let viewControllerFactory: ViewControllerFactoryProtocol
        let datasourceFactory: DatasourceFactoryProtocol
        let modelFactory: ModelFactoryProtocol
        let store: StoreProtocol
        let userProfile: UserProfileProtocol
    }

    typealias Params = EmptyParams
}
