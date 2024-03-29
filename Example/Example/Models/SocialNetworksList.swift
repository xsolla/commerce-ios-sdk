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

import Foundation
import UIKit

protocol SocialNetworksListProtocol: AnyObject
{
    func setup(socialNetworks: [SocialNetwork])
    func search(searchText: String) -> [SocialNetworksListRow]
}

class SocialNetworksList: SocialNetworksListProtocol
{
    var onSocialNetworkSelect: ((SocialNetwork) -> Void)?
    
    func setup(socialNetworks: [SocialNetwork])
    {
        self.socialNetworks = socialNetworks
    }
    
    func search(searchText: String) -> [SocialNetworksListRow]
    {
        if searchText.isEmpty
        {
            return socialNetworks.map
            {
                let attributedTitle = $0.title.attributed(.button, color: textColor)
                return SocialNetworksListRow(socialNetwork: $0,
                                             attributedTitle: attributedTitle,
                                             icon: $0.icon(colored: iconColor))
            }
        }
        else
        {
            return socialNetworks.compactMap
            {
                if $0.title.lowercased().contains(searchText.lowercased())
                {
                    let attributedTitle = $0.title.attributed(.button, color: textColor)
                    return SocialNetworksListRow(socialNetwork: $0,
                                                 attributedTitle: attributedTitle,
                                                 icon: $0.icon(colored: iconColor))
                }
                else
                {
                    return nil
                }
            }
        }
    }
    
    private var socialNetworks: [SocialNetwork] = []
    private var rows: [SocialNetworksListRow] = []
    private var iconColor: UIColor = .xsolla_inactiveWhite
    private var textColor: UIColor = .xsolla_inactiveWhite
    
    // MARK: - Initialization
    
    init()
    {
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
    }

    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}
