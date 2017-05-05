Pod::Spec.new do |s|
  s.name         = 'Ansi'
  s.version      = '1.0.0'
  s.summary      = "Ansi parser written in Swift 3"
  s.description = "Ansi parser written in Swift 3."
  s.homepage     = 'https://github.com/oleander/Ansi'
  s.license      = 'MIT'
  s.author = { 'Linus Oleander' => 'linus@oleander.io' }
  s.platform = :osx, '10.10'
  s.source = { git: 'https://github.com/oleander/Ansi.git', tag: s.version.to_s }
  s.source_files = 'Source/**/*.swift'
  s.dependency 'FootlessParser'
  s.dependency 'Dollar'
  s.dependency 'Cent'
  s.dependency 'Hue'
  s.dependency 'Attr'
end
