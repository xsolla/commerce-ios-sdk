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

extension Font
{
    typealias Roboto = FontFamily.Roboto
}

extension FontConvertible
{
    func size(_ size: CGFloat) -> Font { font(size: size) ?? .systemFont(ofSize: size) }
}

extension Font
{
    static let xolla_button: Font = Style.button.font
    static let xolla_label: Font = Style.label.font
    static let xolla_heading1: Font = Style.heading1.font
    static let xolla_heading2: Font = Style.heading2.font
    static let xolla_description: Font = Style.description.font
    static let xolla_discount: Font = Style.discount.font
    static let xolla_link: Font = Style.link.font
    static let xolla_caption: Font = Style.caption.font
    static let xolla_notification: Font = Style.notification.font
}
