# Supress warning messages.
original_verbose, $VERBOSE = $VERBOSE, nil

# Read file
vars_from_file = File.read("../Dependencies/PayUParamsKit/GitHub/Version.txt")
eval(vars_from_file)

# Activate warning messages again.
$VERBOSE = original_verbose

Pod::Spec.new do |s|
  s.name                = "PayUIndia-Logger"
  s.version             = LOGGER_KIT_POD_VERSION
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "A lightweight SDK which supports logging in PayU's SDKs"
  s.description         = "A lightweight SDK which supports logging in PayU's SDKs. Use 'verbose', 'error' or 'disable' for loggingLevel in UPICore SDK to manage logging"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.name}_#{s.version}"
                          }
  
  s.ios.deployment_target = "10.0"
  s.vendored_frameworks = 'Dependencies/PayULoggerKit.xcframework'
end
