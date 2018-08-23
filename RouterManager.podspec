#
# Be sure to run `pod lib lint RouterManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RouterManager'
  s.version          = '1.0'
  s.summary          = 'RouterManager is a quick to implement library that handles in-app routing from sources such as deep links.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'RouterManager is a quick to implement library that handles in-app routing from sources such as deep links. Quickly add supported routes, and inherit protocol method to get routing.'

  s.homepage         = 'https://github.com/shop-masse/RouterManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Brayden' => 'brayden.wilmoth@shopmasse.com' }
  s.source           = { :git => 'https://github.com/shop-masse/RouterManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '3.2'

  s.source_files = 'RouterManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RouterManager' => ['RouterManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
