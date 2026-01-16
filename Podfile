# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'InkOS' do
  # Pods for InkOS
  pod 'MyScriptInteractiveInk-Runtime', '4.2.1'
  pod 'iosMath'

  # Firebase - with modular headers for Swift compatibility
  pod 'FirebaseCore', :modular_headers => true
  pod 'FirebaseAuth', :modular_headers => true
  pod 'FirebaseFirestore', :modular_headers => true
  pod 'FirebaseCoreInternal', :modular_headers => true
  pod 'FirebaseSharedSwift', :modular_headers => true
  pod 'GoogleUtilities', :modular_headers => true

  # Firebase dependencies that need modular headers
  pod 'FirebaseAuthInterop', :modular_headers => true
  pod 'FirebaseAppCheckInterop', :modular_headers => true
  pod 'RecaptchaInterop', :modular_headers => true
  pod 'FirebaseFirestoreInternal', :modular_headers => true
end

# Test target needs access to the same pods for compilation.
# Tests use mocks so they don't call MyScript at runtime, but need headers for @testable import InkOS.
target 'InkOSTests' do
  # Inherit pods from main target
  pod 'MyScriptInteractiveInk-Runtime', '4.2.1'
end

# Post-install hook to fix deployment target warnings
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
