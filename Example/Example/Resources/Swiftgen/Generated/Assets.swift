// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  internal typealias AssetColorTypeAlias = NSColor
  internal typealias AssetImageTypeAlias = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  internal typealias AssetColorTypeAlias = UIColor
  internal typealias AssetImageTypeAlias = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let inactiveMagenta = ColorAsset(name: "inactiveMagenta")
    internal static let inactiveWhite = ColorAsset(name: "inactiveWhite")
    internal static let inputFieldNormal = ColorAsset(name: "inputFieldNormal")
    internal static let darkMagenta = ColorAsset(name: "darkMagenta")
    internal static let magenta = ColorAsset(name: "magenta")
    internal static let black = ColorAsset(name: "black")
    internal static let onSurfaceDisabled = ColorAsset(name: "onSurfaceDisabled")
    internal static let onSurfaceHigh = ColorAsset(name: "onSurfaceHigh")
    internal static let onSurfaceMedium = ColorAsset(name: "onSurfaceMedium")
    internal static let onSurfaceOverlay = ColorAsset(name: "onSurfaceOverlay")
    internal static let transparentMagenta = ColorAsset(name: "transparentMagenta")
    internal static let transparentSlateGrey = ColorAsset(name: "transparentSlateGrey")
    internal static let white = ColorAsset(name: "white")
    internal static let darkSlateBlue = ColorAsset(name: "darkSlateBlue")
    internal static let lightSlateGrey = ColorAsset(name: "lightSlateGrey")
    internal static let nightBlue = ColorAsset(name: "nightBlue")
  }
  internal enum Images {
    internal static let socialBaiduIcon = ImageAsset(name: "social-baidu-icon")
    internal static let socialFacebookIcon = ImageAsset(name: "social-facebook-icon")
    internal static let socialGoogleIcon = ImageAsset(name: "social-google-icon")
    internal static let socialLinkedinIcon = ImageAsset(name: "social-linkedin-icon")
    internal static let socialMoreIcon = ImageAsset(name: "social-more-icon")
    internal static let socialTwitterIcon = ImageAsset(name: "social-twitter-icon")
    internal static let balanceAddIcon = ImageAsset(name: "balance-add-icon")
    internal static let balanceCurrencyIcon = ImageAsset(name: "balance-currency-icon")
    internal static let balanceItemsIcon = ImageAsset(name: "balance-items-icon")
    internal static let menuAccountIcon = ImageAsset(name: "menu-account-icon")
    internal static let menuCharacterIcon = ImageAsset(name: "menu-character-icon")
    internal static let menuFriendsIcon = ImageAsset(name: "menu-friends-icon")
    internal static let menuHelpIcon = ImageAsset(name: "menu-help-icon")
    internal static let menuInventoryIcon = ImageAsset(name: "menu-inventory-icon")
    internal static let menuLogoutIcon = ImageAsset(name: "menu-logout-icon")
    internal static let menuProfileAvatar = ImageAsset(name: "menu-profile-avatar")
    internal static let menuStoreIcon = ImageAsset(name: "menu-store-icon")
    internal static let menuToggleIcon = ImageAsset(name: "menu-toggle-icon")
    internal static let dismissButtonIcon = ImageAsset(name: "dismiss-button-icon")
    internal static let imagePlaceholder = ImageAsset(name: "image-placeholder")
    internal static let textfieldIsSecure = ImageAsset(name: "textfield-is-secure")
    internal static let textfieldNotSecure = ImageAsset(name: "textfield-not-secure")
    internal static let timerIcon = ImageAsset(name: "timer-icon")
    internal static let xsollaLogoWithText = ImageAsset(name: "xsolla-logo-with-text")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ColorAsset {
  internal fileprivate(set) var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  internal var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

internal extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct DataAsset {
  internal fileprivate(set) var name: String

  #if os(iOS) || os(tvOS) || os(OSX)
  @available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
  internal var data: NSDataAsset {
    return NSDataAsset(asset: self)
  }
  #endif
}

#if os(iOS) || os(tvOS) || os(OSX)
@available(iOS 9.0, tvOS 9.0, OSX 10.11, *)
internal extension NSDataAsset {
  convenience init!(asset: DataAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(name: asset.name, bundle: bundle)
    #elseif os(OSX)
    self.init(name: NSDataAsset.Name(asset.name), bundle: bundle)
    #endif
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  internal var image: AssetImageTypeAlias {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = AssetImageTypeAlias(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = AssetImageTypeAlias(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

internal extension AssetImageTypeAlias {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
