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

extension UICollectionView
{
    func registerXib<T: UICollectionViewCell>(for type: T.Type)
    {
        register(UINib(nibName: T.nibName, bundle: nil), forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func registerCell<T: UICollectionViewCell>(_ type: T.Type)
    {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func cell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T
    {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T
        else { fatalError("Error dequeuing cell with identifier \(T.reuseIdentifier) for section: \(indexPath.section) item: \(indexPath.item)") }

        return cell
    }
}

extension UICollectionViewCell
{
    static var nibName: String
    {
        return String(describing: self)
    }

    static var reuseIdentifier: String
    {
        return String(describing: self)
    }
}
