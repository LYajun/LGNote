

Pod::Spec.new do |spec|

  spec.name         = "LGNote"
  spec.version      = "1.3.8"
  spec.summary      = "笔记公共工具"

  spec.homepage     = "https://github.com/LYajun/LGNote"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.frameworks =  "Foundation","UIKit"


  spec.author             = { "刘亚军" => "liuyajun1999@icloud.com" }

  

  spec.platform     = :ios,"8.0"
  spec.ios.deployment_target = "8.0"



  spec.source       = { :git => "https://github.com/LYajun/LGNote.git", :tag => spec.version }


  spec.source_files  = "LGNote", "LGNote/**/*.{h,m}"

  spec.public_header_files = "Helper/YBIBUtilities.h"


  spec.resources = "LGNote/Resource/LGNote.bundle"

  spec.requires_arc = true

  spec.dependency 'Masonry'
  spec.dependency 'MJExtension'
  spec.dependency 'LGAlertHUD'
  spec.dependency 'ReactiveObjC'
  spec.dependency 'AFNetworking'
  spec.dependency 'MJRefresh'
  spec.dependency 'TFHpple'
  spec.dependency 'YYImage'
  spec.dependency 'SDWebImage'
  spec.dependency 'BlocksKit'
  
end
