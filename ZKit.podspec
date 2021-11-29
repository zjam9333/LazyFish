Pod::Spec.new do |spec|
  spec.name             = 'ZKit'
  spec.version          = '0.1'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/ZJamm1993/ZKit'
  spec.authors          = { 'ZJam' => '670231925@qq.com' }
  spec.summary          = 'A light-weight DSL style UIKit builder.'
  spec.source           = { :git => 'https://github.com/ZJamm1993/ZKit.git', :branch => 'pod' }
  spec.source_files     = 'ZKitCore/*'
  spec.framework        = 'UIKit'
  spec.requires_arc     = true
end