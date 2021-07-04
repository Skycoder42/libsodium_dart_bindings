#import "SodiumLibsPlugin.h"
#if __has_include(<sodium_libs/sodium_libs-Swift.h>)
#import <sodium_libs/sodium_libs-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sodium_libs-Swift.h"
#endif

@implementation SodiumLibsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSodiumLibsPlugin registerWithRegistrar:registrar];
}
@end
