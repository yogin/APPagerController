Pod::Spec.new do |s|
  s.name             = "APPagerController"
  s.version          = "1.0.4"
  s.summary          = "A controller to page horizontally between child controllers"
  s.description      = <<-DESC
                       This controller allows you to have child controllers and swipe through them horizontally.

                       These child controllers also have titles associated with them which you can swipe through.

                       Child controllers and titles will be swiped together.
                       DESC
  s.homepage         = "https://github.com/yogin/APPagerController"
  s.license          = 'MIT'
  s.author           = { "Anthony Powles" => "pod+appagercontroller@idreamz.net" }
  s.source           = { :git => "https://github.com/yogin/APPagerController.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'APPagerController' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = ['UIKit']
end
