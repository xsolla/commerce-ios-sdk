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
import SDWebImage
import XsollaSDKLoginKit

protocol UserProfileVCProtocol: BaseViewController, LoadStatable
{
    var userProfileMandatoryDetails: UserProfileMandatoryDetails { get }
    var saveButtonHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    var selectAvatarButtonHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    var resetPasswordButtonHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    
    func setup(userProfileDetails: UserProfileDetails)
}

class UserProfileVC: BaseViewController, UserProfileVCProtocol
{
    // MARK: - Public
    
    var userProfileMandatoryDetails: UserProfileMandatoryDetails
    {
        var gender: UserProfileDetails.Gender?
        if let genderIndex = currentGenderIndex
        {
            gender = UserProfileDetails.Gender.allCases[genderIndex]
        }
        
        return UserProfileMandatoryDetails(firstName: firstNameTextField.text,
                                           lastName: lastNameTextField.text,
                                           nickname: nicknameTextField.text,
                                           birthday: currentBirthday,
                                           gender: gender,
                                           phone: phoneTextField.text)
    }
    
    var saveButtonHandler: ((UserProfileVCProtocol) -> Void)?
    var selectAvatarButtonHandler: ((UserProfileVCProtocol) -> Void)?
    var resetPasswordButtonHandler: ((UserProfileVCProtocol) -> Void)?
    
    var loadState: LoadState = .normal
    
    var formValidator: FormValidatorProtocol!
    
    func setup(userProfileDetails: UserProfileDetails)
    {
        self.userProfileDetails = userProfileDetails
        update()
    }
    
    // MARK: - Private properties
    
    private var userProfileDetails: UserProfileDetails?

    private let dateFormatter: DateFormatter =
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    private var currentBirthday: Date?
    private var currentGenderIndex: Int?
    
    private var isDataChanged: Bool
    {
        guard let userProfileDetails = userProfileDetails else { return false }
        
        if userProfileMandatoryDetails.nickname != userProfileDetails.nickname { return true }
        if userProfileMandatoryDetails.firstName != userProfileDetails.firstName { return true }
        if userProfileMandatoryDetails.lastName != userProfileDetails.lastName { return true }
        if userProfileMandatoryDetails.birthday != userProfileDetails.birthday { return true }
        if userProfileMandatoryDetails.gender != userProfileDetails.gender { return true }
        if userProfileMandatoryDetails.phone.nilIfEmpty != userProfileDetails.phone.nilIfEmpty { return true }
        
        return false
    }
    
    // MARK: - Outlets
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var screenTitleLabel: UILabel!
    @IBOutlet private weak var avatarButtonView: AvatarButtonView!
    @IBOutlet private weak var saveButton: Button!
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var emailTextField: FloatingTitleTextField!
    @IBOutlet private weak var usernameTextField: FloatingTitleTextField!
    @IBOutlet private weak var nicknameTextField: FloatingTitleTextField!
    @IBOutlet private weak var phoneTextField: FloatingTitleTextField!
    @IBOutlet private weak var firstNameTextField: FloatingTitleTextField!
    @IBOutlet private weak var lastNameTextField: FloatingTitleTextField!
    @IBOutlet private weak var birthdayTextField: FloatingTitleTextField!
    @IBOutlet private weak var genderTextField: FloatingTitleTextField!
    @IBOutlet private weak var birthdayPickerContainer: UIView!
    @IBOutlet private weak var birthdayPicker: UIDatePicker!
    @IBOutlet private weak var dimmingView: UIView!
    @IBOutlet private weak var birthdayPickerOkButton: UIButton!
    @IBOutlet private weak var birthdayPickerCancelButton: UIButton!
    @IBOutlet private weak var genderPickerView: UIPickerView!
    @IBOutlet private weak var genderButtonContainer: UIView!
    @IBOutlet private weak var birthdayButtonContainer: UIView!
    @IBOutlet private weak var resetPasswordButton: Button!

    private var activityVC: ActivityIndicatingViewController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        guard formValidator != nil else { fatalError("Form validator is not set") }
        
        setupTitle()
        setupResetPasswordButton()
        setupDimmingView()
        setupBirthdayPicker()
        setupGenderPicker()
        setupTextFields()
        setupTextValidators()
        setupSaveButton()
        
        update()
        updateActionButton()

