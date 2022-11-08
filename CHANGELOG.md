# Changelog

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
  * updateClientUserAttributes.
