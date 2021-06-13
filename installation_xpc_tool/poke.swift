import Darwin
import XPC
import Foundation
import Virtualization

// to let XPC figure out that we have their framework linked
print(VZVirtualMachineConfiguration())

let xpcConnection = xpc_connection_create("com.apple.Virtualization.Installation", nil)
// let xpcConnection = xpc_connection_create("com.apple.Virtualization.VirtualMachine", nil)
print(xpcConnection)
xpc_connection_set_event_handler(xpcConnection) {xpcObject in
    print("What, an incoming connection?", xpcObject)
}
print("activating")
print(xpcConnection)
xpc_connection_activate(xpcConnection)
print(xpcConnection)
print("activated")

func ensureConnection(xpcConnection: xpc_connection_t) {
    let dumbMessage = xpc_dictionary_create_empty()
    xpc_dictionary_set_uint64(dumbMessage, "ensure_connection", 0x70696e67)
    let response = xpc_connection_send_message_with_reply_sync(xpcConnection, dumbMessage)
    print(response)
}

ensureConnection(xpcConnection: xpcConnection)

var auditToken = audit_token_t()

xpc_connection_get_audit_token(xpcConnection, &auditToken)
print(auditToken)

var filePath = "/Users/zhuowei/tinyipsw.ipsw"

let sandboxExtension = sandbox_extension_issue_file_to_process(APP_SANDBOX_READ, filePath, 0, auditToken)!
print(sandboxExtension)

let dumbMessage = xpc_dictionary_create_empty()
if true {
    xpc_dictionary_set_string(dumbMessage, "name", "load_restore_image")
    let dumbArguments = xpc_array_create_empty()
    xpc_array_set_string(dumbArguments, XPC_ARRAY_APPEND, filePath)
    let innerArray = xpc_array_create_empty()
    xpc_array_set_string(innerArray, XPC_ARRAY_APPEND, sandboxExtension)
    xpc_array_set_value(dumbArguments, XPC_ARRAY_APPEND, innerArray)
    xpc_dictionary_set_value(dumbMessage, "arguments", dumbArguments)
}
if false {
    xpc_dictionary_set_uint64(dumbMessage, "ensure_connection", 0x70696e67)
}
let response = xpc_connection_send_message_with_reply_sync(xpcConnection, dumbMessage)
print(response)
let resultDict = xpc_dictionary_get_value(response, "result")!
if let errorData = xpc_dictionary_get_value(resultDict, "error") {
    print(errorData)
    let myData = Data(bytes: xpc_data_get_bytes_ptr(errorData)!, count: xpc_data_get_length(errorData))
    print(try! PropertyListSerialization.propertyList(from: myData, format: nil))
} else if let valueData = xpc_dictionary_get_value(resultDict, "value") {
    print(valueData)
    let myData = Data(bytes: xpc_data_get_bytes_ptr(valueData)!, count: xpc_data_get_length(valueData))
    print(try! PropertyListSerialization.propertyList(from: myData, format: nil))
}
