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
import MaterialComponents.MaterialTabs_TabBarViewTheming

// swiftlint:disable type_name

protocol ViewControllerFactoryProtocol: AnyObject
{
    func createAuthenticationMainVC(params: AuthenticationMainVCFactoryParams) -> AuthenticationMainVCProtocol
    func createSignupVC(params: SignupVCFactoryParams) -> SignupVCProtocol
    func createLoginVC(params: LoginVCFactoryParams) -> LoginVCProtocol
    func createRecoverPasswordVC(params: RecoverPasswordVCFactoryParams) -> RecoverPasswordVCProtocol
    func createAppDeveloperSettingsVC(params: AppDeveloperSettingsVCFactoryParams) -> AppDeveloperSettingsVCProtocol
    func createMainVC(params: MainVCFactoryParams) -> MainVCProtocol
    func createMainVCContentNavigationController() -> NavigationController
    func createVirtualItemsVC(params: VirtualItemsVCFactoryParams) -> VirtualItemsVCProtocol
    func createBundlePreviewVC(params: BundlePreviewVCFactoryParams) -> BundlePreviewVCProtocol
    func createVirtualCurrencyVC(params: VirtualCurrencyVCFactoryParams) -> VirtualCurrencyVCProtocol
    func createInventoryVC(params: InventoryVCFactoryParams) -> InventoryVCProtocol
    func createSideMenuVC(params: SideMenuVCFactoryParams) -> SideMenuVCProtocol
    func createSideMenuContentVC(params: SideMenuContentVCFactoryParams) -> SideMenuContentVCProtocol
    func createSocialNetworksListVC(params: SocialNetworksListVCFactoryParams) -> SocialNetworksListVCProtocol
    func createWebBrowserVC(params: WebBrowserVCFactoryParams) -> WebBrowserVCProtocol
    func createTableviewVC(params: TableviewVCFactoryParams) -> UITableViewController
    func createTableviewVC(params: TableviewVCFactoryParams,
                           setupTableView: ((UITableView) -> Void)?) -> UITableViewController
    func createUserProfileVC(params: UserProfileVCFactoryParams) -> UserProfileVCProtocol
    func createUserProfileAvatarSelectorVC(params: UserProfileAvatarSelectorVCFactoryParams)
         -> UserProfileAvatarSelectorVCProtocol
    func createUpgradeAccountVC(params: UpgradeAccountVCFactoryParams) -> UpgradeAccountVCProtocol
    func createCharacterVC(params: CharacterVCFactoryParams) -> CharacterVCProtocol
    func createAttributeEditorVC(params: AttributeEditorVCFactoryParams) -> AttributeEditorVCProtocol
    func createAuthenticationOptionsVC(params: AuthenticationOptionsVCFactoryParams) -> AuthenticationOptionsVCProtocol
    func createOTPStartVC(params: OTPStartVCFactoryParams) -> OTPStartVCProtocol
    func createOTPInputCodeVC(params: OTPInputCodeVCFactoryParams) -> OTPInputCodeVCProtocol
    func createDevicesListVC(params: DevicesListVCFactoryParams) -> ConnectedDevicesListVCProtocol
    func createWebFlowURLCallbackListenableVC(params: WebFlowURLCallbackListenableVCFactoryParams)
         -> WebFlowURLCallbackListenableVCProtocol
}

class ViewControllerFactory: ViewControllerFactoryProtocol
{

    // MARK: - Authentication
    
    func createAuthenticationMainVC(params: AuthenticationMainVCFactoryParams) -> AuthenticationMainVCProtocol
    {
        let viewController = StoryboardScene.Authentication.main.instantiate()

        viewController.loginVC = createLoginVC(params: .none)
        viewController.signupVC = createSignupVC(params: .none)
        viewController.tabbarVC = TabbarViewController.create(with: tabbarWithDividerScheme)
        { controller in
            
            controller.tabsLayoutStyle = .fixed
            controller.containerTop = 0
        }

        commonSetup(viewController)
        return viewController
    }
    
