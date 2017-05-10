target 'Ansi' do
  use_frameworks!
  platform :osx, '10.11'

  pod 'Ansi', path: "."

  target 'Tests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble', '< 7.0.0'
  end
end
