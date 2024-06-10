const std = @import("std");

fn defineBool(b: bool) ?u1 {
    return if (b) 1 else null;
}

const ConfigureOptions = struct {
    enable_udev: bool,
    enable_eventfd: bool,
    enable_timerfd: bool,
    enable_logging: bool,
    enable_syslog: bool,
};

fn configureLibusb(
    dep: *std.Build.Dependency,
    m: *std.Build.Module,
    config_header: *std.Build.Step.ConfigHeader,
    options: ConfigureOptions,
) void {
    const target = m.resolved_target.?.result;
    const is_posix = target.os.tag != .windows; // this is an assumption made by libusb

    m.link_libc = true;

    m.addIncludePath(dep.path("libusb"));

    if (target.isDarwin()) {
        m.addIncludePath(dep.path("Xcode"));
    } else if (target.abi == .msvc) {
        m.addIncludePath(dep.path("msvc"));
    } else if (target.abi == .android) {
        m.addIncludePath(dep.path("android"));
    } else {
        m.addConfigHeader(config_header);
    }

    m.addCSourceFiles(.{
        .root = dep.path("libusb"),
        .files = &.{
            "core.c",
            "descriptor.c",
            "hotplug.c",
            "io.c",
            "strerror.c",
            "sync.c",
        },
    });

    // add platform sources
    if (is_posix) {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "events_posix.c",
                "threads_posix.c",
            },
        });
    } else {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "events_windows.c",
                "threads_windows.c",
            },
        });
    }

    // add os sources
    if (target.os.tag.isDarwin()) {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "darwin_usb.c",
            },
        });
        m.linkFramework("IOKit", .{});
        m.linkFramework("CoreFoundation", .{});
        m.linkFramework("Security", .{});
    } else if (target.os.tag == .linux) {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "linux_usbfs.c",
                if (options.enable_udev) "linux_udev.c" else "linux_netlink.c",
            },
        });
        if (options.enable_udev) {
            m.linkSystemLibrary("udev", .{});
        }
    } else if (target.os.tag == .windows) {
        m.addWin32ResourceFile(.{ .file = dep.path("libusb/libusb-1.0.rc") });
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "windows_common.c",
                "windows_usbdk.c",
                "windows_winusb.c",
            },
        });
    } else if (target.os.tag == .netbsd) {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "netbsd_usb.c",
            },
        });
    } else if (target.os.tag == .openbsd) {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "openbsd_usb.c",
            },
        });
    } else if (target.os.tag == .haiku) {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "haiku_pollfs.cpp",
                "haiku_usb_backend.cpp",
                "haiku_usb_raw.cpp",
            },
        });
        m.linkSystemLibrary("be", .{});
    } else if (target.os.tag == .solaris) {
        m.addCSourceFiles(.{
            .root = dep.path("libusb/os"),
            .files = &.{
                "sunos_usb.cpp",
            },
        });
        m.linkSystemLibrary("devinfo", .{});
    }
}

fn addLibrary(
    b: *std.Build,
    dep: *std.Build.Dependency,
    linkage: std.builtin.LinkMode,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    config_header: *std.Build.Step.ConfigHeader,
    options: ConfigureOptions,
) void {
    const lib = std.Build.Step.Compile.create(b, .{
        .name = "usb",

        // TODO: read this from package manifest when it becomes possible
        .version = .{ .major = 1, .minor = 0, .patch = 27 },

        .kind = .lib,
        .linkage = linkage,

        .root_module = .{
            .target = target,
            .optimize = optimize,
        },
    });

    configureLibusb(dep, &lib.root_module, config_header, options);

    lib.installHeader(dep.path("libusb/libusb.h"), "libusb.h");

    b.installArtifact(lib);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep = b.dependency("libusb", .{});

    const build_static = b.option(bool, "static", "Build static lib (default: true)") orelse true;
    const build_shared = b.option(bool, "shared", "Build shared lib (default: true)") orelse true;
    const enable_udev = b.option(bool, "enable_udev", "Use udev for device enumeration and hotplug support (default: false)") orelse false;
    const enable_eventfd = b.option(bool, "enable_eventfd", "Use eventfd for signalling (default: false)") orelse false;
    const enable_timerfd = b.option(bool, "enable_timerfd", "Use eventfd for timing (default: false)") orelse false;
    const disable_log = b.option(bool, "disable_log", "disable all logging (default: false)") orelse false;
    const enable_syslog = b.option(bool, "enable_system_log", "output logging messages to the systemwide log, if supported by the OS (default: false)") orelse false;

    const options = ConfigureOptions{
        .enable_udev = enable_udev,
        .enable_eventfd = enable_eventfd,
        .enable_timerfd = enable_timerfd,
        .enable_logging = !disable_log,
        .enable_syslog = enable_syslog,
    };

    const config_header = b.addConfigHeader(.{ .style = .blank }, .{
        ._GNU_SOURCE = 1,
        .DEFAULT_VISIBILITY = .@"__attribute__ ((visibility (\"default\")))",
        // .PRINTF_FORMAT = .@"__attribute__ ((__format__ (__printf__, a, b)))",
        .@"PRINTF_FORMAT(a, b)" = .@"/* */",
        .PLATFORM_POSIX = defineBool(target.result.os.tag != .windows),
        .PLATFORM_WINDOWS = defineBool(target.result.os.tag == .windows),

        .HAVE_EVENTFD = defineBool(options.enable_eventfd),
        .HAVE_TIMERFD = defineBool(options.enable_timerfd),

        .ENABLE_LOGGING = defineBool(options.enable_logging),
        // .ENABLE_DEBUG_LOGGING = defineBool(options.enable_logging and m.optimize.? == .Debug), // this redirects all contextual logs to the global log callback
        .USE_SYSTEM_LOGGING_FACILITY = defineBool(options.enable_syslog),
    });

    if (build_static) addLibrary(b, dep, .static, target, optimize, config_header, options);
    if (build_shared) addLibrary(b, dep, .dynamic, target, optimize, config_header, options);

    const m = b.addModule("libusb", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    configureLibusb(dep, m, config_header, options);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    configureLibusb(dep, &lib_unit_tests.root_module, config_header, options);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(lib_unit_tests).step);
}
