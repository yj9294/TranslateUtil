#
# Be sure to run `pod lib lint TranslateUtil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TranslateUtil'
  s.version          = '0.6.0'
  s.summary          = 'A short description of TranslateUtil.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yj9294/TranslateUtil'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nico' => 'nicoyang.mason@gmail.com' }
  s.source           = { :git => 'https://github.com/yj9294/TranslateUtil.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'

  s.source_files = 'TranslateUtil/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TranslateUtil' => ['TranslateUtil/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'Network'
   
   s.dependency 'GoogleMLKit/Translate'
   s.dependency 'GoogleMLKit/LanguageID'
   s.dependency 'GoogleMLKit/TextRecognition'
   s.dependency 'GoogleMLKit/TextRecognitionChinese'
   s.dependency 'GoogleMLKit/TextRecognitionDevanagari'
   s.dependency 'GoogleMLKit/TextRecognitionJapanese'
   s.dependency 'GoogleMLKit/TextRecognitionKorean'
   s.static_framework = true
end
