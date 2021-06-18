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

protocol ViewControllerFactoryProtocol: AnyObject
{
    func createAuthenticationMainVC(params: AuthenticationMainVCBuildParams) -> AuthenticationMainVCProtocol
    func createSignupVC(params: SignupVCBuildParams) -> SignupVCProtocol
    func createLoginVC(params: LoginVCBuildParams) -> LoginVCProtocol
    func createRecoverPasswordVC(params: RecoverPasswordVCBuildParams) -> RecoverPasswordVCProtocol
    func createMainVC(params: MainVCBuildParams) -> MainVCProtocol
    func createMainVCContentNavigationController() -> NavigationController
    func createVirtualItemsVC(params: VirtualItemsVCBuildParams) -> VirtualItemsVCProtocol
    func createBundlePreviewVC(params: BundlePreviewVCBuildParams) -> BundlePreviewVCProtocol
    func createVirtualCurrencyVC(params: VirtualCurrencyVCBuildParams) -> VirtualCurrencyVCProtocol
    func createInventoryVC(params: InventoryVCBuildParams) -> InventoryVCProtocol
    func createSideMenuVC(params: SideMenuVCBuildParams) -> SideMenuVCProtocol
    func createSideMenuContentVC(params: SideMenuContentVCBuildParams) -> SideMenuContentVCProtocol
    func createSocialNetworksListVC(params: SocialNetworksListVCBuildParams) -> SocialNetworksListVCProtocol
    func createWebBrowserVC(params: WebBrowserVCBuildParams) -> WebBrowserVCProtocol
    func createTableviewVC(params: TableviewVCBuildParams) -> UITableViewController
    func createTableviewVC(params: TableviewVCBuildParams,
                           setupTableView: ((UITableView) -> Void)?) -> UITableViewController
    func createUserProfileVC(params: UserProfileVCBuildParams) -> UserProfileVCProtocol
    func createUserProfileAvatarSelectorVC(params: UserProfileAvatarSelectorVCBuildParams)
         -> UserProfileAvatarSelectorVCProtocol
    func createCharacterVC(params: CharacterVCBuildParams) -> CharacterVCProtocol
    func createAttributeEditorVC(params: AttributeEditorVCBuildParams) -> AttributeEditorVCProtocol
}

class ViewControllerFactory: ViewControllerFactoryProtocol
{
    // MARK: - Authentication
    
    func createAuthenticationMainVC(params: AuthenticationMainVCBuildParams) -> AuthenticationMainVCProtocol
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
    
    func createSignupVC(params: SignupVCBuildParams) -> SignupVCProtocol
    {
        let viewController = StoryboardScene.Authentication.signup.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)

