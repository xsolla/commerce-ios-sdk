Pod::Spec.new do |s|

  s.name         = 'XsollaSDK'
  s.version      = '0.7.0'
  s.summary      = 'The official Xsolla SDKs for iOS used to work with Xsolla products.'
  s.description  = <<-DESC
                   After integrating SDKs for iOS you will be able to:
                     * authenticate users while keeping user data safe, secure, and under your ownership
                     * sell virtual goods to a worldwide audience and integrate in-app purchases (IAPs)
                     * provide users with a convenient UI to pay for in-game purchases in the game store
                     * manage player’s inventory based on cross-platform cloud storage
                     * grow and manage your community with the friend system and cross-platform player authentication.
                   DESC

  s.author       = 'Xsolla (USA), Inc.'
  s.homepage     = 'http://www.xsolla.com'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }

  s.platform     = :ios, '12.0'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/xsolla/commerce-ios-sdk.git", :tag => "#{s.version}" }

  s.frameworks   = 'Foundation'
  s.requires_arc = true

  s.subspec 'Utilities' do |utilities|
    utilities.dependency 'XsollaSDKUtilities', "~> #{s.version}"
  end

  s.subspec 'LoginKit' do |login|
    login.dependency 'XsollaSDK/Utilities'
    login.dependency 'XsollaSDKLoginKit', "~> #{s.version}"
  end

  s.subspec 'StoreKit' do |store|
    store.dependency 'XsollaSDK/Utilities'
    store.dependency 'XsollaSDKStoreKit', "~> #{s.version}"
  end

  s.subspec 'InventoryKit' do |inventory|
    inventory.dependency 'XsollaSDK/Utilities'
    inventory.dependency 'XsollaSDKInventoryKit', "~> #{s.version}"
  end

  s.subspec 'PaymentsKit' do |payments|
    payments.dependency "XsollaSDK/Utilities"
    payments.dependency 'XsollaSDKPaymentsKit', "~> #{s.version}"
  end

end
