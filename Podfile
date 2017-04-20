# Uncomment this line to define a global platform for your project
  platform :ios, '9.0'

target 'Vantage' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # Pods for Vantage
  pod 'Armchair', '>= 0.1'
  pod 'IQKeyboardManagerSwift'
  #  pod 'Stripe', '~> 6.2.0'
  # pod 'Alamofire', '~> 3.4'
  pod 'OneSignal'
  pod 'SwiftyButton', '0.4.0'
  pod 'Firebase'
  pod 'Firebase/AdMob'
  pod 'Firebase/Analytics'
  pod 'Firebase/AppIndexing'
  pod 'Firebase/Auth'
  pod 'Firebase/Crash'
  pod 'Firebase/Database'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Storage'
  pod 'JSQMessagesViewController'
  pod 'NVActivityIndicatorView'
  pod 'SDWebImage', '~>3.8' 
  pod 'Siren'
  pod 'Onboard'
  pod 'TextFieldEffects'  
  pod 'BRYXBanner'

  target 'VantageTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'VantageUITests' do
    inherit! :search_paths
    # Pods for testing
  end

	post_install do |installer|
		installer.pods_project.targets.each do |target|
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_VERSION'] = '3.0'
			end
		end
	end

end
