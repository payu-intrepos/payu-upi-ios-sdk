

Pod::Spec.new do |s|
  s.name                = "PayUIndia-Networking"
  s.version             = "5.0.0"
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "A lightweight framework to help in mundane tasks of network calls"
  s.description         = "An enum oriented framework to define your network endpoints for easy implemention of network layer"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.name}_#{s.version}"
                          }
  
  s.ios.deployment_target = "13.0"
  s.vendored_frameworks = 'Dependencies/PayUNetworkingKit.xcframework'
  s.dependency            'PayUIndia-Logger', '~> 5.0'

end
