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

protocol UserProfileAvatarSelectorVCProtocol: BaseViewController, LoadStatable
{
    var selectedAvatarIndex: Int? { get }
    var dismissRequestHandler: ((UserProfileAvatarSelectorVCProtocol) -> Void)? { get set }
    var selectAvatarButtonHandler: ((UserProfileAvatarSelectorVCProtocol) -> Void)? { get set }
    var removeAvatarButtonHandler: ((UserProfileAvatarSelectorVCProtocol) -> Void)? { get set }

    func updateUserAvatar(link: String?)
}

class UserProfileAvatarSelectorVC: BaseViewController, UserProfileAvatarSelectorVCProtocol
{
    // MARK: - UserProfileAvatarSelectorVCProtocol

    var selectedAvatarIndex: Int?
    var dismissRequestHandler: ((UserProfileAvatarSelectorVCProtocol) -> Void)?
    var selectAvatarButtonHandler: ((UserProfileAvatarSelectorVCProtocol) -> Void)?
    var removeAvatarButtonHandler: ((UserProfileAvatarSelectorVCProtocol) -> Void)?

    func updateUserAvatar(link: String?)
    {
        if let avatarLink = link, let url = URL(string: avatarLink)
        {
            userAvatarButtonView.primaryImage = Asset.Images.avatarPlaceholderLarge.image

            SDWebImageDownloader.shared.downloadImage(with: url)
            { [weak self] (image, _, _, _) in

                guard let image = image else { return }
                self?.userAvatarButtonView.primaryImage = image
            }
        }
        else
        {
            userAvatarButtonView.primaryImage = Asset.Images.avatarPlaceholderLarge.image
        }
    }

    // MARK: - LoadStatable

    var loadState: LoadState = .normal

    // MARK: - Private fields

    @IBOutlet private weak var titleLabel: UILabel!

    @IBOutlet private var avatarImageViews: [AvatarButtonView]!
    @IBOutlet private weak var userAvatarButtonView: AvatarButtonView!
    @IBOutlet private weak var removeAvatarButton: UIButton!

    private var activityVC: ActivityIndicatingViewController?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        titleLabel.attributedText = L10n.AccountAvatar.title
            .attributed(.heading1, color: .xsolla_white)
            .aligned(.center)

        setupAvatarButtons()
        setupRemoveAvatarButton()
    }

    private func setupAvatarButtons()
    {
        for avatarImageView in avatarImageViews
        {
            // swiftlint:disable:next image_name_initialization
            let image = UIImage(named: "avatar_\(avatarImageView.tag).png")
            avatarImageView.primaryImage = image
            avatarImageView.onTap =
            { [weak self] _ in guard let self = self else { return }
                self.selectedAvatarIndex = avatarImageView.tag
                self.selectAvatarButtonHandler?(self)
            }
        }

        // swiftlint:disable:next image_name_initialization
        userAvatarButtonView.primaryImage = UIImage(named: "avatar_0.png")
    }

    private func setupRemoveAvatarButton()
    {
        removeAvatarButton.setTitle(L10n.AccountAvatar.RemoveButton.title, for: .normal)
        removeAvatarButton.setTitleColor(.xsolla_lightSlateGrey, for: .normal)
        removeAvatarButton.layer.borderWidth = 1
        removeAvatarButton.layer.borderColor = UIColor.xsolla_darkSlateBlue.cgColor
        removeAvatarButton.layer.cornerRadius = Shape.smallCornerRadius
    }

    @IBAction private func onDismissButton(_ sender: UIButton)
    {
        dismissRequestHandler?(self)
    }

    @IBAction private func onRemoveButton(_ sender: UIButton)
    {
        removeAvatarButtonHandler?(self)
    }
}

extension UserProfileAvatarSelectorVC: LoadStatable
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

extension UserProfileAvatarSelectorVC: EmbeddableControllerContainerProtocol
{
    func getContaiterViewForEmbeddableViewController() -> UIView?
    {
        view
    }
}
