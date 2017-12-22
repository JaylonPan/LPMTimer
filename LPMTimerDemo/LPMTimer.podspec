Pod::Spec.new do |s|

  s.name         = "LPMTimer"
  s.version      = "0.0.1"
  s.summary      = "LPMTimer."
  s.description  = <<-DESC
                    LPMTimer is a timer which using block for schedule. 
                   DESC

  s.homepage     = "https://github.com/JaylonPan/LPMTimer"
  s.source       = {:git => "https://github.com/JaylonPan/LPMTimer.git", :tag => "#{s.version}"}
  s.license      = { :type => 'MIT', :text => <<-LICENSE
                      Copyright 2017
                      JaylonPan
                    LICENSE
                    }
  s.author       = { "Jaylon" => "269003942@qq.com" }
  s.platform     = :ios, "8.0"
  s.source_files  = "LPMTimer.{h,m}"
  s.header_dir = 'LPMTimer'
  
end