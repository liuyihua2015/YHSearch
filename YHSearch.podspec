#
# Be sure to run `pod lib lint YHSearch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YHSearch'
  s.version          = '0.1.3'
  s.summary          = '简单的历史和热门搜索框'
  s.description      = <<-DESC
        一个简单的历史搜索和热门搜索控制器
                       DESC
  s.homepage         = 'https://github.com/liuyihua2015/YHSearch'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuyihua2015@sina.com' => 'liuyihua2015@sina.com' }
  s.source           = { :git => 'https://github.com/liuyihua2015/YHSearch.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.source_files = 'YHSearch/Classes/**/*'
  s.resource_bundles = {
    'YHSearch' => ['YHSearch/Assets/*']
  }
end
