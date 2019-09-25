Pod::Spec.new do |s|
  s.name         = "MRMailSDK"
  s.version      = "1.4.3"
  s.summary      = "Library for Mail.Ru OAuth2 authorization"
  s.platform     = :ios
  s.ios.deployment_target = '9.0'
  s.source       = { :git => "https://github.com/mailru/mail-auth-sdk-ios.git", :tag => s.version.to_s }
  s.resource_bundles = {
      'MRMailSDKUI' => [ 'mr-mail-sdk/sources/ui/MRMailSDKUI.xcassets',
                         'mr-mail-sdk/sources/ui/ru.lproj/*.strings',
                         'mr-mail-sdk/sources/ui/en.lproj/*.strings' ]
  }
  s.frameworks    = 'Foundation','UIKit','SafariServices','WebKit'
  s.requires_arc = true
  s.license      = "None"
  s.homepage     = "https://github.com/mailru/mail-auth-sdk-ios"
  s.authors      = { 'Aleksandr Karimov' => 'a.karimov@corp.mail.ru' }
  s.default_subspecs = 'Core'

  s.subspec 'Core' do |cs|
    cs.source_files = 'mr-mail-sdk/sources/*.{h,m}', 'mr-mail-sdk/sources/core/**/*.{h,m}', 'mr-mail-sdk/sources/ui/**/*.{h,m}', 'mr-mail-sdk/sources/utils/**/*.{h,m}'
    cs.public_header_files = 'mr-mail-sdk/sources/*.h'
  end
end
