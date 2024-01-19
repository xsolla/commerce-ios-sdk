Pod::Spec.new do |s|

  s.name         = 'XsollaSDKInventoryKit'
  s.version      = '0.7.1'
  s.summary      = 'The official Xsolla SDK for iOS used to manage player’s inventory using the solution based on In-Game-Store.'
  s.description  = <<-DESC
                   The library contains methods for working with the Player Inventory API and allows you to implement the management of:
                     * user inventory
                     * virtual currency balance
                   The Inventory SDK can be used in combination with the Store SDK or separately.

                   NOTE: The SDK is written in pure Swift. You can use it in Swift or mixed-language projects. Pure Objective-C projects aren’t supported.
                   DESC

  s.author       = 'Xsolla (USA), Inc.'
  s.homepage     = 'http://www.xsolla.com'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }

  s.platform     = :ios, '12.0'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/xsolla/commerce-ios-sdk.git", :tag => "#{s.version}" }

  s.frameworks   = 'Foundation'
  s.requires_arc = true

  s.source_files = 'InventoryKit/**/*.{h,m,swift}'
  s.dependency     'XsollaSDKUtilities', "~> #{s.version}"

end
