Tools for exploring the internals of Virtualization.framework's Mac virtualization support.

I made this since I don't have an Apple Silicon Mac but still want to see how it parses IPSWs.

- virtualization_ipsw_tool: calls VZMacOSRestoreImage with XPC hooking to dump the XPC protocol.
- installation_xpc_tool: calls the Installation XPC service directly on an Intel machine and dumps the BuildManifest of an ipsw.
