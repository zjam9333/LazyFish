Pod::Spec.new do |s|
  s.name             = "ZKitCore"
  s.version          = "0.0.2"
  s.summary          = "A short description of ZKitCore."
  s.homepage         = "https://github.com/ZJamm1993"
  s.license          = "LICENSE"
  s.author           = { "zhangjingjian" => "zhangjingjian@joyy.com" }
  s.source           = { :git => "https://git.duowan.com/zhangjingjian/zkit", :tag => s.version }

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'ZKitCore/*.{swift}'

  s.frameworks = 'UIKit'
  s.module_name = 'ZKitCore'
  s.swift_version = "5.0"
end
