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
    var saveProfileDataRequestHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    var linkSocialNetworkRequestHandler: ((UserProfileVCProtocol, SocialNetwork) -> Void)? { get set }
    var upgradeProfileRequestHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    var manageDevicesRequestHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    var selectAvatarButtonHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    var resetPasswordButtonHandler: ((UserProfileVCProtocol) -> Void)? { get set }
    
    func setup(profileDetails: UserProfileDetails)
    func setup(linkedSocialNetworks connections: Set<SocialNetwork>)
    func setup(connectedDevices devices: [DeviceInfo])
}

class UserProfileVC: BaseViewController, UserProfileVCProtocol
{
    override var navigationBarIsHidden: Bool? { true }

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
    
    var saveProfileDataRequestHandler: ((UserProfileVCProtocol) -> Void)?
    var linkSocialNetworkRequestHandler: ((UserProfileVCProtocol, SocialNetwork) -> Void)?
    var upgradeProfileRequestHandler: ((UserProfileVCProtocol) -> Void)?
    var manageDevicesRequestHandler: ((UserProfileVCProtocol) -> Void)?
    var selectAvatarButtonHandler: ((UserProfileVCProtocol) -> Void)?
    var resetPasswordButtonHandler: ((UserProfileVCProtocol) -> Void)?
    
    var loadState: LoadState = .normal
    
    var formValidator: FormValidatorProtocol!
    
    func setup(profileDetails: UserProfileDetails)
    {
        self.userProfileDetails = profileDetails
        update()
    }

