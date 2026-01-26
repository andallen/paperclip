# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'InkOS' do
  # Pods for InkOS
  pod 'iosMath', :modular_headers => true

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

target 'InkOSTests' do
  # Inherit pods from main target
end

# Post-install hook to fix deployment target warnings and Firebase linking
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end

  # Fix FirebaseFirestoreInternal weak_framework issue
  # The xcconfig incorrectly adds -weak_framework for a static library
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        xcconfig_path = config.base_configuration_reference&.real_path
        if xcconfig_path && File.exist?(xcconfig_path)
          xcconfig = File.read(xcconfig_path)
          if xcconfig.include?('-weak_framework "FirebaseFirestoreInternal"')
            xcconfig = xcconfig.gsub('-weak_framework "FirebaseFirestoreInternal"', '')
            File.write(xcconfig_path, xcconfig)
          end
        end
      end
    end
  end
end
