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

class BaseStringValidator: UserInputValidatorProtocol
{
    let target: StringUserInputValidatable
    var cachedResult: Bool?
    var active: Bool = false
    var inactiveStateResult: Bool = false
    var errorsEnabled: Bool = false
    
    func validate() -> Bool
    {
        if !active { return inactiveStateResult }
        if let cachedResult = cachedResult { return cachedResult }

        let result = self.getValidationResult()
        cache(result)
        
        return result
    }
    
    func getValidationResult() -> Bool
    {
        true
    }
 
    func reset()
    {
        cachedResult = nil
    }

    func cache(_ result: Bool)
    {
        cachedResult = result
    }
    
    func error(_ string: String?)
    {
        if errorsEnabled { target.setError(text: string) }
    }
    
    init(target: StringUserInputValidatable)
    {
        self.target = target
    }
}
