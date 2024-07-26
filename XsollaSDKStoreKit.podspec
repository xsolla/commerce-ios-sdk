Pod::Spec.new do |s|

  s.name         = 'XsollaSDKStoreKit'
  s.version      = '1.0.2'
  s.summary      = 'The official Xsolla SDK for iOS used to sell items in the apps based on In-Game Store.'
  s.description  = <<-DESC
                   The library contains methods for working with the Store API and allows you to implement the following features:
                     * selling virtual items and virtual currency
                     * managing virtual currency balance
                     * working with promotional campaigns (discounts, coupons, and promo codes)
                   To work with payments when using the Store SDK, the Payments SDK is required.

                   NOTE: The SDK is written in pure Swift. You can use it in Swift or mixed-language projects. Pure Objective-C projects are not supported.
                   DESC

  s.author       = 'Xsolla (USA), Inc.'
  s.homepage     = 'http://www.xsolla.com'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }

  s.platform     = :ios, '12.0'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/xsolla/commerce-ios-sdk.git", :tag => "#{s.version}" }

  s.frameworks   = 'Foundation'
  s.requires_arc = true

  s.source_files = 'StoreKit/**/*.{h,m,swift}'
  s.dependency     'XsollaSDKUtilities', "~> #{s.version}"
  s.dependency     'SwiftCentrifuge', '< 8.0.0'

end
