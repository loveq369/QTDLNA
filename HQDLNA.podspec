#
# Be sure to run `pod lib lint QTDLNA.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QTDLNA'
  s.version          = '0.1.9'
  s.summary          = 'DLNA投屏'


  s.description      = <<-DESC
  (基于MRDLNA)DLNA投屏,支持各大主流盒子互联网电视.
                       DESC

  s.homepage         = 'https://github.com/sillker/QTDLNA'
  
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sillker' => '269055130@qq.com' }
  s.source           = { :git => 'https://github.com/sillker/QTDLNA.git', :tag => s.version}
  #s.social_media_url = 'http://cocomccree.cn/'

  s.platform     = :ios, "9.0"
  s.requires_arc = true

  s.source_files = 'MRDLNA/**/*{h,m}'
  
  # s.resource_bundles = {
  #   'MRDLNA' => ['MRDLNA/Assets/*.png']
  # }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  
  s.libraries = 'icucore', 'c++', 'z', 'xml2'
  
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'CocoaLumberjack','~>3.0.0'
  
  #s.xcconfig = {'ENABLE_BITCODE' => 'NO',
  #    'HEADER_SEARCH_PATHS' => '${SDKROOT}/usr/include/libxml2',
  #    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  #}
  
  #s.subspec 'MRC' do |sp|
  #    sp.source_files = 'MRDLNA/Classes/MRC/**/*'
  #    sp.requires_arc = false
  #end
end
