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
    internal enum Account {
      /// Reset password
      internal static var resetPasswordButton: String { L10n.tr("Localizable", "Account.resetPasswordButton") }
      /// Save changes
      internal static var saveButton: String { L10n.tr("Localizable", "Account.saveButton") }
      /// Account
      internal static var title: String { L10n.tr("Localizable", "Account.title") }
      internal enum DatePicker {
        /// CANCEL
        internal static var cancelButton: String { L10n.tr("Localizable", "Account.datePicker.cancelButton") }
        /// OK
        internal static var confirmButton: String { L10n.tr("Localizable", "Account.datePicker.confirmButton") }
      }
      internal enum Field {
        internal enum Birthday {
          /// Birthday
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.birthday.placeholder") }
        }
        internal enum Email {
          /// Email
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.email.placeholder") }
        }
        internal enum FirstName {
          /// First name
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.firstName.placeholder") }
        }
        internal enum Gender {
          /// Female
          internal static var female: String { L10n.tr("Localizable", "Account.field.gender.female") }
          /// Male
          internal static var male: String { L10n.tr("Localizable", "Account.field.gender.male") }
          /// Other
          internal static var other: String { L10n.tr("Localizable", "Account.field.gender.other") }
          /// Gender
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.gender.placeholder") }
          /// Prefer not to answer
          internal static var unspecified: String { L10n.tr("Localizable", "Account.field.gender.unspecified") }
        }
        internal enum LastName {
          /// Last name
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.lastName.placeholder") }
        }
        internal enum Nickname {
          /// Nickname
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.nickname.placeholder") }
        }
        internal enum Phone {
          /// Phone
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.phone.placeholder") }
          /// Validation error
          internal static var validationError: String { L10n.tr("Localizable", "Account.field.phone.validationError") }
        }
        internal enum Username {
          /// Username
          internal static var placeholder: String { L10n.tr("Localizable", "Account.field.username.placeholder") }
        }
      }
    }
    internal enum AccountAvatar {
      /// Avatar
      internal static var title: String { L10n.tr("Localizable", "AccountAvatar.title") }
      internal enum RemoveButton {
        /// REMOVE AVATAR
        internal static var title: String { L10n.tr("Localizable", "AccountAvatar.removeButton.title") }
      }
    }
    internal enum Alert {
      internal enum Action {
        /// OK
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
      internal enum Button {
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
      internal enum Main {
        internal enum Tabs {
          /// Login
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
        /// Help
        internal static var help: String { L10n.tr("Localizable", "Menu.item.help") }
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
      }
    }
    internal enum RecoverPassword {
      internal enum Button {
        /// Back to login
        internal static var back: String { L10n.tr("Localizable", "RecoverPassword.button.back") }
        /// Reset password
        internal static var resetPassword: String { L10n.tr("Localizable", "RecoverPassword.button.resetPassword") }
      }
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
