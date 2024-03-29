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

enum SocialNetwork: String, CaseIterable
{
    case amazon
    case apple
    case baidu
    case battlenet
    case discord
    case facebook
    case github
    case google
    case kakao
    case linkedin
    case mailru
    case microsoft
    case msn
    case naver
    case ok
    case paypal
    case qq
    case reddit
    case steam
    case twitch
    case twitter
    case vimeo
    case vk
    case wechat
    case weibo
    case yahoo
    case yandex
    case youtube
    case xbox
}

extension SocialNetwork
{
    var title: String
    {
        switch self
        {
            case .amazon: return L10n.SocialNetwork.amazon
            case .apple: return L10n.SocialNetwork.apple
            case .baidu: return L10n.SocialNetwork.baidu
            case .battlenet: return L10n.SocialNetwork.battlenet
            case .discord: return L10n.SocialNetwork.discord
            case .facebook: return L10n.SocialNetwork.facebook
            case .github: return L10n.SocialNetwork.github
            case .google: return L10n.SocialNetwork.google
            case .kakao: return L10n.SocialNetwork.kakao
            case .linkedin: return L10n.SocialNetwork.linkedin
            case .mailru: return L10n.SocialNetwork.mailru
            case .microsoft: return L10n.SocialNetwork.microsoft
            case .msn: return L10n.SocialNetwork.msn
            case .naver: return L10n.SocialNetwork.naver
            case .ok: return L10n.SocialNetwork.ok
            case .paypal: return L10n.SocialNetwork.paypal
            case .qq: return L10n.SocialNetwork.qq
            case .reddit: return L10n.SocialNetwork.reddit
            case .steam: return L10n.SocialNetwork.steam
            case .twitch: return L10n.SocialNetwork.twitch
            case .twitter: return L10n.SocialNetwork.twitter
            case .vimeo: return L10n.SocialNetwork.vimeo
            case .vk: return L10n.SocialNetwork.vk
            case .wechat: return L10n.SocialNetwork.wechat
            case .weibo: return L10n.SocialNetwork.weibo
            case .xbox: return L10n.SocialNetwork.xbox
            case .yahoo: return L10n.SocialNetwork.yahoo
            case .yandex: return L10n.SocialNetwork.yandex
            case .youtube: return L10n.SocialNetwork.youtube
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func icon(colored color: UIColor) -> UIImage
    {
        switch self
        {
            case .amazon: return Asset.Images.socialAmazonIcon.tinted(color)
            case .apple: return Asset.Images.socialAppleIcon.tinted(color)
            case .baidu: return Asset.Images.socialBaiduIcon.tinted(color)
            case .battlenet: return Asset.Images.socialBattlenetIcon.tinted(color)
            case .discord: return Asset.Images.socialDiscordIcon.tinted(color)
            case .facebook: return Asset.Images.socialFacebookIcon.tinted(color)
            case .github: return Asset.Images.socialGithubIcon.tinted(color)
            case .google: return Asset.Images.socialGoogleIcon.tinted(color)
            case .kakao: return Asset.Images.socialKakaoIcon.tinted(color)
            case .linkedin: return Asset.Images.socialLinkedinIcon.tinted(color)
            case .mailru: return Asset.Images.socialMailruIcon.tinted(color)
            case .microsoft: return Asset.Images.socialMicrosoftIcon.tinted(color)
            case .msn: return Asset.Images.socialMsnIcon.tinted(color)
            case .naver: return Asset.Images.socialNaverIcon.tinted(color)
            case .ok: return Asset.Images.socialOkIcon.tinted(color)
            case .paypal: return Asset.Images.socialPaypalIcon.tinted(color)
            case .qq: return Asset.Images.socialQqIcon.tinted(color)
            case .reddit: return Asset.Images.socialRedditIcon.tinted(color)
            case .steam: return Asset.Images.socialSteamIcon.tinted(color)
            case .twitch: return Asset.Images.socialTwitchIcon.tinted(color)
            case .twitter: return Asset.Images.socialTwitterIcon.tinted(color)
            case .vimeo: return Asset.Images.socialVimeoIcon.tinted(color)
            case .vk: return Asset.Images.socialVkIcon.tinted(color)
            case .wechat: return Asset.Images.socialWechatIcon.tinted(color)
            case .weibo: return Asset.Images.socialWeiboIcon.tinted(color)
            case .xbox: return Asset.Images.socialXboxIcon.tinted(color)
            case .yahoo: return Asset.Images.socialYahooIcon.tinted(color)
            case .yandex: return Asset.Images.socialYandexIcon.tinted(color)
            case .youtube: return Asset.Images.socialYoutubeIcon.tinted(color)
        }
    }
}
