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

final class ThreadSafeArray<T>
{
    private var array: [T]
    private let accessQueue = DispatchQueue(label: "SafeArraySynchronizedQueue", attributes: .concurrent)
    
    var count: Int
    {
        var count = 0
        accessQueue.sync { [weak self] in count = self?.array.count ?? 0 }
        return count
    }
    
    var first: T?
    {
        var firstElement: T?
        accessQueue.sync { [weak self] in firstElement = self?.array.first }
        return firstElement
    }
    
    init()
    {
        array = []
    }
    
    func append(_ element: T)
    {
        accessQueue.async(flags: .barrier)
        { [weak self] in
            self?.array.append(element)
        }
    }
    
    func dropFirst()
    {
        accessQueue.async(flags: .barrier)
        { [weak self] in guard let self = self else { return }
            self.array = Array(self.array.dropFirst())
        }
    }
    
    func removeAll()
    {
        accessQueue.async(flags: .barrier) { self.array.removeAll() }
    }
}
