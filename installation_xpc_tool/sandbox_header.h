#import <sandbox.h>
@import XPC;
extern const char *const APP_SANDBOX_READ;
void xpc_connection_get_audit_token(xpc_connection_t, audit_token_t*);
char* sandbox_extension_issue_file_to_process(const char *extension_class, const char *path, uint32_t flags, audit_token_t);
