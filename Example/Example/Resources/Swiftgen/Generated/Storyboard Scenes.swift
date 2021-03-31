// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum Authentication: StoryboardType {
    internal static let storyboardName = "Authentication"

    internal static let login = SceneType<Example.LoginVC>(storyboard: Authentication.self, identifier: "Login")

    internal static let main = SceneType<Example.AuthenticationMainVC>(storyboard: Authentication.self, identifier: "Main")

    internal static let recoverPassword = SceneType<Example.RecoverPasswordVC>(storyboard: Authentication.self, identifier: "RecoverPassword")

    internal static let signup = SceneType<Example.SignupVC>(storyboard: Authentication.self, identifier: "Signup")
  }
  internal enum BundlePreview: StoryboardType {
    internal static let storyboardName = "BundlePreview"

    internal static let bundlePreview = SceneType<Example.BundlePreviewVC>(storyboard: BundlePreview.self, identifier: "BundlePreview")
  }
  internal enum Inventory: StoryboardType {
    internal static let storyboardName = "Inventory"

    internal static let inventory = SceneType<Example.InventoryVC>(storyboard: Inventory.self, identifier: "Inventory")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let main = SceneType<Example.MainVC>(storyboard: Main.self, identifier: "Main")
  }
  internal enum SideMenu: StoryboardType {
    internal static let storyboardName = "SideMenu"

    internal static let sideMenu = SceneType<Example.SideMenuVC>(storyboard: SideMenu.self, identifier: "SideMenu")

    internal static let sideMenuContent = SceneType<Example.SideMenuContentVC>(storyboard: SideMenu.self, identifier: "SideMenuContent")
  }
  internal enum VirtualCurrency: StoryboardType {
    internal static let storyboardName = "VirtualCurrency"

    internal static let virtualCurrency = SceneType<Example.VirtualCurrencyVC>(storyboard: VirtualCurrency.self, identifier: "VirtualCurrency")
  }
  internal enum VirtualItems: StoryboardType {
    internal static let storyboardName = "VirtualItems"

    internal static let initialScene = InitialSceneType<Example.VirtualItemsVC>(storyboard: VirtualItems.self)

    internal static let virtualItems = SceneType<Example.VirtualItemsVC>(storyboard: VirtualItems.self, identifier: "VirtualItems")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
