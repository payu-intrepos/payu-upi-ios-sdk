# Supress warning messages.
original_verbose, $VERBOSE = $VERBOSE, nil

# Read file
vars_from_file = File.read("../Dependencies/PayUParamsKit/GitHub/Version.txt")
eval(vars_from_file)

# Activate warning messages again.
$VERBOSE = original_verbose

Pod::Spec.new do |s|
  s.name                = "PayUIndia-Networking"
  s.version             = NETWORKING_KIT_POD_VERSION
  s.license             = "MIT"
  s.homepage            = "https://app.gitbook.com/@payumobile/s/sdk-integration/v/master/ios/upi-standalone-ios"
  s.author              = { "PayUbiz" => "contact@payu.in"  }

  s.summary             = "A lightweight framework to help in mundane tasks of network calls"
  s.description         = "An enum oriented framework to define your network endpoints for easy implemention of network layer"

  s.source              = { :git => "https://github.com/payu-intrepos/payu-upi-ios-sdk.git",
                            :tag => "#{s.name}_#{s.version}"
                          }
  
  s.ios.deployment_target = "10.0"
  s.vendored_frameworks = 'Dependencies/PayUNetworkingKit.xcframework'

  NETWORKING_KIT_PODSPEC_DEPENDENCIES.each do |dependency|
    dependency
  end
  
end
