// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  /// Update bundle if you need to change the app language
  static var bundle: Bundle?
    internal enum AccountAvatar {
      /// Avatar
      internal static var title: String { L10n.tr("Localizable", "AccountAvatar.title") }
      internal enum RemoveButton {
        /// Remove avatar
        internal static var title: String { L10n.tr("Localizable", "AccountAvatar.removeButton.title") }
      }
    }
    internal enum Alert {
      internal enum Action {
        /// Cancel
        internal static var cancel: String { L10n.tr("Localizable", "Alert.action.cancel") }
        /// Ok
        internal static var ok: String { L10n.tr("Localizable", "Alert.action.ok") }
      }
      internal enum Error {
        /// Error occured
        internal static var common: String { L10n.tr("Localizable", "Alert.error.common") }
      }
      internal enum PasswordRecover {
        internal enum Success {
          /// Check your email.
          internal static var message: String { L10n.tr("Localizable", "Alert.passwordRecover.success.message") }
          /// Password reset success
          internal static var title: String { L10n.tr("Localizable", "Alert.passwordRecover.success.title") }
        }
      }
      internal enum Registration {
        internal enum Success {
          /// Please check your email.
          internal static var message: String { L10n.tr("Localizable", "Alert.registration.success.message") }
          /// Successful registration
          internal static var title: String { L10n.tr("Localizable", "Alert.registration.success.title") }
        }
      }
      internal enum UnlinkDevice {
        /// Yes, remove
        internal static var confinmButton: String { L10n.tr("Localizable", "Alert.unlinkDevice.confinmButton") }
        /// This will log you out of your account on it.
        internal static var message: String { L10n.tr("Localizable", "Alert.unlinkDevice.message") }
        /// Remove this device?
        internal static var title: String { L10n.tr("Localizable", "Alert.unlinkDevice.title") }
      }
    }
    internal enum AppDeveloperSettings {
      /// Developer settings
      internal static var title: String { L10n.tr("Localizable", "AppDeveloperSettings.title") }
      internal enum ActionButton {
        /// Apply
        internal static var title: String { L10n.tr("Localizable", "AppDeveloperSettings.actionButton.title") }
      }
      internal enum LoginId {
        /// Login ID
        internal static var placeholder: String { L10n.tr("Localizable", "AppDeveloperSettings.loginId.placeholder") }
      }
      internal enum OauthClientId {
        /// OAuth2 client ID
        internal static var placeholder: String { L10n.tr("Localizable", "AppDeveloperSettings.oauthClientId.placeholder") }
      }
      internal enum ProjectId {
        /// Project ID
        internal static var placeholder: String { L10n.tr("Localizable", "AppDeveloperSettings.projectId.placeholder") }
      }
      internal enum ResetButton {
        /// Reset to defaults
        internal static var title: String { L10n.tr("Localizable", "AppDeveloperSettings.resetButton.title") }
      }
      internal enum WebshopUrl {
        /// Webshop url
        internal static var placeholder: String { L10n.tr("Localizable", "AppDeveloperSettings.webshopUrl.placeholder") }
      }
    }
    internal enum AttributeEditor {
      internal enum Button {
        /// Add attribute
        internal static var add: String { L10n.tr("Localizable", "AttributeEditor.button.add") }
        /// Delete this attribute
        internal static var delete: String { L10n.tr("Localizable", "AttributeEditor.button.delete") }
        /// Discard changes
        internal static var discard: String { L10n.tr("Localizable", "AttributeEditor.button.discard") }
        /// Save changes
        internal static var save: String { L10n.tr("Localizable", "AttributeEditor.button.save") }
      }
      internal enum TextField {
        internal enum Placeholder {
          /// Attribute key
          internal static var key: String { L10n.tr("Localizable", "AttributeEditor.textField.placeholder.key") }
          /// Attribute value
          internal static var value: String { L10n.tr("Localizable", "AttributeEditor.textField.placeholder.value") }
        }
      }
      internal enum Title {
        /// Custom attribute
        internal static var add: String { L10n.tr("Localizable", "AttributeEditor.title.add") }
        /// Custom attribute
        internal static var edit: String { L10n.tr("Localizable", "AttributeEditor.title.edit") }
      }
    }
    internal enum Auth {
      internal enum Otp {
        /// Restrictions:\n1.	The confirmation code is valid for 3 minutes. After 3 minutes, you will need to request a new confirmation code.\n2.	If you fail to submit the correct confirmation code 3 times, the code becomes invalid.\n3.	You can't request a confirmation code more than 3 times per minute.
        internal static var codeRestrictionsInformation: String { L10n.tr("Localizable", "Auth.OTP.codeRestrictionsInformation") }
        internal enum Email {
          internal enum Code {
            /// Log in
            internal static var actionButton: String { L10n.tr("Localizable", "Auth.OTP.email.code.actionButton") }
            /// Code is expired
            internal static var codeExpired: String { L10n.tr("Localizable", "Auth.OTP.email.code.codeExpired") }
            /// Code expired in 
            internal static var codeExpireIn: String { L10n.tr("Localizable", "Auth.OTP.email.code.codeExpireIn") }
            /// Enter code from email
            internal static var codePlaceholder: String { L10n.tr("Localizable", "Auth.OTP.email.code.codePlaceholder") }
            /// Resend code?
            internal static var resendCode: String { L10n.tr("Localizable", "Auth.OTP.email.code.resendCode") }
            /// Code validation
            internal static var title: String { L10n.tr("Localizable", "Auth.OTP.email.code.title") }
          }
          internal enum Start {
            /// Send code
            internal static var actionButton: String { L10n.tr("Localizable", "Auth.OTP.email.start.actionButton") }
            /// Invalid email
            internal static var invalidPayload: String { L10n.tr("Localizable", "Auth.OTP.email.start.invalidPayload") }
            /// Email
            internal static var payloadPlaceholder: String { L10n.tr("Localizable", "Auth.OTP.email.start.payloadPlaceholder") }
            /// Log in with email
            internal static var title: String { L10n.tr("Localizable", "Auth.OTP.email.start.title") }
          }
        }
        internal enum Phone {
          internal enum Code {
            /// Log in
            internal static var actionButton: String { L10n.tr("Localizable", "Auth.OTP.phone.code.actionButton") }
            /// Code is expired
            internal static var codeExpired: String { L10n.tr("Localizable", "Auth.OTP.phone.code.codeExpired") }
            /// Code expired in 
            internal static var codeExpireIn: String { L10n.tr("Localizable", "Auth.OTP.phone.code.codeExpireIn") }
            /// Enter code from SMS
            internal static var codePlaceholder: String { L10n.tr("Localizable", "Auth.OTP.phone.code.codePlaceholder") }
            /// Resend code?
            internal static var resendCode: String { L10n.tr("Localizable", "Auth.OTP.phone.code.resendCode") }
            /// Code validation
            internal static var title: String { L10n.tr("Localizable", "Auth.OTP.phone.code.title") }
          }
          internal enum Start {
            /// Send code
            internal static var actionButton: String { L10n.tr("Localizable", "Auth.OTP.phone.start.actionButton") }
            /// Invalid phone
            internal static var invalidPayload: String { L10n.tr("Localizable", "Auth.OTP.phone.start.invalidPayload") }
            /// Enter your phone
            internal static var payloadPlaceholder: String { L10n.tr("Localizable", "Auth.OTP.phone.start.payloadPlaceholder") }
            /// Log in with phone
            internal static var title: String { L10n.tr("Localizable", "Auth.OTP.phone.start.title") }
          }
        }
      }
      internal enum Button {
        /// More log in options
        internal static var authenticationOptions: String { L10n.tr("Localizable", "Auth.button.authenticationOptions") }
        /// Log in
        internal static var login: String { L10n.tr("Localizable", "Auth.button.login") }
        /// Log in as demo user
        internal static var loginDemo: String { L10n.tr("Localizable", "Auth.button.loginDemo") }
        /// Forgot your password?
        internal static var recoverPassword: String { L10n.tr("Localizable", "Auth.button.recoverPassword") }
        /// Sign up
        internal static var signup: String { L10n.tr("Localizable", "Auth.button.signup") }
        internal enum PrivacyPolicy {
          /// Privacy Policy
          internal static var linkTitle: String { L10n.tr("Localizable", "Auth.button.privacyPolicy.linkTitle") }
          /// By continuing, you agree to be bound by our %s.
          internal static func text(_ p1: UnsafePointer<CChar>) -> String {
            return L10n.tr("Localizable", "Auth.button.privacyPolicy.text", p1)
          }
        }
      }
      internal enum LoginOptions {
        internal enum Button {
          /// Log in as demo user
          internal static var logInAsDemoUser: String { L10n.tr("Localizable", "Auth.loginOptions.button.logInAsDemoUser") }
          /// Log in with device ID
          internal static var logInWithDeviceId: String { L10n.tr("Localizable", "Auth.loginOptions.button.logInWithDeviceId") }
          /// Log in with phone
          internal static var logInWithPhone: String { L10n.tr("Localizable", "Auth.loginOptions.button.logInWithPhone") }
          /// Log in with Xsolla widget
          internal static var logInWithXsollaWidget: String { L10n.tr("Localizable", "Auth.loginOptions.button.logInWithXsollaWidget") }
          /// Log in with email
          internal static var passwordlessAuthorization: String { L10n.tr("Localizable", "Auth.loginOptions.button.passwordlessAuthorization") }
        }
        internal enum Text {
          /// You can insert one of these in place of the "More login options" button:
          internal static var intro: String { L10n.tr("Localizable", "Auth.loginOptions.text.intro") }
          /// Username/password and "Log in with email" authorization options are only shown together for purposes of demonstration. Availability of authorization options depends on Login project settings in Xsolla Publisher Account.
          internal static var passwordLoginExplanation: String { L10n.tr("Localizable", "Auth.loginOptions.text.passwordLoginExplanation") }
        }
      }
      internal enum Main {
        internal enum Tabs {
          /// Log in
          internal static var login: String { L10n.tr("Localizable", "Auth.main.tabs.login") }
          /// Sign up
          internal static var signup: String { L10n.tr("Localizable", "Auth.main.tabs.signup") }
        }
      }
    }
    internal enum BundlePreview {
      /// Bundle Preview
      internal static var title: String { L10n.tr("Localizable", "BundlePreview.title") }
    }
    internal enum Character {
      /// See the documentation to learn more about read-only attributes.
      internal static var infoText: String { L10n.tr("Localizable", "Character.infoText") }
      /// Character
      internal static var title: String { L10n.tr("Localizable", "Character.title") }
      internal enum Buttons {
        /// Add attribute
        internal static var addAttribute: String { L10n.tr("Localizable", "Character.buttons.addAttribute") }
      }
      internal enum TabBar {
        /// User-editable attributes
        internal static var customAttributes: String { L10n.tr("Localizable", "Character.tabBar.customAttributes") }
        /// Read-only attributes
        internal static var readonlyAttributes: String { L10n.tr("Localizable", "Character.tabBar.readonlyAttributes") }
      }
    }
    internal enum Common {
      internal enum Button {
        /// Buy now
        internal static var buy: String { L10n.tr("Localizable", "Common.button.buy") }
        /// Buy Again
        internal static var buyAgain: String { L10n.tr("Localizable", "Common.button.buyAgain") }
        /// Consume
        internal static var consume: String { L10n.tr("Localizable", "Common.button.consume") }
        /// Free
        internal static var free: String { L10n.tr("Localizable", "Common.button.free") }
        /// Preview
        internal static var preview: String { L10n.tr("Localizable", "Common.button.preview") }
      }
      internal enum Tabbar {
        internal enum Tab {
          /// All
          internal static var all: String { L10n.tr("Localizable", "Common.tabbar.tab.all") }
        }
      }
    }
    internal enum Form {
      internal enum Field {
        internal enum Common {
          internal enum Error {
            /// Required field
            internal static var empty: String { L10n.tr("Localizable", "Form.field.common.error.empty") }
          }
        }
        internal enum ConfirmPassword {
          /// Confirm password
          internal static var placeholder: String { L10n.tr("Localizable", "Form.field.confirmPassword.placeholder") }
          internal enum Error {
            /// Passwords do not match
            internal static var notMatch: String { L10n.tr("Localizable", "Form.field.confirmPassword.error.notMatch") }
          }
        }
        internal enum Email {
          /// Email
          internal static var placeholder: String { L10n.tr("Localizable", "Form.field.email.placeholder") }
        }
        internal enum Password {
          /// Minimum length: 6 characters
          internal static var hint: String { L10n.tr("Localizable", "Form.field.password.hint") }
          /// Password
          internal static var placeholder: String { L10n.tr("Localizable", "Form.field.password.placeholder") }
          internal enum Error {
            /// Minimum length: 6 characters
            internal static var minLength: String { L10n.tr("Localizable", "Form.field.password.error.minLength") }
          }
        }
        internal enum Username {
          /// Username
          internal static var placeholder: String { L10n.tr("Localizable", "Form.field.username.placeholder") }
        }
      }
    }
    internal enum Inventory {
      /// My inventory
      internal static var title: String { L10n.tr("Localizable", "Inventory.title") }
      internal enum Button {
        /// Refresh
        internal static var refresh: String { L10n.tr("Localizable", "Inventory.button.refresh") }
        /// Go To Store
        internal static var toStore: String { L10n.tr("Localizable", "Inventory.button.toStore") }
      }
      internal enum Label {
        /// Active until: %s
        internal static func active(_ p1: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "Inventory.label.active", p1)
        }
        /// Expired
        internal static var expired: String { L10n.tr("Localizable", "Inventory.label.expired") }
      }
    }
    internal enum Menu {
      internal enum Item {
        /// Account
        internal static var account: String { L10n.tr("Localizable", "Menu.item.account") }
        /// Cart
        internal static var cart: String { L10n.tr("Localizable", "Menu.item.cart") }
        /// Character
        internal static var character: String { L10n.tr("Localizable", "Menu.item.character") }
        /// My friends
        internal static var friends: String { L10n.tr("Localizable", "Menu.item.friends") }
        /// My inventory
        internal static var inventory: String { L10n.tr("Localizable", "Menu.item.inventory") }
        /// Log out
        internal static var logout: String { L10n.tr("Localizable", "Menu.item.logout") }
        /// Merchandise
        internal static var merchandise: String { L10n.tr("Localizable", "Menu.item.merchandise") }
        /// Redeem a coupon
        internal static var redeemCoupon: String { L10n.tr("Localizable", "Menu.item.redeemCoupon") }
        /// Store
        internal static var store: String { L10n.tr("Localizable", "Menu.item.store") }
        /// Virtual currency
        internal static var virtualCurrency: String { L10n.tr("Localizable", "Menu.item.virtualCurrency") }
        /// Virtual items
        internal static var virtualItems: String { L10n.tr("Localizable", "Menu.item.virtualItems") }
        /// Web Shop
        internal static var webstore: String { L10n.tr("Localizable", "Menu.item.webstore") }
      }
    }
    internal enum OTPSequenceError {
      /// Expired OTP code
      internal static var expiredCode: String { L10n.tr("Localizable", "OTPSequenceError.expiredCode") }
      /// Invalid access code
      internal static var invalidAccessCode: String { L10n.tr("Localizable", "OTPSequenceError.invalidAccessCode") }
      /// Invalid operation id
      internal static var invalidOperationId: String { L10n.tr("Localizable", "OTPSequenceError.invalidOperationId") }
      /// Invalid OTP code
      internal static var invalidOTPCode: String { L10n.tr("Localizable", "OTPSequenceError.invalidOTPCode") }
      /// Invalid OTP Sequence
      internal static var invalidOTPSequence: String { L10n.tr("Localizable", "OTPSequenceError.invalidOTPSequence") }
      /// Invalid OTP payload
      internal static var invalidPayload: String { L10n.tr("Localizable", "OTPSequenceError.invalidPayload") }
      /// Operation id mismatch
      internal static var operationIdMismatch: String { L10n.tr("Localizable", "OTPSequenceError.operationIdMismatch") }
      /// Token not found in response
      internal static var tokenNotFound: String { L10n.tr("Localizable", "OTPSequenceError.tokenNotFound") }
    }
    internal enum Profile {
      /// Email verification required
      internal static var confirmEmailMessage: String { L10n.tr("Localizable", "Profile.confirmEmailMessage") }
      /// Account
      internal static var title: String { L10n.tr("Localizable", "Profile.title") }
      internal enum Button {
        /// Add username and password
        internal static var addUsernamePassword: String { L10n.tr("Localizable", "Profile.button.addUsernamePassword") }
        /// Manage your devices
        internal static var connectedDevices: String { L10n.tr("Localizable", "Profile.button.connectedDevices") }
        /// Reset password
        internal static var resetPassword: String { L10n.tr("Localizable", "Profile.button.resetPassword") }
        /// Save changes
        internal static var save: String { L10n.tr("Localizable", "Profile.button.save") }
      }
      internal enum DatePicker {
        /// Cancel
        internal static var cancelButton: String { L10n.tr("Localizable", "Profile.datePicker.cancelButton") }
        /// Ok
        internal static var confirmButton: String { L10n.tr("Localizable", "Profile.datePicker.confirmButton") }
      }
      internal enum Field {
        internal enum Birthday {
          /// Birthday
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.birthday.placeholder") }
        }
        internal enum Email {
          /// Email
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.email.placeholder") }
        }
        internal enum FirstName {
          /// First name
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.firstName.placeholder") }
        }
        internal enum Gender {
          /// Female
          internal static var female: String { L10n.tr("Localizable", "Profile.field.gender.female") }
          /// Male
          internal static var male: String { L10n.tr("Localizable", "Profile.field.gender.male") }
          /// Other
          internal static var other: String { L10n.tr("Localizable", "Profile.field.gender.other") }
          /// Gender
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.gender.placeholder") }
          /// Prefer not to answer
          internal static var unspecified: String { L10n.tr("Localizable", "Profile.field.gender.unspecified") }
        }
        internal enum LastName {
          /// Last name
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.lastName.placeholder") }
        }
        internal enum Nickname {
          /// Nickname
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.nickname.placeholder") }
        }
        internal enum Phone {
          /// Phone
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.phone.placeholder") }
          /// Validation error
          internal static var validationError: String { L10n.tr("Localizable", "Profile.field.phone.validationError") }
        }
        internal enum Username {
          /// Username
          internal static var placeholder: String { L10n.tr("Localizable", "Profile.field.username.placeholder") }
        }
      }
      internal enum Section {
        /// Additional user info
        internal static var additionalUserInfo: String { L10n.tr("Localizable", "Profile.section.additionalUserInfo") }
        /// Connected devices
        internal static var connectedDevices: String { L10n.tr("Localizable", "Profile.section.connectedDevices") }
        /// Social networks
        internal static var socialNetworks: String { L10n.tr("Localizable", "Profile.section.socialNetworks") }
        /// User info
        internal static var userInfo: String { L10n.tr("Localizable", "Profile.section.userInfo") }
        internal enum ConnectedDevices {
          /// Remove
          internal static var removeButton: String { L10n.tr("Localizable", "Profile.section.connectedDevices.removeButton") }
        }
      }
      internal enum UpgradeMessage {
        /// Upgrade account to save your progress
        internal static var menu: String { L10n.tr("Localizable", "Profile.upgradeMessage.menu") }
        /// Add a username and password or link a social profile to upgrade your account.
        internal static var profile: String { L10n.tr("Localizable", "Profile.upgradeMessage.profile") }
      }
    }
    internal enum RecoverPassword {
      internal enum Button {
        /// Back to log in
        internal static var back: String { L10n.tr("Localizable", "RecoverPassword.button.back") }
        /// Reset password
        internal static var resetPassword: String { L10n.tr("Localizable", "RecoverPassword.button.resetPassword") }
      }
    }
    internal enum RedirectUrlParsingError {
      /// Network linking error
      internal static var networkLinkingError: String { L10n.tr("Localizable", "RedirectUrlParsingError.networkLinkingError") }
      /// Unknown error
      internal static var unknownError: String { L10n.tr("Localizable", "RedirectUrlParsingError.unknownError") }
    }
    internal enum SocialNetwork {
      /// Amazon
      internal static var amazon: String { L10n.tr("Localizable", "SocialNetwork.amazon") }
      /// Apple
      internal static var apple: String { L10n.tr("Localizable", "SocialNetwork.apple") }
      /// Baidu
      internal static var baidu: String { L10n.tr("Localizable", "SocialNetwork.baidu") }
      /// Battle.net
      internal static var battlenet: String { L10n.tr("Localizable", "SocialNetwork.battlenet") }
      /// Discord
      internal static var discord: String { L10n.tr("Localizable", "SocialNetwork.discord") }
      /// Facebook
      internal static var facebook: String { L10n.tr("Localizable", "SocialNetwork.facebook") }
      /// GitHub
      internal static var github: String { L10n.tr("Localizable", "SocialNetwork.github") }
      /// Google
      internal static var google: String { L10n.tr("Localizable", "SocialNetwork.google") }
      /// Kakao
      internal static var kakao: String { L10n.tr("Localizable", "SocialNetwork.kakao") }
      /// LinkedIn
      internal static var linkedin: String { L10n.tr("Localizable", "SocialNetwork.linkedin") }
      /// Mail.ru
      internal static var mailru: String { L10n.tr("Localizable", "SocialNetwork.mailru") }
      /// Microsoft
      internal static var microsoft: String { L10n.tr("Localizable", "SocialNetwork.microsoft") }
      /// MSN
      internal static var msn: String { L10n.tr("Localizable", "SocialNetwork.msn") }
      /// Naver
      internal static var naver: String { L10n.tr("Localizable", "SocialNetwork.naver") }
      /// Odnoklassniki
      internal static var ok: String { L10n.tr("Localizable", "SocialNetwork.ok") }
      /// PayPal
      internal static var paypal: String { L10n.tr("Localizable", "SocialNetwork.paypal") }
      /// QQ
      internal static var qq: String { L10n.tr("Localizable", "SocialNetwork.qq") }
      /// Reddit
      internal static var reddit: String { L10n.tr("Localizable", "SocialNetwork.reddit") }
      /// Steam
      internal static var steam: String { L10n.tr("Localizable", "SocialNetwork.steam") }
      /// Twitch.tv
      internal static var twitch: String { L10n.tr("Localizable", "SocialNetwork.twitch") }
      /// Twitter
      internal static var twitter: String { L10n.tr("Localizable", "SocialNetwork.twitter") }
      /// Vimeo
      internal static var vimeo: String { L10n.tr("Localizable", "SocialNetwork.vimeo") }
      /// VK
      internal static var vk: String { L10n.tr("Localizable", "SocialNetwork.vk") }
      /// WeChat
      internal static var wechat: String { L10n.tr("Localizable", "SocialNetwork.wechat") }
      /// Weibo
      internal static var weibo: String { L10n.tr("Localizable", "SocialNetwork.weibo") }
      /// Xbox Live
      internal static var xbox: String { L10n.tr("Localizable", "SocialNetwork.xbox") }
      /// Yahoo
      internal static var yahoo: String { L10n.tr("Localizable", "SocialNetwork.yahoo") }
      /// Yandex
      internal static var yandex: String { L10n.tr("Localizable", "SocialNetwork.yandex") }
      /// YouTube
      internal static var youtube: String { L10n.tr("Localizable", "SocialNetwork.youtube") }
    }
    internal enum SocialNetworks {
      /// Search social network
      internal static var searchPlaceholder: String { L10n.tr("Localizable", "SocialNetworks.searchPlaceholder") }
      /// Social networks
      internal static var title: String { L10n.tr("Localizable", "SocialNetworks.title") }
    }
    internal enum Store {
      internal enum Params {
        /// Back to the Game
        internal static var backToTheGame: String { L10n.tr("Localizable", "Store.params.backToTheGame") }
      }
    }
    internal enum UserProfileError {
      /// Username is missing
      internal static var missingUsername: String { L10n.tr("Localizable", "UserProfileError.missingUsername") }
    }
    internal enum VirtualCurrency {
      /// Virtual currency
      internal static var title: String { L10n.tr("Localizable", "VirtualCurrency.title") }
    }
    internal enum VirtualItems {
      /// Purchased
      internal static var purchased: String { L10n.tr("Localizable", "VirtualItems.purchased") }
      /// Virtual items
      internal static var title: String { L10n.tr("Localizable", "VirtualItems.title") }
    }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    if table == "NotLocalizable"
    {
      let format = NSLocalizedString(key, tableName: table, comment: "")
      return String(format: format, arguments: args)
    }
    else
    {
      let format = NSLocalizedString(key, tableName: table, bundle: bundle ?? Bundle(for: BundleToken.self), comment: "")
      return String(format: format, locale: Locale.current, arguments: args)
    }
  }
}

private final class BundleToken {}
