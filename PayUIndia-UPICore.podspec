Pod::Spec.new do |s|
  s.name                = "PayUIndia-UPICore"
  s.version             = "10.5.0"
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "UPI Core SDK for UPI payments on iOS"
  s.description         = "This SDK helps in paying via UPI Collect and UPI intent payments on iOS"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.version}"
                          }
  
  s.ios.deployment_target = "13.0"
  s.vendored_frameworks = 'Dependencies/PayUUPICoreKit.xcframework'
  s.dependency            'PayUIndia-PayUParams', '~> 6.6'
  s.dependency            'PayUIndia-Networking', '~> 5.0'
  s.dependency            'PayUIndia-CommonUI', '~> 2.2'
  
end
