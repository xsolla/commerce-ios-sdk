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

class BaseTableViewController: UITableViewController
{
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder)
    {
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
        super.init(coder: coder)
    }
    
    init()
    {
        logger.debug(.initialization, domain: .example) { String(describing: Self.self) }
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit
    {
        let deinitingType = String(describing: type(of: self))
        logger.debug(.deinitialization, domain: .example) { deinitingType }
    }
}