        commonSetup(viewController)
        return viewController
    }
    
    func createLoginVC(params: LoginVCBuildParams) -> LoginVCProtocol
    {
        let viewController = StoryboardScene.Authentication.login.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)
        
        commonSetup(viewController)
        return viewController
    }
    
    func createRecoverPasswordVC(params: RecoverPasswordVCBuildParams) -> RecoverPasswordVCProtocol
    {
        let viewController = StoryboardScene.Authentication.recoverPassword.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)
        
        commonSetup(viewController)
        return viewController
    }
    
    // MARK: - Main
    
    func createMainVC(params: MainVCBuildParams) -> MainVCProtocol
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
    
    func createVirtualItemsVC(params: VirtualItemsVCBuildParams) -> VirtualItemsVCProtocol
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
    
    func createBundlePreviewVC(params: BundlePreviewVCBuildParams) -> BundlePreviewVCProtocol
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
    
    func createVirtualCurrencyVC(params: VirtualCurrencyVCBuildParams) -> VirtualCurrencyVCProtocol
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
    
    func createInventoryVC(params: InventoryVCBuildParams) -> InventoryVCProtocol
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
    
    func createSideMenuVC(params: SideMenuVCBuildParams) -> SideMenuVCProtocol
    {
        let viewController = StoryboardScene.SideMenu.sideMenu.instantiate()
        viewController.modalPresentationStyle = .overFullScreen
        viewController.set(contentVC: params.contentViewController)
        
        return viewController
    }
    
    func createSideMenuContentVC(params: SideMenuContentVCBuildParams) -> SideMenuContentVCProtocol
    {
        let viewController = StoryboardScene.SideMenu.sideMenuContent.instantiate()

        return viewController
    }

    // MARK: - Misc
    
    func createSocialNetworksListVC(params: SocialNetworksListVCBuildParams) -> SocialNetworksListVCProtocol
    {
        let viewController = SocialNetworksListVC()
        viewController.dataSource = SocialNetworksListDataSource.init(socialNetworks: params)
        
        commonSetup(viewController)
        return viewController
    }
    
    func createWebBrowserVC(params: WebBrowserVCBuildParams) -> WebBrowserVCProtocol
    {
        let viewController = WebBrowserVC(initialURL: params)
        
        commonSetup(viewController)
        return viewController
    }

    func createTableviewVC(params: TableviewVCBuildParams) -> UITableViewController
    {
        let viewController = BaseTableViewController(nibName: nil, bundle: nil)

        viewController.view.backgroundColor = .xsolla_clear
        return viewController
    }

    func createTableviewVC(params: TableviewVCBuildParams,
                           setupTableView: ((UITableView) -> Void)?) -> UITableViewController
    {
        let viewController = BaseTableViewController(nibName: nil, bundle: nil)

        if let tableView = viewController.tableView { setupTableView?(tableView) }

        viewController.view.backgroundColor = .xsolla_clear
        return viewController
    }

    func createUserProfileVC(params: UserProfileVCBuildParams) -> UserProfileVCProtocol
    {
        let viewController = StoryboardScene.UserProfile.userProfile.instantiate()
        viewController.formValidator = FormValidator(factory: validatorFactory)

        commonSetup(viewController)
        return viewController
    }

    func createUserProfileAvatarSelectorVC(params: UserProfileAvatarSelectorVCBuildParams)
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

    func createCharacterVC(params: CharacterVCBuildParams) -> CharacterVCProtocol
    {
        let viewController = StoryboardScene.Character.character.instantiate()
        viewController.userDetailsProvider = params.userProfile
        params.userProfile.addListener(viewController)

        let customTableVCParams = UserAttributesTableVCBuildParams(dataSource: params.customDataSource)
        let customAttributesTableVC = createCustomUserAttributesTableVC(params: customTableVCParams)

        let readonlyTableVCParams = UserAttributesTableVCBuildParams(dataSource: params.readonlyDataSource)
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

    func createCustomUserAttributesTableVC(params: UserAttributesTableVCBuildParams) -> UITableViewController
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

    func createReadonlyUserAttributesTableVC(params: UserAttributesTableVCBuildParams) -> UITableViewController
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

    func createAttributeEditorVC(params: AttributeEditorVCBuildParams) -> AttributeEditorVCProtocol
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

    private func commonSetup(_ viewController: BaseViewController)
    {
        viewController.view.backgroundColor = .xsolla_black
    }
    
    // MARK: - Theming
    
    private var tabbarDefaultScheme: MDCContainerScheme =
    {
        let scheme = MDCContainerScheme()
        
        scheme.colorScheme.surfaceColor = .xsolla_black
        scheme.colorScheme.primaryColor = .xsolla_magenta
        scheme.colorScheme.onSurfaceColor = .xsolla_lightSlateGrey
        scheme.colorScheme.onBackgroundColor = .xsolla_clear

        scheme.typographyScheme.button = .xolla_button
        
        return scheme
    }()
    
    private var tabbarWithDividerScheme: MDCContainerScheme =
    {
        let scheme = MDCContainerScheme()
        
        scheme.colorScheme.surfaceColor = .xsolla_clear
        scheme.colorScheme.primaryColor = .xsolla_magenta
        scheme.colorScheme.onSurfaceColor = .xsolla_lightSlateGrey
        scheme.colorScheme.onBackgroundColor = .xsolla_lightSlateGrey
        
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

typealias AuthenticationMainVCBuildParams = EmptyParams
typealias SocialNetworksListVCBuildParams = [SocialNetwork]
typealias SignupVCBuildParams = EmptyParams
typealias LoginVCBuildParams = EmptyParams
typealias RecoverPasswordVCBuildParams = EmptyParams
typealias SideMenuContentVCBuildParams = EmptyParams
typealias WebBrowserVCBuildParams = URL?
typealias TableviewVCBuildParams = EmptyParams
typealias UserProfileVCBuildParams = EmptyParams
typealias UserProfileAvatarSelectorVCBuildParams = EmptyParams

struct MainVCBuildParams
{
    let navigationController: NavigationController
}

struct SideMenuVCBuildParams
{
    let contentViewController: BaseViewController
}

struct InventoryVCBuildParams
{
    let dataSource: InventoryListDataSourceProtocol
}

struct VirtualCurrencyVCBuildParams
{
    let dataSource: VirtualCurrencyListDataSourceProtocol
}

struct VirtualItemsVCBuildParams
{
    let dataSource: VirtualItemsListDataSourceProtocol
}

struct BundlePreviewVCBuildParams
{
    let dataSource: BundlePreviewDataSource
}

struct UserAttributesTableVCBuildParams
{
    let dataSource: UserAttributesListDataSource
}

struct CharacterVCBuildParams
{
    let customDataSource: UserAttributesListDataSource
    let readonlyDataSource: UserAttributesListDataSource
    let userProfile: UserProfileProtocol
}

struct AttributeEditorVCBuildParams
{
    let userAttribute: UnifiedUserAttribute?
}
