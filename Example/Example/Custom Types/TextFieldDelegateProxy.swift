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

class TextFieldDelegateProxy: NSObject, UITextFieldDelegate
{
    weak var delegate: UITextFieldDelegate?
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        delegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        delegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason)
    {
        delegate?.textFieldDidEndEditing?(textField)
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    @available(iOS 13.0, *)
    func textFieldDidChangeSelection(_ textField: UITextField)
    {
        delegate?.textFieldDidChangeSelection?(textField)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        delegate?.textFieldShouldClear?(textField) ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        delegate?.textFieldShouldReturn?(textField) ?? true
    }
}
