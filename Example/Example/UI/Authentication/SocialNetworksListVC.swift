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

protocol SocialNetworksListVCProtocol: BaseViewController
{
    var dataSource: SocialNetworksListDataSource { get set }
    var onSocialNetwork: ((SocialNetwork) -> Void)? { get set }
}

class SocialNetworksListVC: BaseViewController, SocialNetworksListVCProtocol
{
    var dataSource: SocialNetworksListDataSource = .init(socialNetworks: [.linkedin, .twitter])
    
    var onSocialNetwork: ((SocialNetwork) -> Void)?
    
    private var buttonSize: CGSize = .init(width: 60, height: 60)
    
    var collectionView: UICollectionView =
    {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView()
    {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SocialNetworkCell.self,
                                forCellWithReuseIdentifier: SocialNetworkCell.reuseIdentifier)
        
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 20, right: 20)
        collectionView.backgroundColor = .xsolla_inputFieldNormal
        
        view.addSubview(collectionView)
        collectionView.pinToSuperview()
    }
    
    private func getImage(for socialNetwork: SocialNetwork) -> UIImage
    {
        switch socialNetwork
        {
            case .baidu: return Asset.Images.socialBaiduIcon.image
            case .facebook: return Asset.Images.socialFacebookIcon.image
            case .google: return Asset.Images.socialGoogleIcon.image
            case .linkedin: return Asset.Images.socialLinkedinIcon.image
            case .twitter: return Asset.Images.socialTwitterIcon.image
        }
    }
}

extension SocialNetworksListVC: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return dataSource.socialNetworks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SocialNetworkCell.reuseIdentifier,
                                                      for: indexPath)
        
        if let socialNetworkCell = cell as? SocialNetworkCell
        {
            let socialNetwork = dataSource.socialNetworks[indexPath.item]
            socialNetworkCell.button.setImage(getImage(for: socialNetwork), for: .normal)
            socialNetworkCell.onButton = { [weak self] in self?.onSocialNetwork?(socialNetwork) }
        }
        
        return cell
    }
}

extension SocialNetworksListVC: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return buttonSize
    }
}

struct SocialNetworksListDataSource
{
    let socialNetworks: [SocialNetwork]
    
    init(socialNetworks: [SocialNetwork])
    {
        self.socialNetworks = socialNetworks
    }
}

class SocialNetworkCell: UICollectionViewCell
{
    public static let reuseIdentifier = "SocialNetworkCell"
    
    let button = Button()
    
    var onButton: (() -> Void)?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit()
    {
        contentView.addSubview(button)
        button.pinToSuperview()
        
        button.setupAppearance(config: Button.largeOutlined)
        button.addTarget(self, action: #selector(onButtonHandler), for: .touchUpInside)
    }
    
    @objc
    func onButtonHandler()
    {
        onButton?()
    }
}