        avatarButtonView.onTap =
        { [weak self] _ in guard let self = self else { return }

            self.selectAvatarButtonHandler?(self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        view.endEditing(true)
    }
    
    // MARK: - Setups
    
    private func setupTitle()
    {
        screenTitleLabel.attributedText = L10n.Account.title.attributed(.heading2, color: .xsolla_white)
    }
    
    private func setupResetPasswordButton()
    {
        let attributedTitle = L10n.Account.resetPasswordButton.attributed(.button, color: .xsolla_lightSlateGrey)
        resetPasswordButton.setAttributedTitle(attributedTitle, for: .normal)
        resetPasswordButton.setupAppearance(config: Button.largeOutlined)
    }
    
    private func setupDimmingView()
    {
        dimmingView.isUserInteractionEnabled = true
        dimmingView.alpha = 0.5
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDimmingView)))
    }
    
    private func setupBirthdayPicker()
    {
        birthdayPickerContainer.backgroundColor = .xsolla_nightBlue
        birthdayPicker.backgroundColor = .xsolla_nightBlue
        
        let okAttributedTitle = L10n.Account.DatePicker.confirmButton
            .attributed(.button, color: .xsolla_magenta)
        birthdayPickerOkButton.setAttributedTitle(okAttributedTitle, for: .normal)
        
        let cancelAttributedTitle = L10n.Account.DatePicker.cancelButton
            .attributed(.button, color: .xsolla_onSurfaceDisabled)
        birthdayPickerCancelButton.setAttributedTitle(cancelAttributedTitle, for: .normal)
    }
    
    private func setupGenderPicker()
    {
        genderPickerView.backgroundColor = .xsolla_nightBlue
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
    }
    
    private func setupTextFields()
    {
        for (index, tuple) in [(emailTextField, L10n.Account.Field.Email.placeholder),
                               (usernameTextField, L10n.Account.Field.Username.placeholder),
                               (nicknameTextField, L10n.Account.Field.Nickname.placeholder),
                               (phoneTextField, L10n.Account.Field.Phone.placeholder),
                               (firstNameTextField, L10n.Account.Field.FirstName.placeholder),
                               (lastNameTextField, L10n.Account.Field.LastName.placeholder),
                               (birthdayTextField, L10n.Account.Field.Birthday.placeholder),
                               (genderTextField, L10n.Account.Field.Gender.placeholder)].enumerated()
        {
            guard let textField = tuple.0 else { continue }
            
            let placeholder = tuple.1
            textField.textColor = .xsolla_onSurfaceMedium
            textField.placeholder = placeholder
            textField.delegate = self
            textField.tag = index
            
            setTextField(textField, active: true)
        }
        
        setTextField(emailTextField, active: false)
        setTextField(usernameTextField, active: false)
        
        genderTextField.isUserInteractionEnabled = false
        birthdayTextField.isUserInteractionEnabled = false
    }
    
    private func setupTextValidators()
    {
        let phoneNumberValidator = formValidator.factory.createPhoneNumberValidator(for: phoneTextField)
        formValidator.addValidator(phoneNumberValidator, withKey: phoneTextField.tag)
        formValidator.enableValidator(withKey: phoneTextField.tag)
    }
    
    private func setupSaveButton()
    {
        let attributedTitle = L10n.Account.saveButton.attributed(.label, color: .xsolla_white)
        saveButton.setAttributedTitle(attributedTitle, for: .normal)
        saveButton.setupAppearance(config: Button.largeOutlined)
    }
    
    // MARK: - Updates

    private func update()
    {
        accountNameLabel.attributedText = userProfileDetails?.nickname?.attributed(.heading2, color: .xsolla_white)
        
        emailTextField.set(text: userProfileDetails?.email)
        usernameTextField.set(text: userProfileDetails?.username)
        nicknameTextField.set(text: userProfileDetails?.nickname)
        phoneTextField.set(text: userProfileDetails?.phone)
        firstNameTextField.set(text: userProfileDetails?.firstName)
        lastNameTextField.set(text: userProfileDetails?.lastName)
        
        if let birthday = userProfileDetails?.birthday
        {
            currentBirthday = birthday
            birthdayTextField.set(text: dateFormatter.string(from: birthday))
            setTextField(birthdayTextField, active: false)
            birthdayButtonContainer.isUserInteractionEnabled = false
        }
        else
        {
            setTextField(birthdayTextField, active: true)
            birthdayButtonContainer.isUserInteractionEnabled = true
        }
        
        if let gender = userProfileDetails?.gender
        {
            let genderIndex = UserProfileDetails.Gender.allCases.firstIndex(of: gender)
            currentGenderIndex = genderIndex
        }
        
        genderTextField.set(text: titleForGender(userProfileDetails?.gender))
        
        updateAvatarSection()
        updateActionButton()
    }
    
    private func updateAvatarSection()
    {
        if let avatarLink = userProfileDetails?.picture, let url = URL(string: avatarLink)
        {
            avatarButtonView.primaryImage = Asset.Images.avatarPlaceholder.image

            SDWebImageDownloader.shared.downloadImage(with: url)
            { [weak self] (image, _, _, _) in

                guard let image = image else { return }
                self?.avatarButtonView.primaryImage = image
            }
        }
        else
        {
            avatarButtonView.primaryImage = Asset.Images.avatarPlaceholder.image
        }
    }
    
    private func updateActionButton()
    {
        let isFormValid = formValidator.validate()
        setActionButtonActive(isDataChanged && isFormValid)
    }
    
    // MARK: - Private methods
    
    private func showDatePicker()
    {
        birthdayPicker.date = currentBirthday ?? Date()
        
        dimmingView.isHidden = false
        birthdayPickerContainer.isHidden = false
        
        view.endEditing(true)
    }
    
    private func showGenderSelection()
    {
        genderPickerView.selectRow(currentGenderIndex ?? 0, inComponent: 0, animated: false)
        
        dimmingView.isHidden = false
        genderPickerView.isHidden = false
        
        view.endEditing(true)
    }
    
    private func hideDatePicker()
    {
        dimmingView.isHidden = true
        birthdayPickerContainer.isHidden = true
    }
    
    private func hideGenderSelection()
    {
        dimmingView.isHidden = true
        genderPickerView.isHidden = true
    }
    
    private func setActionButtonActive(_ isActive: Bool)
    {
        let textColor: UIColor = isActive ? .xsolla_white : .xsolla_lightSlateGrey
        let attributedTitle = L10n.Account.saveButton.attributed(.label, color: textColor)
        saveButton.setAttributedTitle(attributedTitle, for: .normal)
        saveButton.isUserInteractionEnabled = isActive
    }
    
    private func setTextField(_ textField: FloatingTitleTextField, active isActive: Bool)
    {
        textField.isUserInteractionEnabled = isActive
        textField.normalBackgroundColor = isActive ? .xsolla_inputFieldNormal : .xsolla_inputFieldDisabled
    }
    
    private func titleForGender(_ gender: UserProfileDetails.Gender?) -> String?
    {
        switch gender
        {
            case .female: return L10n.Account.Field.Gender.female
            case .male: return L10n.Account.Field.Gender.male
            case .other: return L10n.Account.Field.Gender.other
            case .unspecified: return L10n.Account.Field.Gender.unspecified
            default: return nil
        }
    }
    
    // MARK: - Handlers
    
    @IBAction private func onDatePickerOkButton()
    {
        birthdayTextField.set(text: dateFormatter.string(from: birthdayPicker.date))
        currentBirthday = birthdayPicker.date
        
        updateActionButton()
        hideDatePicker()
    }
    
    @IBAction private func onDatePickerCancelButton()
    {
        hideDatePicker()
    }
    
    @objc private func onDimmingView()
    {
        hideDatePicker()
        hideGenderSelection()
    }
    
    @IBAction private func onSaveButton()
    {
        saveButtonHandler?(self)
    }
    
    @IBAction private func onGenderButtton()
    {
        showGenderSelection()
    }
    
    @IBAction private func onBirthdayButtton()
    {
        showDatePicker()
    }
    
    @IBAction private func onResetButton()
    {
        resetPasswordButtonHandler?(self)
    }
}

