Pod::Spec.new do |s|

  s.name         = 'XsollaSDKPaymentsKit'
  s.version      = '0.1.0'
  s.summary      = 'The official Xsolla SDK for iOS used to receive payments for in-game purchases with the convenient UI based on Xsolla Pay Station.'
  s.description  = <<-DESC
                   The library allows opening payment UI via web to use main Pay Station features:
                     * purchases for 130+ currencies
                     * purchases via 700+ payment methods
                     * built-in anti-fraud
                     * payment UI localized in 20 languages
                     * purchase refund
                   The Payments SDK is required to work with payments when using the Store SDK, but it also can be used separately.

                   NOTE: The SDK is written in pure Swift. You can use it in Swift or mixed-language projects. Pure Objective-C projects are not supported.
                   DESC

  s.author       = 'Xsolla (USA), Inc.'
  s.homepage     = 'http://www.xsolla.com'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }

  s.platform     = :ios, '11.0'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/xsolla/commerce-ios-sdk.git", :tag => "#{s.version}" }

  s.frameworks   = 'Foundation'
  s.requires_arc = true

  s.source_files = 'PaymentsKit/**/*.{h,m,swift}'
  s.dependency     'XsollaSDKUtilities', "~> #{s.version}"

end
