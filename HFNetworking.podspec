Pod::Spec.new do |spec|

  spec.name         = "HFNetworking"
  spec.version      = "1.0.0"
  spec.summary      = "A Network Layer"
  spec.description  = "A Network Layer that simplify the network process"
  spec.homepage     = "https://github.com/ahikmatf/HFNetworking"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { 'Asep Hikmat' => 'asephikmatf@gmail.com' }
  
  # spec.source       = { :path => "." }
  # spec.source_files = "Content/**/*.{swift}"

  spec.platform      = :ios, "10.0"
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.1' }

  spec.dependency 'Alamofire', "~> 4.9.0"

end
