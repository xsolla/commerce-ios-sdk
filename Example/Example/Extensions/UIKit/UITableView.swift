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

typealias TableViewDataSource = UITableViewDataSource & UITableViewDelegate

extension UITableView
{
    func registerXib<T: UITableViewCell>(for type: T.Type)
    {
        register(UINib(nibName: T.nibName, bundle: nil), forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerXib<T: UITableViewHeaderFooterView>(for type: T.Type)
    {
        register(UINib(nibName: T.nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerCell<T: UITableViewCell>(_ type: T.Type)
    {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerHeader<T: UITableViewHeaderFooterView>(_ type: T.Type)
    {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerFooter<T: UITableViewHeaderFooterView>(_ type: T.Type)
    {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }
    
    func cell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T
    {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T
        else { fatalError("Error dequeuing cell with identifier \(T.reuseIdentifier) for section: \(indexPath.section) row: \(indexPath.row)") }
        
        return cell
    }
    
    func headerOrFooter<T: UITableViewHeaderFooterView>(_ type: T.Type) -> T
    {
        guard let headerOrFooter = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T
        else { fatalError("Error dequeuing header or footer with identifier \(T.reuseIdentifier)") }
        
        return headerOrFooter
    }
}

extension UITableViewCell
{
    static var reuseIdentifier: String
    {
        return String(describing: self)
    }

    static var nibName: String
    {
        return String(describing: self)
    }

    static var xibName: String
    {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView
{
    static var reuseIdentifier: String
    {
        return String(describing: self)
    }

    static var nibName: String
    {
        return String(describing: self)
    }

    static var xibName: String
    {
        return String(describing: self)
    }
}
