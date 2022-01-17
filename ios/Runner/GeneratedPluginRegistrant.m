//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<camera/CameraPlugin.h>)
#import <camera/CameraPlugin.h>
#else
@import camera;
#endif

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<scandit_flutter_datacapture_barcode/ScanditFlutterDataCaptureBarcodePlugin.h>)
#import <scandit_flutter_datacapture_barcode/ScanditFlutterDataCaptureBarcodePlugin.h>
#else
@import scandit_flutter_datacapture_barcode;
#endif

#if __has_include(<scandit_flutter_datacapture_core/ScanditFlutterDataCaptureCorePlugin.h>)
#import <scandit_flutter_datacapture_core/ScanditFlutterDataCaptureCorePlugin.h>
#else
@import scandit_flutter_datacapture_core;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [CameraPlugin registerWithRegistrar:[registry registrarForPlugin:@"CameraPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [ScanditFlutterDataCaptureBarcodePlugin registerWithRegistrar:[registry registrarForPlugin:@"ScanditFlutterDataCaptureBarcodePlugin"]];
  [ScanditFlutterDataCaptureCorePlugin registerWithRegistrar:[registry registrarForPlugin:@"ScanditFlutterDataCaptureCorePlugin"]];
}

@end
