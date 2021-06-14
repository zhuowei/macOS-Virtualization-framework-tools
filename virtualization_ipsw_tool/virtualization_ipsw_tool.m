@import Darwin;
@import Virtualization;
char* printMe(id o) { return [o debugDescription].UTF8String; }

@interface VZMacOSRestoreImage (PrivateStuff)
- (NSArray<VZMacOSConfigurationRequirements*>*)_configurations;
@end

@interface VZMacHardwareModel (PrivateStuff)
+ (VZMacHardwareModel*)_hardwareModelWithPlatformVersion:(int)platformVersion boardID:(int)boardId;
@end

int main() {
  // BoardID default for version 2 is 0x20 and is not stored in dataRepresentation
  // if I change it, it _is_ stored
  VZMacHardwareModel* model = [VZMacHardwareModel _hardwareModelWithPlatformVersion:2 boardID:0x20];
  fprintf(stderr, "%s %s\n", model.description.UTF8String,
          model.dataRepresentation.description.UTF8String);
  [model.dataRepresentation writeToFile:@"HardwareModel.dat" atomically:false];
  NSURL* outputUrl = [NSURL fileURLWithPath:@"AuxStorage.dat"];
  NSError* error;
  fprintf(stderr, "auxStorage\n");
  VZMacAuxiliaryStorage* auxStorage =
      [[VZMacAuxiliaryStorage alloc] initCreatingStorageAtURL:outputUrl
                                                hardwareModel:model
                                                      options:0
                                                        error:&error];
  fprintf(stderr, "out %p %p\n", error, auxStorage);
  if (!auxStorage) {
    fprintf(stderr, "%s\n", error.description.UTF8String);
  }
  fprintf(stderr, "%s\n", auxStorage.description.UTF8String);
}

int main2(int argc, char** argv) {
  if (argc < 2) {
    fprintf(stderr, "Usage: virtualization_ipsw_tool <path/to/ipsw> [optional/nvram_output.bin]\n");
    return 1;
  }
  NSURL* ipswUrl = [NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]];
  NSLog(@"%@", ipswUrl);
  [VZMacOSRestoreImage
      loadRestoreImageFromURL:ipswUrl
            completionHandler:^(VZMacOSRestoreImage* restoreImage, NSError* error) {
              if (error) {
                NSLog(@"Failed to load restore image! %@", error);
                fprintf(stderr, "Failed to load restore image! %s\n",
                        [error description].UTF8String);
                exit(1);
              }
              NSLog(@"%@", restoreImage);
              fprintf(stderr, "got it %s\n", [restoreImage description].UTF8String);
              fprintf(
                  stderr, "%s\n",
                  [NSString
                      stringWithFormat:
                          @"buildVersion %@ mostFeaturefulSupportedConfiguration %@ (hardwareModel "
                          @"%@, minimumSupportedCPUCount %d, minimumSupportedMemorySize %d) "
                          @"operatingSystemVersion %d:%d:%d url %@ _configurations %@",
                          restoreImage.buildVersion,
                          restoreImage.mostFeaturefulSupportedConfiguration,
                          restoreImage.mostFeaturefulSupportedConfiguration.hardwareModel,
                          (int)restoreImage.mostFeaturefulSupportedConfiguration
                              .minimumSupportedCPUCount,
                          (int)restoreImage.mostFeaturefulSupportedConfiguration
                              .minimumSupportedMemorySize,
                          (int)restoreImage.operatingSystemVersion.majorVersion,
                          (int)restoreImage.operatingSystemVersion.minorVersion,
                          (int)restoreImage.operatingSystemVersion.patchVersion, restoreImage.url,
                          restoreImage._configurations]
                      .UTF8String);
              for (VZMacOSConfigurationRequirements* req in restoreImage._configurations) {
                fprintf(stderr, "%s %s %d %d\n", req.hardwareModel.description.UTF8String,
                        req.hardwareModel.dataRepresentation.description.UTF8String,
                        (int)req.minimumSupportedCPUCount, (int)req.minimumSupportedMemorySize);
              }
              exit(1);
            }];
  NSLog(@"cf run loop");
  CFRunLoopRun();
  return 0;
}
