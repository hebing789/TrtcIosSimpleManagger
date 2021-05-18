#
# Be sure to run `pod lib lint TrtcIosSimpleManagger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TrtcIosSimpleManagger'
  s.version          = '0.0.1'
  s.summary          = 'TRTC TXLiteSDK  Pod of TrtcIosSimpleManagger.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/hebing789/TrtcIosSimpleManagger'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hebing789' => '1101918842@qq.com' }
  s.source           = { :git => 'https://github.com/hebing789/TrtcIosSimpleManagger.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'TrtcIosSimpleManagger/Classes/**/*'
  s.resource_bundles = {
    'TrtcIosSimpleManagger' => ['TrtcIosSimpleManagger/Assets/*.bundle']
  }

  s.dependency 'TXLiteAVSDK_Professional','8.3.9884'
  # 在podfile中使用use_frameworks!导致报错,允许使用静态库TXLiteAVSDK_Professional
  s.static_framework = true
  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
  
  # s.resource_bundles = {
  #   'TrtcIosSimpleManagger' => ['TrtcIosSimpleManagger/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
