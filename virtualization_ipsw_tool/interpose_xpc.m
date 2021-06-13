@import Darwin;
@import Foundation;
@import XPC;

#define DYLD_INTERPOSE(_replacement, _replacee)                               \
  __attribute__((used)) static struct {                                       \
    const void* replacement;                                                  \
    const void* replacee;                                                     \
  } _interpose_##_replacee __attribute__((section("__DATA,__interpose"))) = { \
      (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee}

// hook xpc
xpc_connection_t wdb_xpc_connection_create(const char* name, dispatch_queue_t targetq) {
  NSLog(@"%s %@", name, targetq);
  fprintf(stderr, "%s\n", [NSString stringWithFormat:@"%s %@", name, targetq].UTF8String);
  return xpc_connection_create(name, targetq);
}
DYLD_INTERPOSE(wdb_xpc_connection_create, xpc_connection_create);

void wdb_xpc_connection_send_message(xpc_connection_t connection, xpc_object_t message) {
  NSLog(@"%@ %@", connection, message);
  fprintf(stderr, "%s\n", [NSString stringWithFormat:@"%@ %@", connection, message].UTF8String);
}
DYLD_INTERPOSE(wdb_xpc_connection_send_message, xpc_connection_send_message);

void wdb_xpc_connection_send_message_with_reply(xpc_connection_t connection, xpc_object_t message,
                                                dispatch_queue_t targetq, xpc_handler_t handler) {
  NSLog(@"%@ %@ %@ %@", connection, message, targetq, handler);
  fprintf(
      stderr, "%s\n",
      [NSString stringWithFormat:@"%@ %@ %@ %@", connection, message, targetq, handler].UTF8String);
  if (!strcmp(xpc_dictionary_get_string(message, "name"), "load_restore_image")) {
    dispatch_async(targetq, ^{
      xpc_object_t result_dict = xpc_dictionary_create_empty();
      xpc_dictionary_set_bool(result_dict, "has_value", true);
      NSData* plist_data = [NSData dataWithContentsOfFile:@"KnownGoodReturn.plist"];
      xpc_dictionary_set_data(result_dict, "value", plist_data.bytes, plist_data.length);
      xpc_object_t response = xpc_dictionary_create_empty();
      xpc_dictionary_set_value(response, "result", result_dict);
      handler(response);
    });
  }
}
DYLD_INTERPOSE(wdb_xpc_connection_send_message_with_reply, xpc_connection_send_message_with_reply);

xpc_object_t wdb_xpc_connection_send_message_with_reply_sync(xpc_connection_t connection,
                                                             xpc_object_t message) {
  NSLog(@"%@ %@", connection, message);
  fprintf(stderr, "reply sync %s\n",
          [NSString stringWithFormat:@"%@ %@", connection, message].UTF8String);
  if (xpc_dictionary_get_uint64(message, "ensure_connection") == 0x70696e67) {
    xpc_object_t response = xpc_dictionary_create_empty();
    xpc_dictionary_set_uint64(response, "ensure_connection", 0x706f6e67);
    return response;
  }
  return nil;
}
DYLD_INTERPOSE(wdb_xpc_connection_send_message_with_reply_sync,
               xpc_connection_send_message_with_reply_sync);
extern char* sandbox_extension_issue_file_to_process();
char* wdb_sandbox_extension_issue_file_to_process() {
  fprintf(stderr, "sandbox_extension_issue_file_to_process\n");
  return strcpy(malloc(0x100), "nice");
}
DYLD_INTERPOSE(wdb_sandbox_extension_issue_file_to_process,
               sandbox_extension_issue_file_to_process);
extern int sandbox_extension_release();
int wdb_sandbox_extension_release() {
  fprintf(stderr, "sandbox_extension_release\n");
  return 0;
}

DYLD_INTERPOSE(wdb_sandbox_extension_release, sandbox_extension_release);
