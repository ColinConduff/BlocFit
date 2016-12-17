# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'

target 'BlocFit' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BlocFit

  target 'BlocFitTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BlocFitUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  pod 'GoogleMaps'
  pod 'GooglePlaces'

  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'

end

plugin 'cocoapods-keys', {
  :project => "BlocFit",
  :keys => [
    "googleMapsAPIKey"
  ]
}