    func createSignupVC(params: SignupVCFactoryParams) -> SignupVCProtocol
    {
        let viewController = StoryboardScene.Authentication.signup.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)

        commonSetup(viewController)
        return viewController
    }
    
    func createLoginVC(params: LoginVCFactoryParams) -> LoginVCProtocol
    {
        let viewController = StoryboardScene.Authentication.login.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)
        
        commonSetup(viewController)
        return viewController
    }
    
    func createRecoverPasswordVC(params: RecoverPasswordVCFactoryParams) -> RecoverPasswordVCProtocol
    {
        let viewController = StoryboardScene.Authentication.recoverPassword.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)
        
        commonSetup(viewController)
        return viewController
    }

    func createAuthenticationOptionsVC(params: AuthenticationOptionsVCFactoryParams) -> AuthenticationOptionsVCProtocol
    {
        let viewController = StoryboardScene.Authentication.authenticationOptionsSelector.instantiate()

        commonSetup(viewController)
        return viewController
    }

    func createOTPStartVC(params: OTPStartVCFactoryParams) -> OTPStartVCProtocol
    {
        let viewController = StoryboardScene.AuthenticationOTP.otpStart.instantiate()
        viewController.configuration = params.configuration

        commonSetup(viewController)
        return viewController
    }

    func createOTPInputCodeVC(params: OTPInputCodeVCFactoryParams) -> OTPInputCodeVCProtocol
    {
        let viewController = StoryboardScene.AuthenticationOTP.otpInputCode.instantiate()
        viewController.configuration = params.configuration

        commonSetup(viewController)
        return viewController
    }

    func createAppDeveloperSettingsVC(params: AppDeveloperSettingsVCFactoryParams) -> AppDeveloperSettingsVCProtocol
    {
        let viewController = StoryboardScene.Authentication.appDeveloperSettings.instantiate()

        let model = AppDeveloperSettingsVC.Model(oAuthClientId: "\(AppConfig.oAuth2ClientId)",
                                                 loginId: "\(AppConfig.loginId)",
                                                 projectId: "\(AppConfig.projectId)",
                                                 webshopUrl: "\(AppConfig.webshopUrl)")
        viewController.setup(with: model)

        commonSetup(viewController)
        return viewController
    }

    // MARK: - Main
    
    func createMainVC(params: MainVCFactoryParams) -> MainVCProtocol
    {
        let viewController = StoryboardScene.Main.main.instantiate()
        viewController.embedNavigationController(params.navigationController)
        
        commonSetup(viewController)
        return viewController
    }
    
    func createMainVCContentNavigationController() -> NavigationController
    {
        let navigationController = NavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }
    
    func createVirtualItemsVC(params: VirtualItemsVCFactoryParams) -> VirtualItemsVCProtocol
    {
        let viewController = StoryboardScene.VirtualItems.virtualItems.instantiate()
        
        viewController.tabbarVC = TabbarViewController.create(with: tabbarDefaultScheme)
        { controller in
            
            controller.tabsLayoutStyle = .scrollableCentered
            controller.containerTop = Shape.tabbarBottomMargin
        }
        
        viewController.viewControllerFactory = self
        viewController.dataSource = params.dataSource
        
        commonSetup(viewController)
        return viewController
    }
    
    func createBundlePreviewVC(params: BundlePreviewVCFactoryParams) -> BundlePreviewVCProtocol
    {
        let viewController = StoryboardScene.BundlePreview.bundlePreview.instantiate()
        
        viewController.dataSource = params.dataSource
        viewController.modalPresentationStyle = .overFullScreen
        viewController.dismissRequestHandler =
        { viewController in
            viewController.dismiss(animated: true, completion: nil)
        }

        commonSetup(viewController)
        return viewController
    }
    
    func createVirtualCurrencyVC(params: VirtualCurrencyVCFactoryParams) -> VirtualCurrencyVCProtocol
    {
        let viewController = StoryboardScene.VirtualCurrency.virtualCurrency.instantiate()
        
        viewController.tabbarVC = TabbarViewController.create(with: tabbarDefaultScheme)
        { controller in
            
            controller.tabsLayoutStyle = .scrollableCentered
            controller.containerTop = Shape.tabbarBottomMargin
        }
        
        viewController.viewControllerFactory = self
        viewController.dataSource = params.dataSource
        
        commonSetup(viewController)
        return viewController
    }
    
    func createInventoryVC(params: InventoryVCFactoryParams) -> InventoryVCProtocol
    {
        let viewController = StoryboardScene.Inventory.inventory.instantiate()
        
        viewController.tabbarVC = TabbarViewController.create(with: tabbarDefaultScheme)
        { controller in
            
            controller.tabsLayoutStyle = .scrollableCentered
            controller.containerTop = Shape.tabbarBottomMargin
        }
        
        viewController.viewControllerFactory = self
        viewController.dataSource = params.dataSource
        
        commonSetup(viewController)
        return viewController
    }
    
    func createSideMenuVC(params: SideMenuVCFactoryParams) -> SideMenuVCProtocol
    {
        let viewController = StoryboardScene.SideMenu.sideMenu.instantiate()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.set(contentVC: params.contentViewController)
        
        return viewController
    }
    
    func createSideMenuContentVC(params: SideMenuContentVCFactoryParams) -> SideMenuContentVCProtocol
    {
        let viewController = StoryboardScene.SideMenu.sideMenuContent.instantiate()

        return viewController
    }

    // MARK: - Misc
    
    func createSocialNetworksListVC(params: SocialNetworksListVCFactoryParams) -> SocialNetworksListVCProtocol
    {
        let viewController = StoryboardScene.SocialNetworksList.socialNetworksList.instantiate()
        
        commonSetup(viewController)
        return viewController
    }
    
    func createWebBrowserVC(params: WebBrowserVCFactoryParams) -> WebBrowserVCProtocol
    {
        let viewController = WebBrowserVC(initialURL: params)
        
        commonSetup(viewController)
        return viewController
    }

    func createTableviewVC(params: TableviewVCFactoryParams) -> UITableViewController
    {
        let viewController = BaseTableViewController(nibName: nil, bundle: nil)

        viewController.view.backgroundColor = .xsolla_clear
        return viewController
    }

    func createTableviewVC(params: TableviewVCFactoryParams,
                           setupTableView: ((UITableView) -> Void)?) -> UITableViewController
    {
        let viewController = BaseTableViewController(nibName: nil, bundle: nil)

        if let tableView = viewController.tableView { setupTableView?(tableView) }

        viewController.view.backgroundColor = .xsolla_clear
        return viewController
    }

    func createUserProfileVC(params: UserProfileVCFactoryParams) -> UserProfileVCProtocol
    {
        let viewController = StoryboardScene.UserProfile.userProfile.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)

        commonSetup(viewController)
        return viewController
    }

    func createUserProfileAvatarSelectorVC(params: UserProfileAvatarSelectorVCFactoryParams)
         -> UserProfileAvatarSelectorVCProtocol
    {
        let viewController = StoryboardScene.UserProfile.userProfileAvatarSelector.instantiate()

        viewController.modalPresentationStyle = .overFullScreen
        viewController.dismissRequestHandler =
        { viewController in
            viewController.dismiss(animated: true, completion: nil)
        }

        commonSetup(viewController)
        return viewController
    }

    func createUpgradeAccountVC(params: UpgradeAccountVCFactoryParams) -> UpgradeAccountVCProtocol
    {
        let viewController = StoryboardScene.UserProfile.upgradeAccount.instantiate()

        commonSetup(viewController)
        return viewController
    }

    func createCharacterVC(params: CharacterVCFactoryParams) -> CharacterVCProtocol
    {
        let viewController = StoryboardScene.Character.character.instantiate()
        viewController.userDetailsProvider = params.userProfile
        params.userProfile.addListener(viewController)

        let customTableVCParams = UserAttributesTableVCFactoryParams(dataSource: params.customDataSource)
        let customAttributesTableVC = createCustomUserAttributesTableVC(params: customTableVCParams)

        let readonlyTableVCParams = UserAttributesTableVCFactoryParams(dataSource: params.readonlyDataSource)
        let readonlyAttributesTableVC = createReadonlyUserAttributesTableVC(params: readonlyTableVCParams)

        let customAttributesTabbarItem = UITabBarItem(title: params.customDataSource.title,
                                                      image: nil,
                                                      selectedImage: nil)

        let readonlyAttributesTabbarItem = UITabBarItem(title: params.readonlyDataSource.title,
                                                        image: nil,
                                                        selectedImage: nil)

        viewController.tabbarVC = TabbarViewController.create(with: tabbarDefaultScheme)
        { controller in

            controller.tabsLayoutStyle = .scrollableCentered
            controller.containerTop = Shape.tabbarBottomMargin
        }

        viewController.reloadDataRequestHandler =
        {
            customAttributesTableVC.tableView.reloadData()
            readonlyAttributesTableVC.tableView.reloadData()
        }

        commonSetup(viewController)

        viewController.tabbarVC.setup(with:
        [
            .init(tabbarItem: readonlyAttributesTabbarItem, viewController: readonlyAttributesTableVC),
            .init(tabbarItem: customAttributesTabbarItem, viewController: customAttributesTableVC)
        ])
        
        return viewController
    }

    func createCustomUserAttributesTableVC(params: UserAttributesTableVCFactoryParams) -> UITableViewController
    {
        let viewController = createTableviewVC(params: .none)

        guard let tableView = viewController.tableView else { fatalError("TableView in UITableViewController is nil") }

        tableView.dataSource = params.dataSource
        tableView.delegate = params.dataSource
        tableView.registerXib(for: UserAttributeListAddAttributeCell.self)
        tableView.registerXib(for: UserAttributeListItemCell.self)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none

        return viewController
    }

    func createReadonlyUserAttributesTableVC(params: UserAttributesTableVCFactoryParams) -> UITableViewController
    {
        let viewController = createTableviewVC(params: .none)

        guard let tableView = viewController.tableView else { fatalError("TableView in UITableViewController is nil") }

        tableView.dataSource = params.dataSource
        tableView.delegate = params.dataSource
        tableView.registerXib(for: UserAttributeListInfoCell.self)
        tableView.registerXib(for: UserAttributeListItemCell.self)
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .none

        return viewController
    }

    func createAttributeEditorVC(params: AttributeEditorVCFactoryParams) -> AttributeEditorVCProtocol
    {
        let viewController = StoryboardScene.Character.attributeEditor.instantiate()

        viewController.modalPresentationStyle = .overFullScreen
        viewController.dismissRequestHandler =
        { viewController in
            viewController.dismiss(animated: true, completion: nil)
        }
        
        viewController.initialUserAttribute = params.userAttribute
        
        commonSetup(viewController)
        return viewController
    }
    
    func createDevicesListVC(params: DevicesListVCFactoryParams) -> ConnectedDevicesListVCProtocol
    {
        let viewController = StoryboardScene.UserProfile.connectedDevicesList.instantiate()
        
        commonSetup(viewController)
        return viewController
    }

    func createWebFlowURLCallbackListenableVC(params: WebFlowURLCallbackListenableVCFactoryParams)
         -> WebFlowURLCallbackListenableVCProtocol
    {
        let webViewController = WebFlowURLCallbackListenableVC(nibName: nil, bundle: nil)

        webViewController.configureMainView
        { view in
            view.backgroundColor = .xsolla_nightBlue
        }

        webViewController.configureWebView
        { webView in
            webView.customUserAgent = params.useragent
        }

        webViewController.configureDismissButton
        { button in

            button.setTitle(nil, for: .normal)
            button.setImage(Asset.Images.dismissButtonIcon.image, for: .normal)
            button.tintColor = .xsolla_inactiveWhite
        }

        return webViewController
    }

    private func commonSetup(_ viewController: BaseViewController)
    {
        viewController.view.backgroundColor = .xsolla_black
    }
    
    // MARK: - Theming
    
    private var tabbarDefaultScheme: MDCContainerScheme =
    {
        let scheme = MDCContainerScheme()
        
        scheme.colorScheme.surfaceColor = .xsolla_black
        scheme.colorScheme.primaryColor = .xsolla_white
        scheme.colorScheme.onSurfaceColor = .xsolla_inactiveWhite
        scheme.colorScheme.onBackgroundColor = .xsolla_clear

        scheme.typographyScheme.button = .xolla_button
        
        return scheme
    }()
    
    private var tabbarWithDividerScheme: MDCContainerScheme =
    {
        let scheme = MDCContainerScheme()
        
        scheme.colorScheme.surfaceColor = .xsolla_clear
        scheme.colorScheme.primaryColor = .xsolla_white
        scheme.colorScheme.onSurfaceColor = .xsolla_inactiveWhite
        scheme.colorScheme.onBackgroundColor = .xsolla_inactiveWhite
        
        scheme.typographyScheme.button = .xolla_button
        
        return scheme
    }()
    
    // MARK: - Private fields
    
    let validatorFactory = UserInputValidatorFactory()
    
    // MARK: - Initialization
    
    let params: Params
    
    init(params: Params)
    {
        self.params = params
    }
}

