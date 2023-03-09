#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sodium_libs.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sodium_libs'
  s.version          = '1.2.0'
  s.summary          = 'Flutter companion package to sodium that provides the low-level libsodium binaries for easy use.'
  s.description      = <<-DESC
Flutter companion package to sodium that provides the low-level libsodium binaries for easy use.
                       DESC
  s.homepage         = 'https://github.com/Skycoder42/libsodium_dart_bindings'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Skycoder42' => 'skycoder42@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.dependency 'Sodium'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
