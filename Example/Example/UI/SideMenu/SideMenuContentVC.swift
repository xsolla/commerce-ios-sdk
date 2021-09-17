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
import SDWebImage
import XsollaSDKLoginKit

protocol SideMenuContentVCProtocol: BaseViewController
{
    var profileMenuItemHandler: (() -> Void)? { get set }
    var characterMenuItemHandler: (() -> Void)? { get set }
    var inventoryMenuItemHandler: (() -> Void)? { get set }
    var virtualItemsMenuItemHandler: (() -> Void)? { get set }
    var virtualCurrencyMenuItemHandler: (() -> Void)? { get set }
    var logoutMenuItemHandler: (() -> Void)? { get set }
    
    func setProfileInfo(name: String?, email: String?, avatarUrl: URL?, message: String?)
}

class SideMenuContentVC: BaseViewController, SideMenuContentVCProtocol
{
    var profileMenuItemHandler: (() -> Void)?
    var characterMenuItemHandler: (() -> Void)?
    var inventoryMenuItemHandler: (() -> Void)?
    var virtualItemsMenuItemHandler: (() -> Void)?
    var virtualCurrencyMenuItemHandler: (() -> Void)?
    var logoutMenuItemHandler: (() -> Void)?
    
    func setProfileInfo(name: String?, email: String?, avatarUrl: URL?, message: String?)
    {
        self.profileName = name
        self.profileEmail = email
        self.profileMessage = message
        self.profileAvatarURL = avatarUrl
        updateProfileInfo()
    }
    
    private var profileName: String?
    private var profileEmail: String?
    private var profileMessage: String?
    private var profileAvatarURL: URL?
    
    @IBOutlet private weak var profileContainerView: UIView!
    @IBOutlet private weak var profileAvatarButtonView: AvatarButtonView!
    @IBOutlet private weak var profileMessageLabel: UILabel!
    @IBOutlet private weak var profileUsernameLabel: UILabel!
    @IBOutlet private weak var profileEmailLabel: UILabel!
    @IBOutlet private weak var characterSection: ExpandableMenuItemsSectionView!
    @IBOutlet private weak var inventorySection: ExpandableMenuItemsSectionView!
    @IBOutlet private weak var storeSection: ExpandableMenuItemsSectionView!
    @IBOutlet private weak var logoutSection: ExpandableMenuItemsSectionView!
    @IBOutlet private weak var versionInfoLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setupCharacterSection()
        setupInventorySection()
        setupStoreSection()
        setupProfileSection()
        setupLogoutSection()
        updateProfileInfo()

        let version = "SDK version: \(LoginKit.version)"
        versionInfoLabel.attributedText = version.attributed(.notification, color: .xsolla_onSurfaceDisabled)
    }

    func setupProfileSection()
    {
        profileContainerView.addTapHandler { [weak self] in self?.profileMenuItemHandler?() }
    }

    func setupCharacterSection()
    {
        let section = characterSection!

        let title = L10n.Menu.Item.character
        let sectionTitle = MenuItemView(title: title, image: Asset.Images.menuCharacterIcon.image, height: 40)

        let view = ExpandableMenuItemsSectionView.View(view: sectionTitle, tapHandler: characterMenuItemHandler)

        section.setup(withTitleView: view, items: [])
    }
    
    func setupInventorySection()
    {
        let section = inventorySection!
        
        let title = L10n.Menu.Item.inventory
        let sectionTitle = MenuItemView(title: title,
                                        image: Asset.Images.menuInventoryIcon.image,
                                        height: 40)
        let titleView = ExpandableMenuItemsSectionView.View(view: sectionTitle, tapHandler: inventoryMenuItemHandler)
        section.setup(withTitleView: titleView, items: [])
    }
    
    func setupStoreSection()
    {
        let section = storeSection!

        var sectionItems = [ExpandableMenuItemsSectionView.View]()

        do
        {
            let title = L10n.Menu.Item.virtualItems
            let view = MenuItemView(title: title, height: 40)
            view.textColorNormal = .xsolla_lightSlateGrey
            sectionItems.append(ExpandableMenuItemsSectionView.View(view: view,
                                                                    tapHandler: virtualItemsMenuItemHandler))
        }

        do
        {
            let title = L10n.Menu.Item.virtualCurrency
            let view = MenuItemView(title: title, height: 40)
            view.textColorNormal = .xsolla_lightSlateGrey
            sectionItems.append(ExpandableMenuItemsSectionView.View(view: view,
                                                                    tapHandler: virtualCurrencyMenuItemHandler))
        }
        
        let title = L10n.Menu.Item.store
        let sectionTitle = MenuItemView(title: title, image: Asset.Images.menuStoreIcon.image, height: 40)
        section.setup(withTitleView: ExpandableMenuItemsSectionView.View(view: sectionTitle),
                      items: sectionItems)
        section.expand(animated: false)
    }
    
    func setupLogoutSection()
    {
        let section = logoutSection!

        let title = L10n.Menu.Item.logout
        let sectionTitle = MenuItemView(title: title, image: Asset.Images.menuLogoutIcon.image, height: 40)
        
        section.setup(withTitleView: ExpandableMenuItemsSectionView.View(view: sectionTitle,
                                                                         tapHandler: logoutMenuItemHandler), items: [])
    }
    
    func updateProfileInfo()
    {
        guard isViewLoaded else { return }

        profileAvatarButtonView.primaryImage = Asset.Images.avatarPlaceholder.image
        profileAvatarButtonView.isUserInteractionEnabled = false

        SDWebImageDownloader.shared.downloadImage(with: profileAvatarURL)
        { [weak self] (image, _, _, _) in
            self?.profileAvatarButtonView.primaryImage = image ?? Asset.Images.avatarPlaceholder.image
        }

        if profileMessage != nil
        {
            profileUsernameLabel.isHidden = true
            profileEmailLabel.isHidden = true
            profileMessageLabel.isHidden = false

            profileMessageLabel.attributedText = profileMessage?.attributed(.link, color: .xsolla_magenta)
            profileUsernameLabel.attributedText = nil
            profileEmailLabel.attributedText = nil
        }
        else
        {
            profileUsernameLabel.isHidden = false
            profileEmailLabel.isHidden = false
            profileMessageLabel.isHidden = true

            profileMessageLabel.attributedText = nil
            profileUsernameLabel.attributedText = profileName?.attributed(.button, color: .xsolla_onSurfaceHigh)
            profileEmailLabel.attributedText = profileEmail?.attributed(.link, color: .xsolla_lightSlateGrey)
        }
    }
}
