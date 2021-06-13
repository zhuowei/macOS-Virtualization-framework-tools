@import Darwin;
@import Virtualization;
char* printMe(id o) { return [o debugDescription].UTF8String; }

int main(int argc, char** argv) {
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
              exit(1);
            }];
  NSLog(@"cf run loop");
  CFRunLoopRun();
  return 0;
}
