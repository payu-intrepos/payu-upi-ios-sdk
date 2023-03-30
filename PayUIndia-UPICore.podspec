# Supress warning messages.
original_verbose, $VERBOSE = $VERBOSE, nil

# Read file
vars_from_file = File.read("../Dependencies/PayUParamsKit/GitHub/Version.txt")
eval(vars_from_file)

# Activate warning messages again.
$VERBOSE = original_verbose

Pod::Spec.new do |s|
  s.name                = "PayUIndia-UPICore"
  s.version             = UPI_CORE_POD_VERSION
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "UPI Core SDK for UPI payments on iOS"
  s.description         = "This SDK helps in paying via UPI Collect and UPI intent payments on iOS"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.name}_#{s.version}"
                          }
  
  s.ios.deployment_target = "11.0"
  s.vendored_frameworks = 'Dependencies/PayUUPICoreKit.xcframework'
  
  UPI_CORE_PODSPEC_DEPENDENCIES.each do |dependency|
    dependency
  end
  
end
