Pod::Spec.new do |s|
  s.name             = 'justpass-me'
  s.version          = '0.1.3'
  s.summary          = 'justpass-me iOS sdk for passkeys'
  s.homepage         = 'https://www.justpass.me'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Justpass.me Developer' => 'shaer@justpass.me' }
  s.source           = { :git => 'https://github.com/justpass-me/justpass-me-iOS-sdk.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.ios.vendored_frameworks = 'justpass-me/Frameworks/JustPassMeFramework.xcframework'
  s.frameworks = 'UIKit'
  s.swift_versions = '4.0'
end
