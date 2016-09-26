Pod::Spec.new do |s|
  s.name             = 'MagazineViewController'
  s.version          = '1.0.0'
  s.summary          = 'A simple book-like paging view controller'
  s.description      = <<-DESC
  A simple paging view controller, with an interactive gesture, that mimics a magazine paging effect.
                       DESC

  s.homepage         = 'https://github.com/macoscope/MagazineViewController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Macoscope' => 'info@macoscope.com' }
  s.source           = { :git => 'https://github.com/macoscope/MagazineViewController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/macoscope'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MagazineViewController/Classes/**/*'
  s.private_header_files = 'MagazineViewController/Classes/Private/**/*.h'
end
