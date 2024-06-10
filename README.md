# zig-libusb

This module takes full advantage of the zig build system to download and build libusb. There is also a thin zig layer for more natural integration in other zig code.

Tested with the following configurations:
- self-hosted zig 0.12.0 on aarch64-macos
- self-hosted zig 0.13.0 on x86_64-linux

Some effort was spent porting other build configurations as well. Please submit a pull request to verify or fix builds on your system if possible.

# Building

```sh
zig build --release=safe
```

## Options

Run `zig build --help` for the full list of options offered by zig.

```
  -Dtarget=[string]            The CPU architecture, OS, and ABI to build for
  -Dcpu=[string]               Target CPU features to add or subtract
  -Ddynamic-linker=[string]    Path to interpreter on the target system
  -Doptimize=[enum]            Prioritize performance, safety, or binary size
                                 Supported Values:
                                   Debug
                                   ReleaseSafe
                                   ReleaseFast
                                   ReleaseSmall
  -Dstatic=[bool]              Build static lib (default: true)
  -Dshared=[bool]              Build shared lib (default: true)
```

# Zig Layer

The zig layer tries OO-ify the library and remove manual bit-wise operations where possible.

## Installing into your own project

Run this command from your project folder

```sh
zig fetch --save https://github.com/ssttevee/zig-libusb/archive/refs/tags/1.0.27.tar.gz
```

Then add this snippet to your `build.zig` file

```zig
const libusb = b.dependency("libusb", .{
    .optimize = optimize,
    .target = target,
});

exe.root_module.addImport("libusb", libusb.module("libusb"));
```

## Example

```zig
const std = @import("std");
const libusb = @import("libusb");

pub fn main() !void {
    try libusb.init(.{ .log_level = .info });
    defer libusb.deinit();

    const my_device = blk: {
        const devices = try libusb.getDeviceList();
        defer libusb.freeDeviceList(devices);

        for (devices) |device| {
            if (isMyDevice(device)) {
                break :blk device.ref();
            }
        }
    };
    defer my_device.unref();

    var config_desc = try my_device.getActiveConfigDescriptor();
    defer config_desc.deinit();

    const interface_desc = config_desc.interfacesSlice()[0].toSlice()[0];
    const write_endpoint = interface_desc.endpointsSlice()[0];

    std.debug.assert(write_endpoint.bmAttributes.transfer_type == .bulk);
    std.debug.assert(write_endpoint.bEndpointAddress.direction == .output);

    const device_handle = try my_device.open();
    defer device_handle.close();
    defer device_handle.reset() catch {};

    const my_interface = try device_handle.claimInterface(interface_desc.bInterfaceNumber);
    defer my_interface.release();

    const w = my_interface.writable(write_endpoint.bEndpointAddress, 0);
    try std.fmt.format(w.writer(), "Hello World\n", .{});
}
```

The raw c functions are also all accessible

```zig
const std = @import("std");
const libusb = @import("libusb");

pub fn main() !void {
    try libusb.c.libusb_init_context(null, null, 0).result();
    defer libusb.c.libusb_exit(null);
}
```
