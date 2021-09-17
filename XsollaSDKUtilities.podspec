Pod::Spec.new do |s|

  s.name         = 'XsollaSDKUtilities'
  s.version      = '0.3.0'
  s.summary      = 'Shared interchange utility methods for Xsolla libraries. Not intended for direct use.'
  s.description  = <<-DESC
                   This module contains utility methods that are shared between Xsolla libraries. This pod doesn’t expose any headers and isn't intended for direct use, but rather as a dependency of Xsolla libraries.
                   The module includes the following submodules:
                     * Networking — a networking layer
                     * CoreAPI — base classes for working with API
                     * LoggerKit — a logging tool
                   DESC

  s.author       = 'Xsolla (USA), Inc.'
  s.homepage     = 'http://www.xsolla.com'
  s.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }

  s.platform     = :ios, '11.0'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/xsolla/commerce-ios-sdk.git", :tag => "#{s.version}" }

  s.frameworks   = 'Foundation'
  s.requires_arc = true

  s.source_files = 'Utilities/**/*.{h,m,swift}'

end