extension UserProfileVC: UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        _ = formValidator.validate()
        updateActionButton()
    }
}

extension UserProfileVC: LoadStatable
{
    func getState() -> LoadState
    {
        loadState
    }
    
    func setState(_ state: LoadState, animated: Bool)
    {
        loadState = state
        updateLoadState(animated)
    }
    
    func updateLoadState(_ animated: Bool = false)
    {
        switch loadState
        {
            case .normal, .error: do
            {
                activityVC?.hide(animated: true)
                activityVC = nil
                updateActionButton()
            }
            
            case .loading: do
            {
                guard activityVC == nil else { return }
                activityVC = ActivityIndicatingViewController.presentEmbedded(in: self, embeddingMode: .over)
                setActionButtonActive(false)
            }
        }
    }
}

extension UserProfileVC: UIPickerViewDelegate, UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        UserProfileDetails.Gender.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        titleForGender(UserProfileDetails.Gender.allCases[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        currentGenderIndex = row
        genderTextField.set(text: titleForGender(UserProfileDetails.Gender.allCases[row]))
        updateActionButton()
    }
}

extension UserProfileVC: EmbeddableControllerContainerProtocol
{
    func getContaiterViewForEmbeddableViewController() -> UIView?
    {
        scrollView
    }
}

private extension UserProfileDetails.Gender
{
    static let allCases: [Self] = [.male, .female, .other, .unspecified]
}
