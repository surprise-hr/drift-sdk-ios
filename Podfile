platform :ios, '8.0'
use_frameworks!

target 'Drift-SDK' do
    pod 'ObjectMapper', '~> 3.0'
    pod 'SlackTextViewController', '~> 1.9.3'
    pod 'AlamofireImage', '~> 3.3'
    pod 'SVProgressHUD', '~> 1.1'
    pod 'Starscream', '~> 3.0'
end

target 'DriftTests' do
    pod 'ObjectMapper', '~> 3.0'
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['Alamofire', 'AlamofireImage'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
