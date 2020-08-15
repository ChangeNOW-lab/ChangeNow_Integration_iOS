Pod::Spec.new do |s|
  s.name         = "CNExchange"
  s.version      = "0.1.0"
  s.summary      = 'ChangeNOW client SDK for iOS.'

  s.authors           = "ChangeNOW"
  s.homepage          = "https://changenow.io"
  s.documentation_url = "https://changenow.io"
  s.license           = { :type => "MIT", :file => "LICENSE.txt" }

  s.ios.deployment_target = '11.0'
  s.swift_version         = '5.0'
  s.source                = { :git => 'https://changenow.io', :tag => s.version.to_s }
  
  s.dependency  'Moya'
  s.dependency  'Kingfisher'
  s.dependency  'PocketSVG'
  s.dependency  'R.swift'
  s.dependency  'CocoaLumberjack'
  s.dependency  'SnapKit'
  s.dependency  'NVActivityIndicatorView'
  s.dependency  'Resolver'

  s.frameworks   = 'Foundation'
  s.source_files = 'CNExchange/**/*'

end
