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

protocol CharacterVCProtocol: BaseViewController, LoadStatable
{

}

class CharacterVC: BaseViewController, CharacterVCProtocol
{
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var tabbarViewControllerContainer: UIView!
    @IBOutlet private weak var avatarButtonView: AvatarButtonView!
    @IBOutlet private weak var nicknameLabel: UILabel!

    weak var userDetailsProvider: UserProfileDetailsProvider?
    var tabbarVC: TabbarViewController!
    private var tabbarChildViewControllers: [UIViewController] = []

    var reloadDataRequestHandler: (() -> Void)?

    var loadState: LoadState = .normal
    private var activityVC: ActivityIndicatingViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        titleLabel.attributedText = L10n.Character.title.attributed(Style.heading1.align(.left), color: .xsolla_white)

        setupTabbarViewController()

        avatarButtonView.primaryImage = Asset.Images.avatarPlaceholder.image
        updateUserProfileSection()
    }

    func updateUserProfileSection()
    {
        if let avatarLink = userDetailsProvider?.userDetails?.picture
        {
            SDWebImageDownloader.shared.downloadImage(with: URL(string: avatarLink))
            { [weak self] (image, _, _, _) in
                if let image = image { self?.avatarButtonView.primaryImage = image }
            }
        }
        
        let nickname = userDetailsProvider?.userDetails?.nickname
        nicknameLabel.attributedText = nickname?.attributed(.heading2, color: .xsolla_white)
    }

    // MARK: - Setup

    private func setupTabbarViewController()
    {
        addChild(tabbarVC)
        tabbarViewControllerContainer.addSubview(tabbarVC.view)
        tabbarVC.view.pinToSuperview()
        tabbarVC.didMove(toParent: self)
    }
}

extension CharacterVC: LoadStatable
{
    func getState() -> LoadState
    {
        loadState
    }

    func setState(_ state: LoadState, animated: Bool)
    {
        loadState = state
        updateLoadState(animated)
    }

    func updateLoadState(_ animated: Bool = false)
    {
        switch loadState
        {
            case .normal, .error: do
            {
                reloadDataRequestHandler?()
                activityVC?.hide(animated: true)
                activityVC = nil
            }

            case .loading: do
            {
                guard activityVC == nil else { return }
                activityVC = ActivityIndicatingViewController.presentEmbedded(in: self, embeddingMode: .over)
            }
        }
    }
}

extension CharacterVC: EmbeddableControllerContainerProtocol
{
    func getContaiterViewForEmbeddableViewController() -> UIView?
    {
        view
    }
}

extension CharacterVC: UserProfileListener
{
    func userProfileDidUpdateDetails(_ userProfile: UserProfileProtocol)
    {
        updateUserProfileSection()
    }
}
