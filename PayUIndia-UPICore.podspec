Pod::Spec.new do |s|
  s.name                = "PayUIndia-UPICore"
  s.version             = "1.1.0-beta1"
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "UPI Core SDK for UPI payments on iOS"
  s.description         = "This SDK helps in paying via UPI Collect and UPI intent payments on iOS"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.name}_#{s.version}"
                          }
  
  s.ios.deployment_target = "10.0"
  s.vendored_frameworks = 'Dependencies/PayUUPICore.framework'

  s.dependency            'PayUIndia-Networking', "1.1.0-beta1"
  s.dependency            'Socket.IO-Client-Swift', '15.1.0'
  
end
