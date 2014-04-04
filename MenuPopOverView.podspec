#
#  Be sure to run `pod spec lint MenuPopOverView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "MenuPopOverView"
  s.version      = "0.0.1"
  s.summary      = "A custom PopOverView looks like UIMenuController works on iPhone."
  s.homepage     = "https://github.com/camelcc/MenuPopOverView"
  s.screenshots  = "https://github.com/camelcc/MenuPopOverView/blob/master/popOver.png"
  s.license      = 'MIT'
  s.author             = { "camel_young" => "camel.young@gmail.com" }
  s.social_media_url = "http://twitter.com/camel_young"
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/camelcc/MenuPopOverView.git", :tag => "0.0.1" }
  s.source_files  = 'MenuPopOverView'
  s.requires_arc = true
end
