#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'sy_flutter_wechat'
  s.version          = '0.2.1'
  s.summary          = '微信SDK flutter插件'
  s.description      = <<-DESC
微信SDK flutter插件
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.dependency 'WechatOpenSDK'
  s.static_framework = true
  s.ios.deployment_target = '8.0'
end

