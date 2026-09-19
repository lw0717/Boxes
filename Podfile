# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

source 'https://cdn.cocoapods.org'

target 'Boxes' do

  pod 'MBProgressHUD', :inhibit_warnings => true

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO',
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end

