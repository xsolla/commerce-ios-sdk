# Changelog

## [1.0.1] - July 2024
### Changed
 - `StorePaymentProjectSettings` structure. Added closeButtonIcon parameter, that defines the icon of the **Close** button in the payment UI. Can be arrow or cross.

## [1.0.0] - May 2024
### Added
 - `getVirtualItemsWithInfo` SDK method. (Modified version of `getVirtualItems` method)

### Changed
 - `authWithXsollaWidget` SDK method. Added `jwtParams` parameter. This method uses OAuth2.0 authorization now

## [0.7.3] - Marсh 2024
### Added
 - `presentPaymentView` method. Enables a seamless display of the Pay Station view for transactions
 - `warmupPaymentView` method. Preloads the internal Pay Station WebView, ensuring faster content display
 - Ability to close the Pay Station directly within the WebView

### Changed
 - `getUserInventoryItems` SDK method. Added `limit` and `offset` parameters
 - `hasMore` parameter to the response added to the following SDK methods:
    - `getVirtualItemsResponse`
    - `getItemsOfGroupResponse`
    - `getVirtualCurrencyResponse`
    - `getVirtualCurrencyPackagesResponse`

## [0.7.2] - January 2024

### Added
  - `authWithXsollaWidget` SDK method. Added the `locale` parameter

## [0.7.0] - November 2023

### Added
  - Centrifugo integration
  - `trackOrderStatus` SDK method. Establishes connection to Xsolla server to track the order status
  - `authWithXsollaWidget` SDK method. Authenticates the user with Xsolla Login widget

### Changed
  - AppConfig settings. `paystationUITheme` renamed to `paystationUIThemeId`
  - Minimum iOS version (12.0)

## [0.6.0] - June 2023

### Added
  - `createOrderWithFreeItem` - method for purchasing a free virtual item
  - `createOrderWithFreeCart` - method for purchasing a cart that contains free items
  - `StoreItemLimits` data to store items (Bundle, VirtualCurrency, VirtualItem)
  - Ability to pass `externalId` data to purchase order requests

### Changed
  - Methods `createOrderWithCart` and `createOrderFromCurrentCart` have been combined into a single `createOrderWithCart`
  - Parameter `StorePaymentProjectSettings.UISettings.theme` has changed its type from an `enum` to a `string`

## [0.5.0] - November 2022

### Added
- Locale argument to passwordless login
- Locale argument for email sending methods
- Unique Demo User generation
- Personalization for catalog requests

### Changed
- Removed all base request proxies
- Removed request proxies in LoginKit, InventoryKit, and StoreKit
- Changed modelFactory in LoginKit, InventoryKit, and StoreKit
- Refactored error handlers
- KitCompletion<> replaced by Result<>
- Response and requests models:
  * LogUserOut
  * GetDRMList
  * GetGamesList
  * DeleteLinkedNetworks
  * FillCartWithItems
  * DeleteAllCartItemsByCartId
  * RemovePromocodeFromCart
  * GetPromocodeRewards
  * RedeemGameCode
  * RedeemGameCode
  * FillCartWithItems
  * FillSpecificCartWithItems

### Fixed
- Optional parameters generation in APIBaseRequest.swift
- Array parameters in query
- Optional parameter in StoreKit
- Access token use removed from some methods
- Method names in StoreKit
- Quantity in CreateOrderFromCurrentCartRequest

## [0.4.0] - December 2021

### Added
- New methods:
  * logUserOut
  * createCodeForLinkingAccounts
  * checkUserAge
  * searchUsersByNickname
  * getUserPublicProfile
  * getLinksForSocialAuth

### Changed
- Updated 'createOrder' method (added new parameters)

## [0.3.0] - September 2021

### Added
- Passwordless log in via email or SMS
- Log in with Device ID (guest login)
- Guest account upgrade
- Linking a social network(s) to an account
- Linking/unlinking devices to an account

## [0.2.0] - June 2021

### Added
- New methods:
  * updateCurrentUserDetails
  * getUserEmail
  * deleteUserPicture
  * uploadUserPicture
  * getCurrentUserPhone
  * updateCurrentUserPhone
  * deleteCurrentUserPhone
  * getCurrentUserFriends
  * updateCurrentUserFriends
  * getLinkedNetworks
  * getSocialNetworkFriends
  * updateSocialNetworkFriends
  * getClientUserAttributes
  * getClientUserReadOnlyAttributes
  * updateClientUserAttributes
