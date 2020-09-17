Pod::Spec.new do |s|
  s.name                = "PayUIndia-Logger"
  s.version             = "1.1.0"
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "A lightweight SDK which supports logging in PayU's SDKs"
  s.description         = "A lightweight SDK which supports logging in PayU's SDKs. Use 'verbose', 'error' or 'disable' for loggingLevel in UPICore SDK to manage logging"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.name}_#{s.version}"
                          }
  
  s.ios.deployment_target = "10.0"
  s.vendored_frameworks = 'Dependencies/PayULogger.framework'
end
