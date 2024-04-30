Pod::Spec.new do |s|
  s.name                = "PayUIndia-UPICore"
  s.version             = "7.1.2"
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "UPI Core SDK for UPI payments on iOS"
  s.description         = "This SDK helps in paying via UPI Collect and UPI intent payments on iOS"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.name}_#{s.version}"
                          }
  
  s.ios.deployment_target = "12.0"
  s.vendored_frameworks = 'Dependencies/PayUUPICoreKit.xcframework'
  s.dependency            'PayUIndia-PayUParams', '~> 4.4'
  s.dependency            'PayUIndia-Networking', '~> 4.1'
  
end
