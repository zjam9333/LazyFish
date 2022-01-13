Pod::Spec.new do |spec|
  spec.name             = 'LazyFish'
  spec.version          = '0.1'
  spec.license          = { :type => 'MIT' }
  spec.homepage         = 'https://github.com/ZJamm1993/LazyFish'
  spec.authors          = { 'ZJam' => '670231925@qq.com' }
  spec.summary          = 'A light-weight DSL style UIKit builder.'
  spec.source           = { :git => 'https://github.com/ZJamm1993/LazyFish.git', :branch => 'pod' }
  spec.source_files     = 'LazyFishCore/*'
  spec.framework        = 'UIKit'
  spec.requires_arc     = true
  spec.swift_version   = '5.0'
  spec.platform         = :ios, '9.0'
end