extension ViewControllerFactory
{
    typealias Params = EmptyParams
}

typealias AuthenticationMainVCFactoryParams = EmptyParams
typealias SocialNetworksListVCFactoryParams = EmptyParams
typealias SignupVCFactoryParams = EmptyParams
typealias LoginVCFactoryParams = EmptyParams
typealias RecoverPasswordVCFactoryParams = EmptyParams
typealias SideMenuContentVCFactoryParams = EmptyParams
typealias WebBrowserVCFactoryParams = URL?
typealias TableviewVCFactoryParams = EmptyParams
typealias UserProfileVCFactoryParams = EmptyParams
typealias UserProfileAvatarSelectorVCFactoryParams = EmptyParams
typealias UpgradeAccountVCFactoryParams = EmptyParams
typealias DevicesListVCFactoryParams = EmptyParams

typealias AppDeveloperSettingsVCFactoryParams = EmptyParams

struct MainVCFactoryParams
{
    let navigationController: NavigationController
}

struct SideMenuVCFactoryParams
{
    let contentViewController: BaseViewController
}

struct InventoryVCFactoryParams
{
    let dataSource: InventoryListDataSourceProtocol
}

struct VirtualCurrencyVCFactoryParams
{
    let dataSource: VirtualCurrencyListDataSourceProtocol
}

struct VirtualItemsVCFactoryParams
{
    let dataSource: VirtualItemsListDataSourceProtocol
}

struct BundlePreviewVCFactoryParams
{
    let dataSource: BundlePreviewDataSource
}

struct UserAttributesTableVCFactoryParams
{
    let dataSource: UserAttributesListDataSource
}

struct CharacterVCFactoryParams
{
    let customDataSource: UserAttributesListDataSource
    let readonlyDataSource: UserAttributesListDataSource
    let userProfile: UserProfileProtocol
}

struct AttributeEditorVCFactoryParams
{
    let userAttribute: UnifiedUserAttribute?
}

struct AuthenticationOptionsVCFactoryParams
{

}

struct OTPStartVCFactoryParams
{
    let configuration: OTPSequenceConfiguration
}

struct OTPInputCodeVCFactoryParams
{
    let configuration: OTPSequenceConfiguration
}

struct WebFlowURLCallbackListenableVCFactoryParams
{
    let useragent: String?
}
