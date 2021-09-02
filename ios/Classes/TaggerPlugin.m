#import "TaggerPlugin.h"
#if __has_include(<tagger/tagger-Swift.h>)
#import <tagger/tagger-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tagger-Swift.h"
#endif

@implementation TaggerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTaggerPlugin registerWithRegistrar:registrar];
}
@end
