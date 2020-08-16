Pod::Spec.new do |s|
  s.name         = "CNIntegration"
  s.version      = "0.1.1"
  s.summary      = 'ChangeNOW client SDK for iOS.'

  s.authors           = "ChangeNOW"
  s.homepage          = "https://changenow.io"
  s.documentation_url = "https://github.com/ChangeNOW-lab/ChangeNow_Integration_iOS.git"
  s.license           = { :type => "MIT", :file => "LICENSE.txt" }

  s.ios.deployment_target = '11.0'
  s.swift_version         = '5.0'
  s.source                = { :git => 'https://github.com/ChangeNOW-lab/ChangeNow_Integration_iOS.git', :tag => s.version.to_s }
  
  s.dependency  'Moya', '~> 14.0'
  s.dependency  'Kingfisher', '~> 5.14'
  s.dependency  'PocketSVG', '~> 2.5'
  s.dependency  'R.swift', '~> 5.2'
  s.dependency  'CocoaLumberjack', '~> 3.6'
  s.dependency  'SnapKit', '~> 5.0'
  s.dependency  'NVActivityIndicatorView', '4.8.0'
  s.dependency  'Resolver', '~> 1.1'

  s.frameworks   = 'Foundation'
  s.source_files = 'CNIntegration/**/*.{h,m,swift}'
  s.resources = 'CNIntegration/Resources/**/*.{xcassets,strings}'

end