    func setup(linkedSocialNetworks connections: Set<SocialNetwork>)
    {
        userNetworkConnetions = connections

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut)
        {
            self.updateSocialNetworksSection()
        }
    }

    func setup(connectedDevices devices: [DeviceInfo])
    {
        userConnectedDevices = devices

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut)
        {
            self.updateConnectedDevicesSection()
        }
    }

    // MARK: - Private properties
    
    private var userProfileDetails: UserProfileDetails?
    private var userNetworkConnetions: Set<SocialNetwork>?
    private var userConnectedDevices: [DeviceInfo] = []

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
        
        if userProfileMandatoryDetails.nickname.nilIfEmpty != userProfileDetails.nickname.nilIfEmpty { return true }
        if userProfileMandatoryDetails.firstName.nilIfEmpty != userProfileDetails.firstName.nilIfEmpty { return true }
        if userProfileMandatoryDetails.lastName.nilIfEmpty != userProfileDetails.lastName.nilIfEmpty { return true }
        if userProfileMandatoryDetails.birthday != userProfileDetails.birthday { return true }
        if userProfileMandatoryDetails.gender != userProfileDetails.gender { return true }
        if userProfileMandatoryDetails.phone.nilIfEmpty != userProfileDetails.phone.nilIfEmpty { return true }
        
        return false
    }

    // MARK: - Outlets

    // Common
    @IBOutlet private weak var rootView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    // Navigation
    @IBOutlet private weak var screenTitleLabel: UILabel!
    @IBOutlet private weak var saveButton: Button!

    // Header
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var profileMessageLabel: UILabel!
    @IBOutlet private weak var avatarButtonView: AvatarButtonView!

    @IBOutlet private weak var networksSectionView: UserProfileSectionView!
    @IBOutlet private weak var networksListView: LinkedSocialNetworksListView!

    // Userinfo
    @IBOutlet private weak var userInfoSectionView: UserProfileSectionView!
    @IBOutlet private weak var emailTextField: FloatingTitleTextField!
    @IBOutlet private weak var usernameTextField: FloatingTitleTextField!
    @IBOutlet private weak var profileUpgradeButton: Button!
    @IBOutlet private weak var resetPasswordButton: Button!

    // Connected devices
    @IBOutlet private weak var connectedDevicesSectionView: UserProfileSectionView!
    @IBOutlet private weak var manageDevicesButton: Button!

    // Additional info
    @IBOutlet private weak var additionalInfoSectionView: UserProfileSectionView!
    @IBOutlet private weak var nicknameTextField: FloatingTitleTextField!
    @IBOutlet private weak var phoneTextField: FloatingTitleTextField!
    @IBOutlet private weak var firstNameTextField: FloatingTitleTextField!
    @IBOutlet private weak var lastNameTextField: FloatingTitleTextField!
    @IBOutlet private weak var birthdayTextField: FloatingTitleTextField!
    @IBOutlet private weak var genderTextField: FloatingTitleTextField!

    // Pickers
    @IBOutlet private weak var birthdayPickerContainer: UIView!
    @IBOutlet private weak var birthdayPicker: UIDatePicker!
    @IBOutlet private weak var birthdayPickerOkButton: UIButton!
    @IBOutlet private weak var birthdayPickerCancelButton: UIButton!
    @IBOutlet private weak var genderPickerView: UIPickerView!
    @IBOutlet private weak var genderButtonContainer: UIView!
    @IBOutlet private weak var birthdayButtonContainer: UIView!

    private let dimmerView: UIView =
    {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.xsolla_black.withAlphaComponent(0.85)
        view.isUserInteractionEnabled = true
        view.alpha = 0

        return view
    }()

    private var activityVC: ActivityIndicatingViewController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        guard formValidator != nil else { fatalError("Form validator is not set") }
        
        setupTitle()
        setupSocialNetworksList()
        setupDimmerView()
        setupBirthdayPicker()
        setupGenderPicker()
        setupTextFields()
        setupTextValidators()
        setupProfileButtons()
        setupSaveButton()

        userInfoSectionView.top = 16
        connectedDevicesSectionView.top = 16
        additionalInfoSectionView.top = 16

        networksSectionView.titleLabel.attributedText =
        L10n.Profile.Section.socialNetworks.attributed(.description, color: .xsolla_inactiveWhite)
        userInfoSectionView.titleLabel.attributedText =
            L10n.Profile.Section.userInfo.attributed(.description, color: .xsolla_inactiveWhite)
        connectedDevicesSectionView.titleLabel.attributedText =
            L10n.Profile.Section.connectedDevices.attributed(.description, color: .xsolla_inactiveWhite)
        additionalInfoSectionView.titleLabel.attributedText =
            L10n.Profile.Section.additionalUserInfo.attributed(.description, color: .xsolla_inactiveWhite)

        avatarButtonView.onTap =
        { [weak self] _ in guard let self = self else { return }

            self.selectAvatarButtonHandler?(self)
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        update()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        view.endEditing(true)
    }

    // MARK: - Setup
    
    private func setupTitle()
    {
        screenTitleLabel.attributedText = L10n.Profile.title.attributed(.heading2, color: .xsolla_white)
    }

    private func setupSaveButton()
    {
        let activeAttrs = Style.label.attributes(withColor: .xsolla_inactiveWhite)
        let inactiveAttrs = Style.label.attributes(withColor: UIColor.xsolla_inactiveWhite.withAlphaComponent(0.5))

        saveButton.setTitle(L10n.Profile.Button.save, attributes: activeAttrs)
        saveButton.setTitle(L10n.Profile.Button.save, attributes: inactiveAttrs, for: .disabled)
        saveButton.setupAppearance(config: Button.smallOutlined)
    }

    private func setupProfileButtons()
    {
        let activeAttrs = Style.button.attributes(withColor: .xsolla_inactiveWhite)

        profileUpgradeButton.setTitle(L10n.Profile.Button.addUsernamePassword, attributes: activeAttrs)
        profileUpgradeButton.setupAppearance(config: Button.largeOutlined)

        manageDevicesButton.setTitle(L10n.Profile.Button.connectedDevices, attributes: activeAttrs)
        manageDevicesButton.setupAppearance(config: Button.largeOutlined)

        resetPasswordButton.setTitle(L10n.Profile.Button.resetPassword, attributes: activeAttrs)
        resetPasswordButton.setupAppearance(config: Button.largeOutlined)
    }

    private func setupTextFields()
    {
        for (index, tuple) in [(emailTextField, L10n.Profile.Field.Email.placeholder),
                               (usernameTextField, L10n.Profile.Field.Username.placeholder),
                               (nicknameTextField, L10n.Profile.Field.Nickname.placeholder),
                               (phoneTextField, L10n.Profile.Field.Phone.placeholder),
                               (firstNameTextField, L10n.Profile.Field.FirstName.placeholder),
                               (lastNameTextField, L10n.Profile.Field.LastName.placeholder),
                               (birthdayTextField, L10n.Profile.Field.Birthday.placeholder),
                               (genderTextField, L10n.Profile.Field.Gender.placeholder)].enumerated()
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

    private func setupSocialNetworksList()
    {
        networksListView.selectionHandler =
        { [weak self] network in guard let self = self else { return }

            self.linkSocialNetworkRequestHandler?(self, network)
        }
    }

    private func setupDimmerView()
    {
        TapGesture.add(to: dimmerView) { [weak self] in self?.didTapOnDimmerView() }
    }
    
    private func setupBirthdayPicker()
    {
        birthdayPickerContainer.translatesAutoresizingMaskIntoConstraints = false
        birthdayPickerContainer.backgroundColor = .xsolla_nightBlue
        birthdayPicker.backgroundColor = .xsolla_nightBlue
        
        let okAttributedTitle = L10n.Profile.DatePicker.confirmButton
            .attributed(.button, color: .xsolla_magenta)
        birthdayPickerOkButton.setAttributedTitle(okAttributedTitle, for: .normal)
        
        let cancelAttributedTitle = L10n.Profile.DatePicker.cancelButton
            .attributed(.button, color: .xsolla_onSurfaceDisabled)
        birthdayPickerCancelButton.setAttributedTitle(cancelAttributedTitle, for: .normal)
    }
    
    private func setupGenderPicker()
    {
        genderPickerView.backgroundColor = .xsolla_nightBlue
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
    }
    
    // MARK: - Update

    private func update()
    {
        updateAvatarSection()
        updateProfileMessage()
        updateSocialNetworksSection()
        updateUserInfoSection()
        updateConnectedDevicesSection()
        updateAdditionaInfoSection()

        updateSaveButton()
    }

    private func updateProfileMessage()
    {
        profileMessageLabel.isHidden = true

        guard let details = userProfileDetails else { return }

        var message: NSAttributedString?

        if details.email.nilIfEmpty != nil && details.isLastEmailConfirmed != true
        {
            message = L10n.Profile.confirmEmailMessage.attributed(.description, color: .xsolla_magenta)
        }
        else if details.isAnonymous == true && details.email.nilIfEmpty == nil
        {
            message = L10n.Profile.UpgradeMessage.profile.attributed(.description, color: .xsolla_magenta)
        }

        profileMessageLabel.attributedText = message
        profileMessageLabel.isHidden = message == nil
    }

    private func updateSocialNetworksSection()
    {
        guard let userNetworkConnetions = userNetworkConnetions else
        {
            networksSectionView.isHidden = true
            networksListView.isHidden = true
            return
        }

        networksSectionView.isHidden = false
        networksListView.isHidden = false

        let items: [LinkedSocialNetworksListView.ListItem] = AppConfig.socialNetworkList.map
        {
            .init(socialNetwork: $0, linked: userNetworkConnetions.contains($0))
        }

        networksListView.setup(withItems: items.sorted { $0.linked && !$1.linked })
    }

    private func updateAvatarSection()
    {
        accountNameLabel.attributedText = userProfileDetails?.nickname?.attributed(.heading2, color: .xsolla_white)

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

    private func updateUserInfoSection()
    {
        emailTextField.set(text: userProfileDetails?.email)
        usernameTextField.set(text: userProfileDetails?.username)

        guard let details = userProfileDetails else
        {
            resetPasswordButton.isHidden = true
            profileUpgradeButton.isHidden = true

            return
        }

        let passwordResetPermitted = details.email.nilIfEmpty != nil && details.isLastEmailConfirmed == true

        resetPasswordButton.isHidden = !passwordResetPermitted
        profileUpgradeButton.isHidden = passwordResetPermitted
    }

    private func updateConnectedDevicesSection()
    {
        let hidden = userConnectedDevices.isEmpty

        connectedDevicesSectionView.isHidden = hidden
        manageDevicesButton.isHidden = hidden
    }

    private func updateAdditionaInfoSection()
    {
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
    }

    private func updateSaveButton()
    {
        let isActive = isDataChanged && formValidator.validate()

        UIView.performWithoutAnimation
        {
            self.saveButton.isEnabled = isActive
        }
    }

    // MARK: - Private methods
    
    private func showDatePicker(animated: Bool = true)
    {
        if #available(iOS 14, *) { birthdayPicker.preferredDatePickerStyle = .inline }

        birthdayPicker.date = currentBirthday ?? Date()
        
        dimmerView.show(in: rootView) { $0.pinToSuperview() }
        birthdayPickerContainer.show(in: rootView)
        { view in

            view.leadingAnchor.constraint(equalTo: self.rootView.leadingAnchor, constant: 20).isActive = true
            view.trailingAnchor.constraint(equalTo: self.rootView.trailingAnchor, constant: -20).isActive = true
            view.centerYAnchor.constraint(equalTo: self.rootView.centerYAnchor).isActive = true
        }
        
        view.endEditing(true)
    }
    
    private func showGenderSelection()
    {
        genderPickerView.selectRow(currentGenderIndex ?? 0, inComponent: 0, animated: false)
        
        dimmerView.show(in: rootView) { $0.pinToSuperview() }
        genderPickerView.show(in: rootView)
        { view in
            view.pinToSuperview(insets: nil, edges: [.left, .right, .bottom])
        }

        view.endEditing(true)
    }
    
    private func hideDatePicker()
    {
        dimmerView.hide()
        birthdayPickerContainer.hide()
    }
    
    private func hideGenderSelection()
    {
        dimmerView.hide()
        genderPickerView.hide(animated: false)
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
            case .female: return L10n.Profile.Field.Gender.female
            case .male: return L10n.Profile.Field.Gender.male
            case .other: return L10n.Profile.Field.Gender.other
            case .unspecified: return L10n.Profile.Field.Gender.unspecified
            default: return nil
        }
    }
    
    // MARK: - Handlers
    
    @IBAction private func onDatePickerOkButton()
    {
        birthdayTextField.set(text: dateFormatter.string(from: birthdayPicker.date))
        currentBirthday = birthdayPicker.date
        
        updateSaveButton()
        hideDatePicker()
    }
    
    @IBAction private func onDatePickerCancelButton()
    {
        hideDatePicker()
    }
    
    private func didTapOnDimmerView()
    {
        hideDatePicker()
        hideGenderSelection()
    }
    
    @IBAction private func onSaveButton()
    {
        saveProfileDataRequestHandler?(self)
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

    @IBAction private func onUpgradeButton(_ sender: Button)
    {
        upgradeProfileRequestHandler?(self)
    }

    @IBAction private func onManageDevicesButton(_ sender: Button)
    {
        manageDevicesRequestHandler?(self)
    }
}

extension UserProfileVC: UITextFieldDelegate
{
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        _ = formValidator.validate()
        updateSaveButton()
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
            }
            
            case .loading: do
            {
                guard activityVC == nil else { return }
                activityVC = ActivityIndicatingViewController.presentEmbedded(in: self, embeddingMode: .over)

                UIView.performWithoutAnimation
                {
                    self.saveButton.isEnabled = false
                }
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
        updateSaveButton()
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

fileprivate extension UIView
{
    func show(in view: UIView, animated: Bool = true, configure: ((UIView) -> Void)?)
    {
        if superview != nil { return }

        alpha = 0
        view.addSubview(self)
        configure?(self)

        guard animated else
        {
            alpha = 1
            return
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut)
        {
            self.alpha = 1
        }
    }

    func hide(animated: Bool = true)
    {
        if superview == nil { return }

        guard animated else
        {
            alpha = 0
            removeFromSuperview()
            return
        }

        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: { self.alpha = 0 },
                       completion: { _ in self.removeFromSuperview() })
    }
}

class UserProfileSectionView: BaseView
{
    let titleLabel = UILabel(frame: .zero)

    var leading: CGFloat { get { leadingConstraint.constant } set { leadingConstraint.constant = newValue } }
    var trailing: CGFloat { get { trailingConstraint.constant } set { trailingConstraint.constant = newValue } }
    var top: CGFloat { get { topConstraint.constant } set { topConstraint.constant = newValue } }
    var bottom: CGFloat { get { bottomConstraint.constant } set { bottomConstraint.constant = newValue } }

    private var leadingConstraint = NSLayoutConstraint()
    private var trailingConstraint = NSLayoutConstraint()
    private var topConstraint = NSLayoutConstraint()
    private var bottomConstraint = NSLayoutConstraint()

    override func commonInit()
    {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        leadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0)
        trailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        topConstraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        bottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)

        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}
