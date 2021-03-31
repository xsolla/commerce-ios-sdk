# Xsolla SDK for iOS
This SDK is a set of classes and methods that you can integrate into your iOS app to work with Xsolla products. After integration, you can:
* authenticate users while keeping user data safe, secure, and under your ownership
* sell virtual goods to a worldwide audience and integrate in-app purchases (IAPs)
* provide users with a convenient UI to pay for in-game purchases in the game store
* manage player’s inventory based on cross-platform cloud storage
* grow and manage your community with the friend system and cross-platform player authentication

## Composition
The SDK includes the following modules:

### LoginKit
Contains methods for working with the [Login API](https://developers.xsolla.com/login-api/) and allows you to implement the following [Xsolla Login](https://developers.xsolla.com/doc/login/) features:

* authentication via email or username and password
* authentication via the following social networks:
  - Google
  - Facebook
  - Twitter
  - LinkedIn
  - Baidu
* sign-up
* email confirmation
* password reset

### StoreKit
Contains methods for working with the [Store API](https://developers.xsolla.com/store-api/) and allows you to implement the following [In-Game Store](https://developers.xsolla.com/doc/in-game-store/features/player-inventory/) features:

* selling virtual items and virtual currency
* managing virtual currency balance
* working with promotional campaigns (discounts, coupons, and promo codes)

### InventoryKit
Contains methods for working with the [Player Inventory API](https://developers.xsolla.com/store-api/player-inventory) and allows you to implement the following [In-Game Store](https://developers.xsolla.com/doc/in-game-store/features/player-inventory/) features:

* user inventory management
* virtual currency balance management

### PaymentsKit
Allows opening payment UI via the web to use the main [Xsolla Pay Station](https://developers.xsolla.com/doc/pay-station/) features:

* purchases for 130+ currencies
* purchases via 700+ payment methods
* built-in anti-fraud
* payment UI localized in 20 languages
* purchase refund

## System requirements
* iOS 11 or higher
* Swift 5
* Internet connection

**Notice:** The SDK is written in pure Swift. You can use it in Swift or mixed-language projects. Pure Objective-C projects are not supported.

## Prerequisites
Before you integrate:

1. Install [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#getting-started).
2. Download and install [Xcode](https://apps.apple.com/us/app/xcode/id497799835?mt=12).
3. Create a new Xcode project.
4. Register an [Xsolla Publisher Account](https://publisher.xsolla.com/signup?store_type=sdk) and set up a new project.

## Installation
The library is available in CocoaPods.

Add the following line to your `Podfile` to include all SDKs for iOS at once:

```
 pod 'XsollaSDK'
```

To use only specific modules, specify them in your `Podfile`. For example:

```
 pod 'XsollaSDKLoginKit'
 pod 'XsollaSDKStoreKit'
```
To test installation, add the following line to your `AppDelegate`, where `<pod_name>` is the name of the installed module:
```
import '<pod_name>'
```

Check-out the API references available online at: <https://developers.xsolla.com/>

## Community
Join our [Discord server](https://discord.gg/auNFyzZx96). Connect with the Xsolla team and developers who use Xsolla products.

## Documentation
API reference:

 * [Login API](https://developers.xsolla.com/login-api/)
 * [Store API](https://developers.xsolla.com/store-api/)
 * [Player Inventory API](https://developers.xsolla.com/store-api/player-inventory)

## Licence
See the [LICENSE](LICENSE) file.

## Additional resources
* [Xsolla official website](https://xsolla.com/)
* [Developers documentation](https://developers.xsolla.com/)
