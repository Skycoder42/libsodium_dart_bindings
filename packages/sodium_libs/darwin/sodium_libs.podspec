#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sodium_libs.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sodium_libs'
  s.version          = '3.4.7-dev.1'
  s.summary          = 'Flutter companion package to sodium that provides the low-level libsodium binaries for easy use.'
  s.description      = <<-DESC
Flutter companion package to sodium that provides the low-level libsodium binaries for easy use.
                       DESC
  s.homepage         = 'https://github.com/Skycoder42/libsodium_dart_bindings'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Skycoder42' => 'skycoder42@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'sodium_libs/Sources/sodium_libs/**/*.swift'
  s.resource_bundles = {'plugin_name_privacy' => ['sodium_libs/Sources/sodium_libs/PrivacyInfo.xcprivacy']}

  s.ios.dependency 'Flutter'
  s.ios.deployment_target = '12.0'

  s.osx.dependency 'FlutterMacOS'
  s.osx.deployment_target = '10.14'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # libsodium
  s.prepare_command = 'dart run ../tool/libsodium/download.dart darwin'
  s.vendored_frameworks = "Libraries/libsodium.xcframework"
end
