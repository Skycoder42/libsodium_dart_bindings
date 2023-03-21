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
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'

  s.platform = :ios, '11.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # libsodium
  s.vendored_frameworks = "Libraries/libsodium.xcframework"
  s.xcconfig = {
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -force_load $(PODS_ROOT)/../.symlinks/plugins/sodium_libs/ios/Libraries/libsodium.xcframework/ios-arm64_armv7_armv7s/libsodium.a',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -force_load $(PODS_ROOT)/../.symlinks/plugins/sodium_libs/ios/Libraries/libsodium.xcframework/ios-arm64_i386_x86_64-simulator/libsodium.a',
  }
end
