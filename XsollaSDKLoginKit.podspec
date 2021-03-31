Pod::Spec.new do |s|

  s.name         = 'XsollaSDKLoginKit'
  s.version      = '0.1.0'
  s.summary      = 'The official Xsolla SDK for iOS used to authenticate users and to connect them via a friend system using the solution based on Xsolla Login.'
  s.description  = <<-DESC
                   The library contains methods for working with the Login API and allows you to implement the following features:
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

                   NOTE: The SDK is written in pure Swift. You can use it in Swift or mixed-language projects. Pure Objective-C projects aren’t supported.
                   DESC

  s.author       = 'Xsolla (USA), Inc.'
  s.homepage     = 'http://www.xsolla.com'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }

  s.platform     = :ios, '11.0'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/xsolla/commerce-ios-sdk.git", :tag => "#{s.version}" }

  s.frameworks   = 'Foundation'
  s.requires_arc = true

  s.source_files = 'LoginKit/**/*.{h,m,swift}'
  s.dependency     'XsollaSDKUtilities', "~> #{s.version}"

end
