# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'tawk.to' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for tawk.to

  pod 'SKActivityIndicatorView', '0.1.0'
  pod 'PagedLists', '~> 1.0.0'
  pod 'ReachabilitySwift'
  pod 'TPKeyboardAvoiding'

  target 'tawk.toTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'tawk.toUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['SKActivityIndicatorView'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.0'
            end
        end
        
        if ['SKActivityIndicatorView'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
            end
        end
        
    end
end