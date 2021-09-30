# Xsolla SDK for iOS
This SDK is a set of classes and methods that you can integrate into your iOS app to work with Xsolla products. After integration, you can:
* authenticate users while keeping user data safe, secure, and under your ownership
* sell virtual goods to a worldwide audience and integrate in-app purchases 
* provide users with a convenient UI to pay for in-game purchases in the game store
* manage player’s inventory based on cross-platform cloud storage
* grow and manage your community with the friend system and cross-platform player authentication

## Composition
The SDK includes the following modules:

### LoginKit
Contains methods for working with the [Login API](http://developers.xsolla.com/login-api/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) and allows you to implement the following [Xsolla Login](https://developers.xsolla.com/doc/login/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) features:

* sign-up
* authentication via a device ID
* authentication via an email address or username and password
* passwordless authentication via an email address or phone number
* authentication via social networks
<details>
<summary><b>See the full list of supported social networks</b></summary>
    <ul>
		<li>Amazon</li>
		<li>Apple</li>
		<li>Baidu</li>
		<li>Battle.net</li>
		<li>Discord</li>
		<li>Facebook</li>
		<li>GitHub</li>
		<li>Google</li>
		<li>Kakao</li>
		<li>LinkedIn</li>
		<li>MSN</li>
		<li>Mail.ru</li>
		<li>Microsoft</li>
		<li>Naver</li>
		<li>Odnoklassniki</li>
		<li>PayPal</li>
		<li>QQ</li>
		<li>Reddit</li>
		<li>Steam</li>
		<li>Twitch.tv</li>
		<li>Twitter</li>
		<li>VK</li>
		<li>Vimeo</li>
		<li>WeChat</li>
		<li>Weibo</li>
		<li>Xbox Live</li>
		<li>Yahoo</li>
		<li>Yandex</li>
		<li>YouTube</li>
		</ul>
</details>

* email confirmation
* password reset
* user account
* user attributes management
* friend system


### StoreKit
Contains methods for working with the [Store API](http://developers.xsolla.com/in-game-store-buy-button-api/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) and allows you to implement the following [In-Game Store](https://developers.xsolla.com/doc/in-game-store/features/player-inventory/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) features:

* selling virtual items and virtual currency
* working with promotional campaigns (discounts and coupons)

### InventoryKit
Contains methods for working with the [Player Inventory API](http://developers.xsolla.com/in-game-store-buy-button-api/player-inventory?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) and allows you to implement the following [In-Game Store](http://developers.xsolla.com/in-game-store-buy-button-api/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) features:

* user inventory management
* virtual currency balance management

### PaymentsKit
Allows opening payment UI via the web to use the main [Xsolla Pay Station](https://developers.xsolla.com/doc/pay-station/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) features:

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
4. Register an [Xsolla Publisher Account](http://publisher.xsolla.com/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce) and set up a new project.

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

Check-out the [API references](https://developers.xsolla.com/#api?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce).

## Community
Join our [Discord server](https://discord.gg/auNFyzZx96). Connect with the Xsolla team and developers who use Xsolla products.

## Documentation
API reference:

 * [Login API](http://developers.xsolla.com/login-api/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce)
 * [Store API](http://developers.xsolla.com/in-game-store-buy-button-api/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce)
 * [Player Inventory API](http://developers.xsolla.com/in-game-store-buy-button-api/player-inventory?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce)

## Licence
See the [LICENSE](LICENSE) file.

## Additional resources
* [Xsolla official website](http://xsolla.com/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce)
* [Developers documentation](http://developers.xsolla.com/?utm_source=github&utm_medium=sdk-ios&utm_campaign=commerce)
