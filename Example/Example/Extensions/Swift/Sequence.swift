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

extension Sequence
{
    func mapToDictionary<T: Hashable>(keyPath: KeyPath<Element, T>) -> [T: Element]
    {
        reduce(into: [T: Element]()) { (result, element) in result[element[keyPath: keyPath]] = element }
    }
    
    func map<T>(keyPath: KeyPath<Element, T>) -> [T]
    {
        map { element in element[keyPath: keyPath] }
    }
    
    func mapDistinctValue<T: Hashable>(keyPath: KeyPath<Element, T>) -> [T]
    {
        Array(reduce(into: Set<T>()) { (result, element) in result.insert(element[keyPath: keyPath]) })
    }
    
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element]
    {
        sorted { a, b in a[keyPath: keyPath] < b[keyPath: keyPath] }
    }
}
