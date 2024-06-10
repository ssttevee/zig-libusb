const std = @import("std");
const testing = std.testing;
const root = @import("./root.zig");

const ClassCode = root.ClassCode;
const DescriptorType = root.DescriptorType;
const BOSType = root.BOSType;
const StandardRequest = root.StandardRequest;
const SupportedSpeed = root.SupportedSpeed;
const DeviceDescriptor = root.DeviceDescriptor;
const EndpointDescriptor = root.EndpointDescriptor;
const InterfaceAssociationDescriptor = root.InterfaceAssociationDescriptor;
const InterfaceAssociationDescriptorArray = root.InterfaceAssociationDescriptorArray;
const InterfaceDescriptor = root.InterfaceDescriptor;
const Interface = root.Interface;
const ConfigDescriptor = root.ConfigDescriptor;
const SSEndpointCompanionDescriptor = root.SSEndpointCompanionDescriptor;
const BOSDeviceCapabilityDescriptor = root.BOSDeviceCapabilityDescriptor;
const BOSDescriptor = root.BOSDescriptor;
const USB20ExtensionDescriptor = root.USB20ExtensionDescriptor;
const SSUSBDeviceCapabilityDescriptor = root.SSUSBDeviceCapabilityDescriptor;
const ContainerIdDescriptor = root.ContainerIdDescriptor;
const PlatformDescriptor = root.PlatformDescriptor;
const ControlSetup = root.ControlSetup;
const Version = root.Version;
const InitOptions = root.InitOptions;
const Context = root.Context;
const Device = root.Device;
const DeviceHandle = root.DeviceHandle;
const Speed = root.Speed;
const ErrorCode = root.ErrorCode;
const UsizeOrErrorCode = root.UsizeOrErrorCode;
const U32OrErrorCode = root.U32OrErrorCode;
const TransferStatus = root.TransferStatus;
const ISOPacketDescriptor = root.ISOPacketDescriptor;
const Transfer = root.Transfer;
const Capability = root.Capability;
const LogLevel = root.LogLevel;
const LogCBMode = root.LogCBMode;
const Pollfd = root.Pollfd;
const HotplugCallbackHandle = root.HotplugCallbackHandle;
const HotplugEvent = root.HotplugEvent;

pub const LogCallbackFn = fn (*Context, LogLevel, [*c]const u8) callconv(.C) void;

/// Available option values for libusb_set_option() and libusb_init_context().
pub const Option = enum(c_uint) {
    /// Set the log message verbosity.
    ///
    /// This option must be provided an argument of type libusb_log_level.
    /// The default level is LIBUSB_LOG_LEVEL_NONE, which means no messages are ever
    /// printed. If you choose to increase the message verbosity level, ensure
    /// that your application does not close the stderr file descriptor.
    ///
    /// You are advised to use level LIBUSB_LOG_LEVEL_WARNING. libusb is conservative
    /// with its message logging and most of the time, will only log messages that
    /// explain error conditions and other oddities. This will help you debug
    /// your software.
    ///
    /// If the LIBUSB_DEBUG environment variable was set when libusb was
    /// initialized, this option does nothing: the message verbosity is fixed
    /// to the value in the environment variable.
    ///
    /// If libusb was compiled without any message logging, this option does
    /// nothing: you'll never get any messages.
    ///
    /// If libusb was compiled with verbose debug message logging, this option
    /// does nothing: you'll always get messages from all levels.
    log_level = 0,

    /// Use the UsbDk backend for a specific context, if available.
    ///
    /// This option should be set at initialization with libusb_init_context()
    /// otherwise unspecified behavior may occur.
    ///
    /// Only valid on Windows. Ignored on all other platforms.
    use_usbdk = 1,

    /// Do not scan for devices
    ///
    /// With this option set, libusb will skip scanning devices in
    /// libusb_init_context().
    ///
    /// Hotplug functionality will also be deactivated.
    ///
    /// The option is useful in combination with libusb_wrap_sys_device(),
    /// which can access a device directly without prior device scanning.
    ///
    /// This is typically needed on Android, where access to USB devices
    /// is limited.
    ///
    /// This option should only be used with libusb_init_context()
    /// otherwise unspecified behavior may occur.
    ///
    /// Only valid on Linux. Ignored on all other platforms.
    no_device_discovery = 2,

    /// Set the context log callback function.
    ///
    /// Set the log callback function either on a context or globally. This
    /// option must be provided an argument of type libusb_log_cb.
    /// Using this option with a NULL context is equivalent to calling
    /// libusb_set_log_cb() with mode LIBUSB_LOG_CB_GLOBAL.
    /// Using it with a non-NULL context is equivalent to calling
    /// libusb_set_log_cb() with mode LIBUSB_LOG_CB_CONTEXT.
    log_cb = 3,
};

/// Structure used for setting options through libusb_init_context.
pub const InitOption = extern struct {
    /// Which option to set
    option: Option,

    /// An integer value used by the option (if applicable).
    value: extern union {
        void: void,
        log_level: LogLevel,
        log_cb: *const LogCallbackFn,
    },
};

/// Deprecated initialization function.
///
/// Equivalent to calling libusb_init_context with no options.
///
/// Returns 0 on success, or a LIBUSB_ERROR code on failure
pub extern fn libusb_init(
    /// Optional output location for context pointer. Only valid on return code
    /// 0.
    ctx: ?*?*Context,
) callconv(.C) ErrorCode;

/// Initialize libusb.
///
/// This function must be called before calling any other libusb function.
///
/// If you do not provide an output location for a context pointer, a default
/// context will be created. If there was already a default context, it will be
/// reused (and nothing will be initialized/reinitialized and options will be
/// ignored). If num_options is 0 then options is ignored and may be NULL.
///
/// Since version 1.0.27, LIBUSB_API_VERSION >= 0x0100010A
///
/// Returns 0 on success, or a LIBUSB_ERROR code on failure
pub extern fn libusb_init_context(
    /// Optional output location for context pointer. Only valid on return code 0.
    ctx: ?*?*Context,
    /// Optional array of options to set on the new context.
    options: ?[*]const InitOption,
    /// Number of elements in the options array.
    num_options: c_int,
) callconv(.C) ErrorCode;

/// Deinitialize libusb.
///
/// Should be called after closing all open devices and before your application
/// terminates.
pub extern fn libusb_exit(
    /// the context to deinitialize, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) void;

/// Deprecated.
///
/// Use libusb_set_option() or libusb_init_context() instead, with the
/// LIBUSB_OPTION_LOG_LEVEL option.
pub extern fn libusb_set_debug(
    /// context, or NULL for the default context. Parameter ignored if only
    /// LIBUSB_LOG_CB_GLOBAL mode is requested.
    ctx: ?*Context,
    /// the log level
    level: LogLevel,
) callconv(.C) void;

/// Set log handler.
///
/// libusb will redirect its log messages to the provided callback function.
/// libusb supports redirection of per context and global log messages. Log
/// messages sent to the context will be sent to the global log handler too.
///
/// If libusb is compiled without message logging or USE_SYSTEM_LOGGING_FACILITY
/// is defined then global callback function will never be called. If
/// ENABLE_DEBUG_LOGGING is defined then per context callback function will
/// never be called.
///
/// Since version 1.0.23, LIBUSB_API_VERSION >= 0x01000107
pub extern fn libusb_set_log_cb(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// pointer to the callback function, or NULL to stop log messages
    /// redirection
    callback: ?*const LogCallbackFn,
    /// mode of callback function operation. Several modes can be selected for
    /// a single callback function, see libusb_log_cb_mode for a description.
    mode: LogCBMode,
) callconv(.C) void;

/// Returns a pointer to const struct libusb_version with the version (major,
/// minor, micro, nano and rc) of the running library.
pub extern fn libusb_get_version() callconv(.C) *const Version;

/// Check at runtime if the loaded library has a given capability.
///
/// This call should be performed after libusb_init_context(), to ensure the
/// backend has updated its capability set.
///
/// Returns nonzero if the running library has the capability, 0 otherwise
pub extern fn libusb_has_capability(
    /// the `Capability` to check for
    capability: Capability,
) callconv(.C) c_int;

/// Returns a constant NULL-terminated string with the ASCII name of a libusb
/// error or transfer status code.
///
/// The caller must not free() the returned string.
pub extern fn libusb_error_name(
    /// The libusb_error or libusb_transfer_status code to return the name of.
    errcode: c_int,
) callconv(.C) [*c]const u8;

/// Set the language, and only the language, not the encoding! used for
/// translatable libusb messages.
///
/// This takes a locale string in the default setlocale format: lang[-region] or
/// lang[_country_region][.codeset]. Only the lang part of the string is used,
/// and only 2 letter ISO 639-1 codes are accepted for it, such as "de". The
/// optional region, country_region or codeset parts are ignored. This means
/// that functions which return translatable strings will NOT honor the
/// specified encoding. All strings returned are encoded as UTF-8 strings.
///
/// If libusb_setlocale() is not called, all messages will be in English.
///
/// The following functions return translatable strings: libusb_strerror().
/// Note that the libusb log messages controlled through LIBUSB_OPTION_LOG_LEVEL
/// are not translated, they are always in English.
///
/// For POSIX UTF-8 environments if you want libusb to follow the standard
/// locale settings, call libusb_setlocale(setlocale(LC_MESSAGES, NULL)), after
/// your app has done its locale setup.
///
/// Returns:
/// * LIBUSB_SUCCESS on success
/// * LIBUSB_ERROR_INVALID_PARAM if the locale doesn't meet the requirements
/// * LIBUSB_ERROR_NOT_FOUND if the requested language is not supported
/// * a LIBUSB_ERROR code on other errors
pub extern fn libusb_setlocale(
    /// locale-string in the form of lang[_country_region][.codeset] or
    /// lang[-region], where lang is a 2 letter ISO 639-1 code
    locale: [*c]const u8,
) callconv(.C) ErrorCode;

/// Returns a constant string with a short description of the given error code,
/// this description is intended for displaying to the end user and will be in
/// the language set by libusb_setlocale().
///
/// The returned string is encoded in UTF-8.
///
/// The messages always start with a capital letter and end without any dot. The
/// caller must not free() the returned string.
pub extern fn libusb_strerror(
    /// the error code whose description is desired
    errcode: c_int,
) callconv(.C) [*c]const u8;

/// Returns a list of USB devices currently attached to the system.
///
/// This is your entry point into finding a USB device to operate.
///
/// You are expected to unreference all the devices when you are done with them,
/// and then free the list with libusb_free_device_list(). Note that
/// libusb_free_device_list() can unref all the devices for you. Be careful not
/// to unreference a device you are about to open until after you have opened
/// it.
///
/// This return value of this function indicates the number of devices in the
/// resultant list. The list is actually one element larger, as it is
/// NULL-terminated.
///
/// Returns the number of devices in the outputted list, or any libusb_error
/// according to errors encountered by the backend.
pub extern fn libusb_get_device_list(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// output location for a list of devices. Must be later freed with
    /// libusb_free_device_list().
    list: *?[*]*Device,
) callconv(.C) UsizeOrErrorCode;

/// Frees a list of devices previously discovered using
/// libusb_get_device_list().
///
/// If the unref_devices parameter is set, the reference count of each device
/// in the list is decremented by 1.
pub extern fn libusb_free_device_list(
    /// the list to free
    list: [*]*Device,
    /// whether to unref the devices in the list
    unref_devices: bool,
) callconv(.C) void;

/// Increment the reference count of a device.
///
/// Returns the same device
pub extern fn libusb_ref_device(
    /// the device to reference
    dev: *Device,
) callconv(.C) *Device;

/// Decrement the reference count of a device.
///
/// If the decrement operation causes the reference count to reach zero, the
/// device shall be destroyed.
pub extern fn libusb_unref_device(
    /// the device to unreference
    dev: *Device,
) callconv(.C) void;

/// Determine the bConfigurationValue of the currently active configuration.
///
/// You could formulate your own control request to obtain this information, but
/// this function has the advantage that it may be able to retrieve the
/// information from operating system caches (no I/O involved).
///
/// If the OS does not cache this information, then this function will block
/// while a control transfer is submitted to retrieve the information.
///
/// This function will return a value of 0 in the config output parameter if the
/// device is in unconfigured state.
///
/// Returns:
/// * 0 on success
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_get_configuration(
    /// a device handle
    dev: *DeviceHandle,
    /// output location for the bConfigurationValue of the active configuration
    /// (only valid for return code 0)
    config: *c_int,
) callconv(.C) ErrorCode;

/// Get the USB device descriptor for a given device.
///
/// This is a non-blocking function; the device descriptor is cached in memory.
///
/// Note since libusb-1.0.16, LIBUSBX_API_VERSION >= 0x01000102, this function
/// always succeeds.
///
/// Returns 0 on success or a LIBUSB_ERROR code on failure
pub extern fn libusb_get_device_descriptor(
    /// the device
    dev: *Device,
    /// output location for the descriptor data
    desc: *DeviceDescriptor,
) callconv(.C) ErrorCode;

/// Get the USB configuration descriptor for the currently active configuration.
///
/// This is a non-blocking function which does not involve any requests being
/// sent to the device.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the device is in unconfigured state
/// * another LIBUSB_ERROR code on error
pub extern fn libusb_get_active_config_descriptor(
    /// a device
    dev: *Device,
    /// output location for the USB configuration descriptor. Only valid if 0
    /// was returned. Must be freed with libusb_free_config_descriptor() after
    /// use.
    config: *?*ConfigDescriptor,
) callconv(.C) ErrorCode;

/// Get a USB configuration descriptor based on its index.
///
/// This is a non-blocking function which does not involve any requests being
/// sent to the device.
///
/// Returns:
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the configuration does not exist
/// * another LIBUSB_ERROR code on error
pub extern fn libusb_get_config_descriptor(
    /// a device
    dev: *Device,
    /// the index of the configuration you wish to retrieve
    config_index: u8,
    /// output location for the USB configuration descriptor. Only valid if 0
    /// was returned. Must be freed with libusb_free_config_descriptor() after
    /// use.
    config: *?*ConfigDescriptor,
) callconv(.C) ErrorCode;

/// Get a USB configuration descriptor with a specific bConfigurationValue.
///
/// This is a non-blocking function which does not involve any requests being
/// sent to the device.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the configuration does not exist
/// * another LIBUSB_ERROR code on error
pub extern fn libusb_get_config_descriptor_by_value(
    /// a device
    dev: *Device,
    /// the bConfigurationValue of the configuration you wish to retrieve
    bConfigurationValue: u8,
    /// output location for the USB configuration descriptor. Only valid if 0
    /// was returned. Must be freed with libusb_free_config_descriptor() after
    /// use.
    config: *?*ConfigDescriptor,
) callconv(.C) ErrorCode;

/// Free a configuration descriptor obtained from
/// libusb_get_active_config_descriptor() or libusb_get_config_descriptor().
///
/// It is safe to call this function with a NULL config parameter, in which
/// case the function simply returns.
pub extern fn libusb_free_config_descriptor(
    /// the configuration descriptor to free
    config: ?*ConfigDescriptor,
) callconv(.C) void;

/// Get an endpoints superspeed endpoint companion descriptor (if any)
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the configuration does not exist
/// * another LIBUSB_ERROR code on error
pub extern fn libusb_get_ss_endpoint_companion_descriptor(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// endpoint descriptor from which to get the superspeed endpoint companion
    /// descriptor
    endpoint: *const EndpointDescriptor,
    /// output location for the superspeed endpoint companion descriptor. Only
    /// valid if 0 was returned. Must be freed with
    /// libusb_free_ss_endpoint_companion_descriptor() after use.
    ep_comp: *?*SSEndpointCompanionDescriptor,
) callconv(.C) ErrorCode;

/// Free a superspeed endpoint companion descriptor obtained from
/// libusb_get_ss_endpoint_companion_descriptor().
///
/// It is safe to call this function with a NULL ep_comp parameter, in which
/// case the function simply returns.
pub extern fn libusb_free_ss_endpoint_companion_descriptor(
    /// the superspeed endpoint companion descriptor to free
    ep_comp: ?*SSEndpointCompanionDescriptor,
) callconv(.C) void;

/// Get a Binary Object Store (BOS) descriptor This is a BLOCKING function,
/// which will send requests to the device.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the device doesn't have a BOS descriptor
/// * another LIBUSB_ERROR code on error
pub extern fn libusb_get_bos_descriptor(
    /// the handle of an open libusb device
    dev_handle: *DeviceHandle,
    /// output location for the BOS descriptor. Only valid if 0 was returned.
    /// Must be freed with libusb_free_bos_descriptor() after use.
    bos: *?*BOSDescriptor,
) callconv(.C) ErrorCode;

/// Free a BOS descriptor obtained from libusb_get_bos_descriptor().
///
/// It is safe to call this function with a NULL bos parameter, in which case
/// the function simply returns.
pub extern fn libusb_free_bos_descriptor(
    /// the BOS descriptor to free
    bos: ?*BOSDescriptor,
) callconv(.C) void;

/// Get an USB 2.0 Extension descriptor.
///
/// Returns
/// * 0 on success
/// * a LIBUSB_ERROR code on error
pub extern fn libusb_get_usb_2_0_extension_descriptor(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// Device Capability descriptor with a bDevCapabilityType of
    /// libusb_capability_type::LIBUSB_BT_USB_2_0_EXTENSION
    /// LIBUSB_BT_USB_2_0_EXTENSION
    dev_cap: *BOSDeviceCapabilityDescriptor,
    /// output location for the USB 2.0 Extension descriptor. Only valid if 0
    /// was returned. Must be freed with
    /// libusb_free_usb_2_0_extension_descriptor() after use.
    usb_2_0_extension: *?*USB20ExtensionDescriptor,
) callconv(.C) ErrorCode;

/// Free a USB 2.0 Extension descriptor obtained from
/// libusb_get_usb_2_0_extension_descriptor().
///
/// It is safe to call this function with a NULL usb_2_0_extension parameter,
/// in which case the function simply returns.
pub extern fn libusb_free_usb_2_0_extension_descriptor(
    /// the USB 2.0 Extension descriptor to free
    usb_2_0_extension: ?*USB20ExtensionDescriptor,
) callconv(.C) void;

/// Get a SuperSpeed USB Device Capability descriptor.
///
/// Returns
/// * 0 on success
/// * a LIBUSB_ERROR code on error
pub extern fn libusb_get_ss_usb_device_capability_descriptor(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// Device Capability descriptor with a bDevCapabilityType of
    /// libusb_capability_type::LIBUSB_BT_SS_USB_DEVICE_CAPABILITY
    /// LIBUSB_BT_SS_USB_DEVICE_CAPABILITY
    dev_cap: *BOSDeviceCapabilityDescriptor,
    /// output location for the SuperSpeed USB Device Capability descriptor.
    /// Only valid if 0 was returned. Must be freed with
    /// libusb_free_ss_usb_device_capability_descriptor() after use.
    ss_usb_device_cap: *?*SSUSBDeviceCapabilityDescriptor,
) callconv(.C) ErrorCode;

/// Free a SuperSpeed USB Device Capability descriptor obtained from
/// libusb_get_ss_usb_device_capability_descriptor().
///
/// It is safe to call this function with a NULL ss_usb_device_cap parameter,
/// in which case the function simply returns.
pub extern fn libusb_free_ss_usb_device_capability_descriptor(
    /// the SuperSpeed USB Device Capability descriptor to free
    ss_usb_device_cap: ?*SSUSBDeviceCapabilityDescriptor,
) callconv(.C) void;

/// Get a Container ID descriptor.
///
/// Returns
/// * 0 on success
/// * a LIBUSB_ERROR code on error
pub extern fn libusb_get_container_id_descriptor(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// Device Capability descriptor with a bDevCapabilityType of
    /// libusb_capability_type::LIBUSB_BT_CONTAINER_ID LIBUSB_BT_CONTAINER_ID
    dev_cap: *BOSDeviceCapabilityDescriptor,
    /// output location for the Container ID descriptor. Only valid if 0 was
    /// returned. Must be freed with libusb_free_container_id_descriptor() after
    /// use
    container_id: *?*ContainerIdDescriptor,
) callconv(.C) ErrorCode;

/// Free a Container ID descriptor obtained from
/// libusb_get_container_id_descriptor().
///
/// It is safe to call this function with a NULL container_id parameter, in
/// which case the function simply returns.
pub extern fn libusb_free_container_id_descriptor(
    /// the Container ID descriptor to free
    container_id: ?*ContainerIdDescriptor,
) callconv(.C) void;

/// Get a platform descriptor.
///
/// Since version 1.0.27, LIBUSB_API_VERSION >= 0x0100010A
///
/// Returns
/// * 0 on success
/// * a LIBUSB_ERROR code on error
pub extern fn libusb_get_platform_descriptor(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// Device Capability descriptor with a bDevCapabilityType of
    /// libusb_capability_type::LIBUSB_BT_PLATFORM_DESCRIPTOR
    /// LIBUSB_BT_PLATFORM_DESCRIPTOR
    dev_cap: *BOSDeviceCapabilityDescriptor,
    /// output location for the Platform descriptor. Only valid if 0 was
    /// returned. Must be freed with libusb_free_platform_descriptor() after
    /// use.
    platform_descriptor: *?*PlatformDescriptor,
) callconv(.C) ErrorCode;

/// Free a platform descriptor obtained from libusb_get_platform_descriptor().
///
/// It is safe to call this function with a NULL platform_descriptor parameter,
/// in which case the function simply returns.
pub extern fn libusb_free_platform_descriptor(
    /// the Platform descriptor to free
    platform_descriptor: *PlatformDescriptor,
) callconv(.C) void;

/// Get the number of the bus that a device is connected to.
pub extern fn libusb_get_bus_number(
    /// a device
    dev: *Device,
) callconv(.C) u8;

/// Get the number of the port that a device is connected to.
///
/// Unless the OS does something funky, or you are hot-plugging USB extension
/// cards, the port number returned by this call is usually guaranteed to be
/// uniquely tied to a physical port, meaning that different devices plugged on
/// the same physical port should return the same port number.
///
/// But outside of this, there is no guarantee that the port number returned by
/// this call will remain the same, or even match the order in which ports have
/// been numbered by the HUB/HCD manufacturer.
///
/// Returns the port number (0 if not available)
pub extern fn libusb_get_port_number(
    /// a device
    dev: *Device,
) callconv(.C) u8;

/// Get the list of all port numbers from root for the specified device.
///
/// Since version 1.0.16, LIBUSBX_API_VERSION >= 0x01000102
///
/// Returns
/// the number of elements filled
/// LIBUSB_ERROR_OVERFLOW if the array is too small
pub extern fn libusb_get_port_numbers(
    /// a device
    dev: *Device,
    /// the array that should contain the port numbers
    port_numbers: [*]u8,
    /// the maximum length of the array. As per the USB 3.0 specs, the current
    /// maximum limit for the depth is 7.
    port_numbers_len: c_int,
) callconv(.C) U32OrErrorCode;

/// Deprecated.
///
/// Please use libusb_get_port_numbers() instead
pub extern fn libusb_get_port_path(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// a device
    dev: *Device,
    /// the array that should contain the port numbers
    path: [*]u8,
    /// the maximum length of the array. As per the USB 3.0 specs, the current
    /// maximum limit for the depth is 7.
    path_length: u8,
) callconv(.C) c_int;

/// Get the the parent from the specified device.
///
/// Returns the device parent or NULL if not available You should issue a
/// libusb_get_device_list() before calling this function and make sure that
/// you only access the parent before issuing libusb_free_device_list(). The
/// reason is that libusb currently does not maintain a permanent list of
/// device instances, and therefore can only guarantee that parents are fully
/// instantiated within a libusb_get_device_list() - libusb_free_device_list()
/// block.
pub extern fn libusb_get_parent(
    /// a device
    dev: *Device,
) callconv(.C) ?*Device;

/// Get the address of the device on the bus it is connected to.
///
/// Returns the device address.
pub extern fn libusb_get_device_address(
    /// a device
    dev: *Device,
) callconv(.C) u8;

/// Get the negotiated connection speed for a device.
///
/// Returns a libusb_speed code, where LIBUSB_SPEED_UNKNOWN means that the OS
/// doesn't know or doesn't support returning the negotiated speed.
pub extern fn libusb_get_device_speed(dev: ?*Device) callconv(.C) Speed;

/// Convenience function to retrieve the wMaxPacketSize value for a particular
/// endpoint in the active device configuration.
///
/// This function was originally intended to be of assistance when setting up
/// isochronous transfers, but a design mistake resulted in this function
/// instead. It simply returns the wMaxPacketSize value without considering its
/// contents. If you're dealing with isochronous transfers, you probably want
/// libusb_get_max_iso_packet_size() instead.
pub extern fn libusb_get_max_packet_size(dev: ?*Device, endpoint: u8) callconv(.C) c_int;

/// Calculate the maximum packet size which a specific endpoint is capable is
/// sending or receiving in the duration of 1 microframe.
///
/// Only the active configuration is examined. The calculation is based on the
/// wMaxPacketSize field in the endpoint descriptor as described in section
/// 9.6.6 in the USB 2.0 specifications.
///
/// If acting on an isochronous or interrupt endpoint, this function will
/// multiply the value found in bits 0:10 by the number of transactions per
/// microframe (determined by bits 11:12). Otherwise, this function just
/// returns the numeric value found in bits 0:10. For USB 3.0 device, it will
/// attempts to retrieve the Endpoint Companion Descriptor to return
/// wBytesPerInterval.
///
/// This function is useful for setting up isochronous transfers, for example
/// you might pass the return value from this function to
/// libusb_set_iso_packet_lengths() in order to set the length field of every
/// isochronous packet in a transfer.
///
/// This function only considers the first alternate setting of the interface.
/// If the endpoint has different maximum packet sizes for different alternate
/// settings, you probably want libusb_get_max_alt_packet_size() instead.
///
/// Since v1.0.3.
///
/// Returns
/// * the maximum packet size which can be sent/received on this endpoint
/// * LIBUSB_ERROR_NOT_FOUND if the endpoint does not exist
/// * LIBUSB_ERROR_OTHER on other failure
pub extern fn libusb_get_max_iso_packet_size(
    /// a device
    dev: *Device,
    /// address of the endpoint in question
    endpoint: u8,
) callconv(.C) U32OrErrorCode;

/// Calculate the maximum packet size which a specific endpoint is capable of
/// sending or receiving in the duration of 1 microframe.
///
/// Only the active configuration is examined. The calculation is based on the
/// wMaxPacketSize field in the endpoint descriptor as described in section
/// 9.6.6 in the USB 2.0 specifications.
///
/// If acting on an isochronous or interrupt endpoint, this function will
/// multiply the value found in bits 0:10 by the number of transactions per
/// microframe (determined by bits 11:12). Otherwise, this function just
/// returns the numeric value found in bits 0:10. For USB 3.0 device, it will
/// attempts to retrieve the Endpoint Companion Descriptor to return
/// wBytesPerInterval.
///
/// This function is useful for setting up isochronous transfers, for example
/// you might pass the return value from this function to
/// libusb_set_iso_packet_lengths() in order to set the length field of every
/// isochronous packet in a transfer.
///
/// Since version 1.0.27, LIBUSB_API_VERSION >= 0x0100010A
///
/// Returns
/// * the maximum packet size which can be sent/received on this endpoint
/// * LIBUSB_ERROR_NOT_FOUND if the endpoint does not exist
/// * LIBUSB_ERROR_OTHER on other failure
pub extern fn libusb_get_max_alt_packet_size(
    /// a device
    dev: *Device,
    /// the bInterfaceNumber of the interface the endpoint belongs to
    interface_number: c_int,
    /// the bAlternateSetting of the interface
    alternate_setting: c_int,
    /// address of the endpoint in question
    endpoint: u8,
) callconv(.C) ErrorCode;

/// Get an array of interface association descriptors (IAD) for a given
/// configuration.
///
/// This is a non-blocking function which does not involve any requests being
/// sent to the device.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the configuration does not exist
/// * another LIBUSB_ERROR code on error
pub extern fn libusb_get_interface_association_descriptors(
    /// a device
    dev: *Device,
    /// the index of the configuration you wish to retrieve the IADs for.
    config_index: u8,
    /// output location for the array of IADs. Only valid if 0 was returned.
    /// Must be freed with libusb_free_interface_association_descriptors()
    /// after use. It's possible that a given configuration contains no IADs.
    /// In this case the iad_array is still output, but will have 'length'
    /// field set to 0, and iad field set to NULL.
    iad_array: *?*InterfaceAssociationDescriptorArray,
) callconv(.C) ErrorCode;

/// Get an array of interface association descriptors (IAD) for the currently
/// active configuration.
///
/// This is a non-blocking function which does not involve any requests being
/// sent to the device
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the device is in unconfigured state
/// * another LIBUSB_ERROR code on error
pub extern fn libusb_get_active_interface_association_descriptors(
    /// a device
    dev: *Device,
    /// output location for the array of IADs. Only valid if 0 was returned.
    /// Must be freed with libusb_free_interface_association_descriptors()
    /// after use. It's possible that a given configuration contains no IADs.
    /// In this case the iad_array is still output, but will have 'length'
    /// field set to 0, and iad field set to NULL.
    iad_array: *?*InterfaceAssociationDescriptorArray,
) callconv(.C) c_int;

/// Free an array of interface association descriptors (IADs) obtained from
/// libusb_get_interface_association_descriptors() or
/// libusb_get_active_interface_association_descriptors().
///
/// It is safe to call this function with a NULL iad_array parameter, in which
/// case the function simply returns.
pub extern fn libusb_free_interface_association_descriptors(
    /// the IAD array to free
    iad_array: ?*InterfaceAssociationDescriptorArray,
) callconv(.C) void;

/// Wrap a platform-specific system device handle and obtain a libusb device
/// handle for the underlying device.
///
/// The handle allows you to use libusb to perform I/O on the device in
/// question.
///
/// Call libusb_init_context with the LIBUSB_OPTION_NO_DEVICE_DISCOVERY option
/// if you want to skip enumeration of USB devices. In particular, this might
/// be needed on Android if you don't have authority to access USB devices in
/// general. Setting this option with libusb_set_option is deprecated.
///
/// On Linux, the system device handle must be a valid file descriptor opened
/// on the device node.
///
/// The system device handle must remain open until libusb_close() is called.
/// The system device handle will not be closed by libusb_close().
///
/// Internally, this function creates a temporary device and makes it available
/// to you through libusb_get_device(). This device is destroyed during
/// libusb_close(). The device shall not be opened through libusb_open().
///
/// This is a non-blocking function; no requests are sent over the bus.
///
/// Since version 1.0.23, LIBUSB_API_VERSION >= 0x01000107
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NO_MEM on memory allocation failure
/// * LIBUSB_ERROR_ACCESS if the user has insufficient permissions
/// * LIBUSB_ERROR_NOT_SUPPORTED if the operation is not supported on this platform
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_wrap_sys_device(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// sys_dev	the platform-specific system device handle
    sys_dev: isize,
    /// dev_handle	output location for the returned device handle pointer. Only
    /// populated when the return code is 0.
    dev_handle: *?*DeviceHandle,
) callconv(.C) ErrorCode;

/// Open a device and obtain a device handle.
///
/// A handle allows you to perform I/O on the device in question.
///
/// Internally, this function adds a reference to the device and makes it
/// available to you through libusb_get_device(). This reference is removed
/// during libusb_close().
///
/// This is a non-blocking function; no requests are sent over the bus.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NO_MEM on memory allocation failure
/// * LIBUSB_ERROR_ACCESS if the user has insufficient permissions
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_open(
    /// the device to open
    dev: *Device,
    /// dev_handle	output location for the returned device handle pointer. Only
    /// populated when the return code is 0.
    dev_handle: *?*DeviceHandle,
) callconv(.C) ErrorCode;

/// Close a device handle.
///
/// Should be called on all open handles before your application exits.
///
/// Internally, this function destroys the reference that was added by
/// libusb_open() on the given device.
///
/// This is a non-blocking function; no requests are sent over the bus.
pub extern fn libusb_close(
    /// the device handle to close
    dev_handle: *DeviceHandle,
) callconv(.C) void;

/// Get the underlying device for a device handle.
///
/// This function does not modify the reference count of the returned device, so
/// do not feel compelled to unreference it when you are done.
pub extern fn libusb_get_device(
    /// a device handle
    dev_handle: *DeviceHandle,
) callconv(.C) *Device;

/// Set the active configuration for a device.
///
/// The operating system may or may not have already set an active configuration
/// on the device. It is up to your application to ensure the correct
/// configuration is selected before you attempt to claim interfaces and perform
/// other operations.
///
/// If you call this function on a device already configured with the selected
/// configuration, then this function will act as a lightweight device reset: it
/// will issue a SET_CONFIGURATION request using the current configuration,
/// causing most USB-related device state to be reset (altsetting reset to zero,
/// endpoint halts cleared, toggles reset).
///
/// Not all backends support setting the configuration from user space, which
/// will be indicated by the return code LIBUSB_ERROR_NOT_SUPPORTED. As this
/// suggests that the platform is handling the device configuration itself, this
/// error should generally be safe to ignore.
///
/// You cannot change/reset configuration if your application has claimed
/// interfaces. It is advised to set the desired configuration before claiming
/// interfaces.
///
/// Alternatively you can call libusb_release_interface() first. Note if you do
/// things this way you must ensure that auto_detach_kernel_driver for dev is 0,
/// otherwise the kernel driver will be re-attached when you release the
/// interface(s).
///
/// You cannot change/reset configuration if other applications or drivers have
/// claimed interfaces.
///
/// A configuration value of -1 will put the device in unconfigured state. The
/// USB specifications state that a configuration value of 0 does this, however
/// buggy devices exist which actually have a configuration 0.
///
/// You should always use this function rather than formulating your own
/// SET_CONFIGURATION control request. This is because the underlying operating
/// system needs to know when such changes happen.
///
/// This is a blocking function.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the requested configuration does not exist
/// * LIBUSB_ERROR_BUSY if interfaces are currently claimed
/// * LIBUSB_ERROR_NOT_SUPPORTED if setting or changing the configuration is not supported by the backend
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_set_configuration(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the bConfigurationValue of the configuration you wish to activate, or -1
    /// if you wish to put the device in an unconfigured state
    configuration: c_int,
) callconv(.C) ErrorCode;

/// Claim an interface on a given device handle.
///
/// You must claim the interface you wish to use before you can perform I/O on
/// any of its endpoints.
///
/// It is legal to attempt to claim an already-claimed interface, in which case
/// libusb just returns 0 without doing anything.
///
/// If auto_detach_kernel_driver is set to 1 for dev, the kernel driver will be
/// detached if necessary, on failure the detach error is returned.
///
/// Claiming of interfaces is a purely logical operation; it does not cause any
/// requests to be sent over the bus. Interface claiming is used to instruct the
/// underlying operating system that your application wishes to take ownership
/// of the interface.
///
/// This is a non-blocking function.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the requested interface does not exist
/// * LIBUSB_ERROR_BUSY if another program or driver has claimed the interface
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * a LIBUSB_ERROR code on other failure
pub extern fn libusb_claim_interface(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the bInterfaceNumber of the interface you wish to claim
    interface_number: c_int,
) callconv(.C) ErrorCode;

/// Release an interface previously claimed with libusb_claim_interface().
///
/// You should release all claimed interfaces before closing a device handle.
///
/// This is a blocking function. A SET_INTERFACE control request will be sent to
/// the device, resetting interface state to the first alternate setting.
///
/// If auto_detach_kernel_driver is set to 1 for dev, the kernel driver will be
/// re-attached after releasing the interface.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the interface was not claimed
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_release_interface(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the bInterfaceNumber of the previously-claimed interface
    interface_number: c_int,
) callconv(.C) ErrorCode;

/// Convenience function for finding a device with a particular
/// idVendor/idProduct combination.
///
/// This function is intended for those scenarios where you are using libusb to
/// knock up a quick test application - it allows you to avoid calling
/// libusb_get_device_list() and worrying about traversing/freeing the list.
///
/// This function has limitations and is hence not intended for use in real
/// applications: if multiple devices have the same IDs it will only give you
/// the first one, etc.
///
/// Returns a device handle for the first found device, or NULL on error or if
/// the device could not be found.
pub extern fn libusb_open_device_with_vid_pid(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// the idVendor value to search for
    vendor_id: u16,
    /// the idProduct value to search for
    product_id: u16,
) callconv(.C) ?*DeviceHandle;

/// Activate an alternate setting for an interface.
///
/// The interface must have been previously claimed with
/// libusb_claim_interface().
///
/// You should always use this function rather than formulating your own
/// SET_INTERFACE control request. This is because the underlying operating
/// system needs to know when such changes happen.
///
/// This is a blocking function.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the interface was not claimed, or the requested
/// alternate setting does not exist
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_set_interface_alt_setting(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the bInterfaceNumber of the previously-claimed interface
    interface_number: c_int,
    /// the bAlternateSetting of the alternate setting to activate
    alternate_setting: c_int,
) callconv(.C) ErrorCode;

/// Clear the halt/stall condition for an endpoint.
///
/// Endpoints with halt status are unable to receive or transmit data until the
/// halt condition is stalled.
///
/// You should cancel all pending transfers before attempting to clear the halt
/// condition.
///
/// This is a blocking function.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the endpoint does not exist
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_clear_halt(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the endpoint to clear halt status
    endpoint: u8,
) callconv(.C) ErrorCode;

/// Perform a USB port reset to reinitialize a device.
///
/// The system will attempt to restore the previous configuration and alternate
/// settings after the reset has completed.
///
/// If the reset fails, the descriptors change, or the previous state cannot be
/// restored, the device will appear to be disconnected and reconnected. This
/// means that the device handle is no longer valid (you should close it) and
/// rediscover the device. A return code of LIBUSB_ERROR_NOT_FOUND indicates
/// when this is the case.
///
/// This is a blocking function which usually incurs a noticeable delay.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if re-enumeration is required, or if the device has been disconnected
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_reset_device(
    /// a handle of the device to reset
    dev_handle: *DeviceHandle,
) callconv(.C) ErrorCode;

/// Allocate up to num_streams usb bulk streams on the specified endpoints.
///
/// This function takes an array of endpoints rather then a single endpoint
/// because some protocols require that endpoints are setup with similar stream
/// ids. All endpoints passed in must belong to the same interface.
///
/// Note this function may return less streams then requested. Also note that
/// the same number of streams are allocated for each endpoint in the endpoint
/// array.
///
/// Stream id 0 is reserved, and should not be used to communicate with devices.
/// If libusb_alloc_streams() returns with a value of N, you may use stream ids
/// 1 to N.
///
/// Since version 1.0.19, LIBUSB_API_VERSION >= 0x01000103
///
/// Returns number of streams allocated, or a LIBUSB_ERROR code on failure
pub extern fn libusb_alloc_streams(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// number of streams to try to allocate
    num_streams: u32,
    /// array of endpoints to allocate streams on
    endpoints: [*]u8,
    /// length of the endpoints array
    num_endpoints: c_int,
) callconv(.C) U32OrErrorCode;

/// Free usb bulk streams allocated with libusb_alloc_streams().
///
/// Note streams are automatically free-ed when releasing an interface.
///
/// Since version 1.0.19, LIBUSB_API_VERSION >= 0x01000103
///
/// Returns LIBUSB_SUCCESS, or a LIBUSB_ERROR code on failure
pub extern fn libusb_free_streams(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// array of endpoints to free streams on
    endpoints: [*]u8,
    /// length of the endpoints array
    num_endpoints: c_int,
) callconv(.C) ErrorCode;

/// Attempts to allocate a block of persistent DMA memory suitable for transfers
/// against the given device.
///
/// If successful, will return a block of memory that is suitable for use as
/// "buffer" in libusb_transfer against this device. Using this memory instead
/// of regular memory means that the host controller can use DMA directly into
/// the buffer to increase performance, and also that transfers can no longer
/// fail due to kernel memory fragmentation.
///
/// Note that this means you should not modify this memory (or even data on the
/// same cache lines) when a transfer is in progress, although it is legal to
/// have several transfers going on within the same memory block.
///
/// Will return NULL on failure. Many systems do not support such zero-copy and
/// will always return NULL. Memory allocated with this function must be freed
/// with libusb_dev_mem_free. Specifically, this means that the flag
/// LIBUSB_TRANSFER_FREE_BUFFER cannot be used to free memory allocated with
/// this function.
///
/// Since version 1.0.21, LIBUSB_API_VERSION >= 0x01000105
///
/// Returns a pointer to the newly allocated memory, or NULL on failure
pub extern fn libusb_dev_mem_alloc(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// size of desired data buffer
    length: usize,
) callconv(.C) ?[*]u8;

/// Free device memory allocated with libusb_dev_mem_alloc().
///
/// Returns LIBUSB_SUCCESS, or a LIBUSB_ERROR code on failure
pub extern fn libusb_dev_mem_free(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// pointer to the previously allocated memory
    buffer: [*]u8,
    /// size of previously allocated memory
    length: usize,
) callconv(.C) ErrorCode;

/// Determine if a kernel driver is active on an interface.
///
/// If a kernel driver is active, you cannot claim the interface, and libusb
/// will be unable to perform I/O.
///
/// This functionality is not available on Windows.
///
/// Returns
/// * 0 if no kernel driver is active
/// * 1 if a kernel driver is active
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * LIBUSB_ERROR_NOT_SUPPORTED on platforms where the functionality is not available
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_kernel_driver_active(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the interface to check
    interface_number: c_int,
) callconv(.C) ErrorCode;

/// Detach a kernel driver from an interface.
///
/// If successful, you will then be able to claim the interface and perform I/O.
///
/// This functionality is not available on Windows.
///
/// Note that libusb itself also talks to the device through a special kernel
/// driver, if this driver is already attached to the device, this call will not
/// detach it and return LIBUSB_ERROR_NOT_FOUND.
pub extern fn libusb_detach_kernel_driver(
    /// a device handle
    dev_handle: ?*DeviceHandle,
    /// the interface to detach the driver from
    interface_number: c_int,
) callconv(.C) ErrorCode;

/// Re-attach an interface's kernel driver, which was previously detached using
/// libusb_detach_kernel_driver().
///
/// This functionality is not available on Windows.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if no kernel driver was active
/// * LIBUSB_ERROR_INVALID_PARAM if the interface does not exist
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * LIBUSB_ERROR_NOT_SUPPORTED on platforms where the functionality is not available
/// * LIBUSB_ERROR_BUSY if the driver cannot be attached because the interface is claimed by a program or driver
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_attach_kernel_driver(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the interface to attach the driver to
    interface_number: c_int,
) callconv(.C) ErrorCode;

/// Enable/disable libusb's automatic kernel driver detachment.
///
/// When this is enabled libusb will automatically detach the kernel driver on
/// an interface when claiming the interface, and attach it when releasing the
/// interface.
///
/// Automatic kernel driver detachment is disabled on newly opened device
/// handles by default.
///
/// On platforms which do not have LIBUSB_CAP_SUPPORTS_DETACH_KERNEL_DRIVER this
/// function will return LIBUSB_ERROR_NOT_SUPPORTED, and libusb will continue as
/// if this function was never called.
///
/// Returns
/// * LIBUSB_SUCCESS on success
/// * LIBUSB_ERROR_NOT_SUPPORTED on platforms where the functionality is not available
pub extern fn libusb_set_auto_detach_kernel_driver(
    /// a device handle
    dev_handle: ?*DeviceHandle,
    /// whether to enable or disable auto kernel driver detachment
    enable: bool,
) callconv(.C) ErrorCode;

/// Allocate a libusb transfer with a specified number of isochronous packet
/// descriptors.
///
/// The returned transfer is pre-initialized for you. When the new transfer is
/// no longer needed, it should be freed with libusb_free_transfer().
///
/// Transfers intended for non-isochronous endpoints (e.g. control, bulk,
/// interrupt) should specify an iso_packets count of zero.
///
/// For transfers intended for isochronous endpoints, specify an appropriate
/// number of packet descriptors to be allocated as part of the transfer. The
/// returned transfer is not specially initialized for isochronous I/O; you are
/// still required to set the num_iso_packets and type fields accordingly.
///
/// It is safe to allocate a transfer with some isochronous packets and then use
/// it on a non-isochronous endpoint. If you do this, ensure that at time of
/// submission, num_iso_packets is 0 and that type is set appropriately.
///
/// Returns a newly allocated transfer, or NULL on error
pub extern fn libusb_alloc_transfer(
    /// number of isochronous packet descriptors to allocate. Must be non-negative.
    iso_packets: c_int,
) callconv(.C) ?*Transfer;

/// Submit a transfer.
///
/// This function will fire off the USB transfer and then return immediately.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * LIBUSB_ERROR_BUSY if the transfer has already been submitted.
/// * LIBUSB_ERROR_NOT_SUPPORTED if the transfer flags are not supported by the
/// operating system.
/// * LIBUSB_ERROR_INVALID_PARAM if the transfer size is larger than the
/// operating system and/or hardware can support (see Transfer length
/// limitations)
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_submit_transfer(
    /// the transfer to submit
    transfer: *Transfer,
) callconv(.C) ErrorCode;

/// Asynchronously cancel a previously submitted transfer.
///
/// This function returns immediately, but this does not indicate cancellation
/// is complete. Your callback function will be invoked at some later time with
/// a transfer status of LIBUSB_TRANSFER_CANCELLED.
///
/// This function behaves differently on Darwin-based systems (macOS and iOS):
/// * Calling this function for one transfer will cause all transfers on the
/// same endpoint to be cancelled. Your callback function will be invoked with a
/// transfer status of LIBUSB_TRANSFER_CANCELLED for each transfer that was
/// cancelled.
/// * When built for macOS versions prior to 10.5, this function sends a
/// ClearFeature(ENDPOINT_HALT) request for the transfer's endpoint. (Prior to
/// libusb 1.0.27, this request was sent on all Darwin systems.) If the device
/// does not handle this request correctly, the data toggle bits for the
/// endpoint can be left out of sync between host and device, which can have
/// unpredictable results when the next data is sent on the endpoint, including
/// data being silently lost. A call to libusb_clear_halt will not resolve this
/// situation, since that function uses the same request. Therefore, if your
/// program runs on macOS < 10.5 (or libusb < 1.0.27), and uses a device that
/// does not correctly implement ClearFeature(ENDPOINT_HALT) requests, it may
/// only be safe to cancel transfers when followed by a device reset using
/// libusb_reset_device.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_NOT_FOUND if the transfer is not in progress, already
/// complete, or already cancelled.
/// * a LIBUSB_ERROR code on failure
pub extern fn libusb_cancel_transfer(
    /// the transfer to cancel
    transfer: *Transfer,
) callconv(.C) ErrorCode;

/// Free a transfer structure.
///
/// This should be called for all transfers allocated with
/// libusb_alloc_transfer().
///
/// If the LIBUSB_TRANSFER_FREE_BUFFER flag is set and the transfer buffer is
/// non-NULL, this function will also free the transfer buffer using the
/// standard system memory allocator (e.g. free()).
///
/// It is legal to call this function with a NULL transfer. In this case, the
/// function will simply return safely.
///
/// It is not legal to free an active transfer (one which has been submitted and
/// has not yet completed).
pub extern fn libusb_free_transfer(
    /// the transfer to free
    transfer: ?*Transfer,
) callconv(.C) void;

/// Set a transfers bulk stream id.
///
/// Note users are advised to use libusb_fill_bulk_stream_transfer() instead of
/// calling this function directly.
///
/// Since version 1.0.19, LIBUSB_API_VERSION >= 0x01000103
pub extern fn libusb_transfer_set_stream_id(
    /// the transfer to set the stream id for
    transfer: *Transfer,
    /// the stream id to set
    stream_id: u32,
) callconv(.C) void;

/// Get a transfers bulk stream id.
///
/// Since version 1.0.19, LIBUSB_API_VERSION >= 0x01000103
///
/// Returns the stream id for the transfer
pub extern fn libusb_transfer_get_stream_id(
    /// the transfer to get the stream id for
    transfer: *Transfer,
) callconv(.C) u32;

/// Perform a USB control transfer.
///
/// The direction of the transfer is inferred from the bmRequestType field of
/// the setup packet.
///
/// The wValue, wIndex and wLength fields values should be given in host-endian
/// byte order.
///
/// Returns
/// * on success, the number of bytes actually transferred
/// * LIBUSB_ERROR_TIMEOUT if the transfer timed out
/// * LIBUSB_ERROR_PIPE if the control request was not supported by the device
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * LIBUSB_ERROR_BUSY if called from event handling context
/// * LIBUSB_ERROR_INVALID_PARAM if the transfer size is larger than the
/// operating system and/or hardware can support (see Transfer length limitations)
/// * another LIBUSB_ERROR code on other failures
pub extern fn libusb_control_transfer(
    /// a handle for the device to communicate with
    dev_handle: *DeviceHandle,
    /// the request type field for the setup packet
    request_type: u8,
    /// the request field for the setup packet
    bRequest: u8,
    /// the value field for the setup packet
    wValue: u16,
    /// the index field for the setup packet
    wIndex: u16,
    /// a suitably-sized data buffer for either input or output (depending on
    /// direction bits within bmRequestType)
    data: [*]u8,
    /// the length field for the setup packet. The data buffer should be at
    /// least this size.
    wLength: u16,
    /// timeout (in milliseconds) that this function should wait before giving
    /// up due to no response being received. For an unlimited timeout, use
    /// value 0.
    timeout: c_uint,
) callconv(.C) ErrorCode;

/// Perform a USB bulk transfer.
///
/// The direction of the transfer is inferred from the direction bits of the
/// endpoint address.
///
/// For bulk reads, the length field indicates the maximum length of data you
/// are expecting to receive. If less data arrives than expected, this function
/// will return that data, so be sure to check the transferred output parameter.
///
/// You should also check the transferred parameter for bulk writes. Not all of
/// the data may have been written.
///
/// Also check transferred when dealing with a timeout error code. libusb may
/// have to split your transfer into a number of chunks to satisfy underlying
/// O/S requirements, meaning that the timeout may expire after the first few
/// chunks have completed. libusb is careful not to lose any data that may have
/// been transferred; do not assume that timeout conditions indicate a complete
/// lack of I/O. See Timeouts for more details.
///
/// Returns
/// * 0 on success (and populates transferred)
/// * LIBUSB_ERROR_TIMEOUT if the transfer timed out (and populates transferred)
/// * LIBUSB_ERROR_PIPE if the endpoint halted
/// * LIBUSB_ERROR_OVERFLOW if the device offered more data, see Packets and
/// overflows
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * LIBUSB_ERROR_BUSY if called from event handling context
/// * LIBUSB_ERROR_INVALID_PARAM if the transfer size is larger than the
/// operating system and/or hardware can support (see Transfer length
/// limitations)
/// * another LIBUSB_ERROR code on other failures
pub extern fn libusb_bulk_transfer(
    /// a handle for the device to communicate with
    dev_handle: *DeviceHandle,
    /// the address of a valid endpoint to communicate with
    endpoint: u8,
    /// a suitably-sized data buffer for either input or output (depending
    /// on endpoint)
    data: [*]u8,
    /// for bulk writes, the number of bytes from data to be sent. for bulk
    /// reads, the maximum number of bytes to receive into the data buffer.
    length: c_int,
    /// output location for the number of bytes actually transferred. Since
    /// version 1.0.21 (LIBUSB_API_VERSION >= 0x01000105), it is legal to pass a
    /// NULL pointer if you do not wish to receive this information.
    actual_length: ?*c_int,
    /// timeout (in milliseconds) that this function should wait before giving
    /// up due to no response being received. For an unlimited timeout, use
    /// value 0.
    timeout: c_uint,
) callconv(.C) ErrorCode;

/// Perform a USB interrupt transfer.
///
/// The direction of the transfer is inferred from the direction bits of the
/// endpoint address.
///
/// For interrupt reads, the length field indicates the maximum length of data
/// you are expecting to receive. If less data arrives than expected, this
/// function will return that data, so be sure to check the transferred output
/// parameter.
///
/// You should also check the transferred parameter for interrupt writes. Not
/// all of the data may have been written.
///
/// Also check transferred when dealing with a timeout error code. libusb may
/// have to split your transfer into a number of chunks to satisfy underlying
/// O/S requirements, meaning that the timeout may expire after the first few
/// chunks have completed. libusb is careful not to lose any data that may have
/// been transferred; do not assume that timeout conditions indicate a complete
/// lack of I/O. See Timeouts for more details.
///
/// The default endpoint bInterval value is used as the polling interval.
///
/// Returns
/// * 0 on success (and populates transferred)
/// * LIBUSB_ERROR_TIMEOUT if the transfer timed out
/// * LIBUSB_ERROR_PIPE if the endpoint halted
/// * LIBUSB_ERROR_OVERFLOW if the device offered more data, see Packets and overflows
/// * LIBUSB_ERROR_NO_DEVICE if the device has been disconnected
/// * LIBUSB_ERROR_BUSY if called from event handling context
/// * LIBUSB_ERROR_INVALID_PARAM if the transfer size is larger than the operating system and/or hardware can support (see Transfer length limitations)
/// * another LIBUSB_ERROR code on other error
pub extern fn libusb_interrupt_transfer(
    /// a handle for the device to communicate with
    dev_handle: *DeviceHandle,
    /// the address of a valid endpoint to communicate with
    endpoint: u8,
    /// a suitably-sized data buffer for either input or output (depending on endpoint)
    data: [*]u8,
    /// for bulk writes, the number of bytes from data to be sent. for bulk reads, the maximum number of bytes to receive into the data buffer.
    length: c_int,
    /// output location for the number of bytes actually transferred. Since version 1.0.21 (LIBUSB_API_VERSION >= 0x01000105), it is legal to pass a NULL pointer if you do not wish to receive this information.
    actual_length: ?*c_int,
    /// timeout (in milliseconds) that this function should wait before giving up due to no response being received. For an unlimited timeout, use value 0.
    timeout: c_uint,
) callconv(.C) ErrorCode;

/// Retrieve a string descriptor in C style ASCII.
///
/// Wrapper around libusb_get_string_descriptor(). Uses the first language
/// supported by the device.
///
/// Returns number of bytes returned in data, or LIBUSB_ERROR code on failure
pub extern fn libusb_get_string_descriptor_ascii(
    /// a device handle
    dev_handle: *DeviceHandle,
    /// the index of the descriptor to retrieve
    desc_index: u8,
    /// output buffer for ASCII string descriptor
    data: [*]u8,
    /// size of data buffer
    length: c_int,
) callconv(.C) U32OrErrorCode;

/// Attempt to acquire the event handling lock.
///
/// This lock is used to ensure that only one thread is monitoring libusb event sources at any one time.
///
/// You only need to use this lock if you are developing an application which calls poll() or select() on libusb's file descriptors directly. If you stick to libusb's event handling loop functions (e.g. libusb_handle_events()) then you do not need to be concerned with this locking.
///
/// While holding this lock, you are trusted to actually be handling events. If you are no longer handling events, you must call libusb_unlock_events() as soon as possible.
///
/// Returns
/// * 0 if the lock was obtained successfully
/// * 1 if the lock was not obtained (i.e. another thread holds the lock)
pub extern fn libusb_try_lock_events(
    /// the context to operate on, or NULL for the default context [Multi-threaded applications and asynchronous I/O](https://libusb.sourceforge.io/api-1.0/libusb_mtasync.html)
    ctx: ?*Context,
) callconv(.C) c_int;

/// Acquire the event handling lock, blocking until successful acquisition if it is contended.
///
/// This lock is used to ensure that only one thread is monitoring libusb event sources at any one time.
///
/// You only need to use this lock if you are developing an application which calls poll() or select() on libusb's file descriptors directly. If you stick to libusb's event handling loop functions (e.g. libusb_handle_events()) then you do not need to be concerned with this locking.
///
/// While holding this lock, you are trusted to actually be handling events. If you are no longer handling events, you must call libusb_unlock_events() as soon as possible.
pub extern fn libusb_lock_events(
    /// the context to operate on, or NULL for the default context [Multi-threaded applications and asynchronous I/O](https://libusb.sourceforge.io/api-1.0/libusb_mtasync.html)
    ctx: ?*Context,
) callconv(.C) void;

/// Release the lock previously acquired with libusb_try_lock_events() or libusb_lock_events().
///
/// Releasing this lock will wake up any threads blocked on libusb_wait_for_event().
pub extern fn libusb_unlock_events(
    /// the context to operate on, or NULL for the default context [Multi-threaded applications and asynchronous I/O](https://libusb.sourceforge.io/api-1.0/libusb_mtasync.html)
    ctx: ?*Context,
) callconv(.C) void;

/// Determine if it is still OK for this thread to be doing event handling.
///
/// Sometimes, libusb needs to temporarily pause all event handlers, and this is the function you should use before polling file descriptors to see if this is the case.
///
/// If this function instructs your thread to give up the events lock, you should just continue the usual logic that is documented in Multi-threaded applications and asynchronous I/O. On the next iteration, your thread will fail to obtain the events lock, and will hence become an event waiter.
///
/// This function should be called while the events lock is held: you don't need to worry about the results of this function if your thread is not the current event handler.
///
/// Returns
/// * 1 if event handling can start or continue
/// * 0 if this thread must give up the events lock
pub extern fn libusb_event_handling_ok(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) c_int;

/// Determine if an active thread is handling events (i.e. if anyone is holding
/// the event handling lock).
///
/// Returns
/// * 1 if a thread is handling events
/// * 0 if there are no threads currently handling events Multi-threaded applications and asynchronous I/O
pub extern fn libusb_event_handler_active(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) c_int;

/// Interrupt any active thread that is handling events.
///
/// This is mainly useful for interrupting a dedicated event handling thread when an application wishes to call libusb_exit().
///
/// Since version 1.0.21, LIBUSB_API_VERSION >= 0x01000105
pub extern fn libusb_interrupt_event_handler(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) void;

/// Acquire the event waiters lock.
///
/// This lock is designed to be obtained under the situation where you want to be aware when events are completed, but some other thread is event handling so calling libusb_handle_events() is not allowed.
///
/// You then obtain this lock, re-check that another thread is still handling events, then call libusb_wait_for_event().
///
/// You only need to use this lock if you are developing an application which calls poll() or select() on libusb's file descriptors directly, and may potentially be handling events from 2 threads simultaneously. If you stick to libusb's event handling loop functions (e.g. libusb_handle_events()) then you do not need to be concerned with this locking.
pub extern fn libusb_lock_event_waiters(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) void;

/// Release the event waiters lock.
pub extern fn libusb_unlock_event_waiters(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) void;

/// Wait for another thread to signal completion of an event.
///
/// Must be called with the event waiters lock held, see libusb_lock_event_waiters().
///
/// This function will block until any of the following conditions are met:
///
/// The timeout expires
/// 1. A transfer completes
/// 2. A thread releases the event handling lock through libusb_unlock_events()
/// 3. Condition 1 is obvious. Condition 2 unblocks your thread after the callback for the transfer has completed. Condition 3 is important because it means that the thread that was previously handling events is no longer doing so, so if any events are to complete, another thread needs to step up and start event handling.
///
/// This function releases the event waiters lock before putting your thread to sleep, and reacquires the lock as it is being woken up.
///
/// Returns
/// * 0 after a transfer completes or another thread stops event handling
/// * 1 if the timeout expired
/// * LIBUSB_ERROR_INVALID_PARAM if timeval is invalid
pub extern fn libusb_wait_for_event(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// maximum timeout for this blocking function. A NULL value indicates unlimited timeout.
    tv: ?*std.c.timeval,
) callconv(.C) U32OrErrorCode;

/// Handle any pending events.
///
/// Like libusb_handle_events_timeout_completed(), but without the completed parameter, calling this function is equivalent to calling libusb_handle_events_timeout_completed() with a NULL completed parameter.
///
/// This function is kept primarily for backwards compatibility. All new code should call libusb_handle_events_completed() or libusb_handle_events_timeout_completed() to avoid race conditions.
///
/// Returns 0 on success, or a LIBUSB_ERROR code on failure
pub extern fn libusb_handle_events_timeout(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// the maximum time to block waiting for events, or an all zero timeval struct for non-blocking mode
    tv: *std.c.timeval,
) callconv(.C) ErrorCode;

/// Handle any pending events.
///
/// libusb determines "pending events" by checking if any timeouts have expired and by checking the set of file descriptors for activity.
///
/// If a zero timeval is passed, this function will handle any already-pending events and then immediately return in non-blocking style.
///
/// If a non-zero timeval is passed and no events are currently pending, this function will block waiting for events to handle up until the specified timeout. If an event arrives or a signal is raised, this function will return early.
///
/// If the parameter completed is not NULL then after obtaining the event handling lock this function will return immediately if the integer pointed to is not 0. This allows for race free waiting for the completion of a specific transfer.
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_INVALID_PARAM if timeval is invalid
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_handle_events_timeout_completed(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// the maximum time to block waiting for events, or an all zero timeval struct for non-blocking mode
    tv: *std.c.timeval,
    /// pointer to completion integer to check, or NULL
    completed: ?*c_int,
) callconv(.C) ErrorCode;

/// Handle any pending events in blocking mode.
///
/// There is currently a timeout hard-coded at 60 seconds but we plan to make it unlimited in future. For finer control over whether this function is blocking or non-blocking, or for control over the timeout, use libusb_handle_events_timeout_completed() instead.
///
/// This function is kept primarily for backwards compatibility. All new code should call libusb_handle_events_completed() or libusb_handle_events_timeout_completed() to avoid race conditions.
///
/// Returns 0 on success, or a LIBUSB_ERROR code on failure
pub extern fn libusb_handle_events(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) ErrorCode;

/// Handle any pending events in blocking mode.
///
/// Like libusb_handle_events(), with the addition of a completed parameter to allow for race free waiting for the completion of a specific transfer.
///
/// See libusb_handle_events_timeout_completed() for details on the completed parameter.
///
/// Returns 0 on success, or a LIBUSB_ERROR code on failure
pub extern fn libusb_handle_events_completed(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// pointer to completion integer to check, or NULL
    completed: ?*c_int,
) callconv(.C) ErrorCode;

/// Handle any pending events by polling file descriptors, without checking if any other threads are already doing so.
///
/// Must be called with the event lock held, see libusb_lock_events().
///
/// This function is designed to be called under the situation where you have taken the event lock and are calling poll()/select() directly on libusb's file descriptors (as opposed to using libusb_handle_events() or similar). You detect events on libusb's descriptors, so you then call this function with a zero timeout value (while still holding the event lock).
///
/// Returns
/// * 0 on success
/// * LIBUSB_ERROR_INVALID_PARAM if timeval is invalid
/// * another LIBUSB_ERROR code on other failure
pub extern fn libusb_handle_events_locked(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// the maximum time to block waiting for events, or zero for non-blocking mode
    tv: *std.c.timeval,
) callconv(.C) ErrorCode;

/// Determines whether your application must apply special timing considerations when monitoring libusb's file descriptors.
///
/// This function is only useful for applications which retrieve and poll libusb's file descriptors in their own main loop (The more advanced option).
///
/// Ordinarily, libusb's event handler needs to be called into at specific moments in time (in addition to times when there is activity on the file descriptor set). The usual approach is to use libusb_get_next_timeout() to learn about when the next timeout occurs, and to adjust your poll()/select() timeout accordingly so that you can make a call into the library at that time.
///
/// Some platforms supported by libusb do not come with this baggage - any events relevant to timing will be represented by activity on the file descriptor set, and libusb_get_next_timeout() will always return 0. This function allows you to detect whether you are running on such a platform.
///
/// Since v1.0.5.
///
/// Returns 0 if you must call into libusb at times determined by libusb_get_next_timeout(), or 1 if all timeout events are handled internally or through regular activity on the file descriptors.
pub extern fn libusb_pollfds_handle_timeouts(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) c_int;

/// Determine the next internal timeout that libusb needs to handle.
///
/// You only need to use this function if you are calling poll() or select() or similar on libusb's file descriptors yourself - you do not need to use it if you are calling libusb_handle_events() or a variant directly.
///
/// You should call this function in your main loop in order to determine how long to wait for select() or poll() to return results. libusb needs to be called into at this timeout, so you should use it as an upper bound on your select() or poll() call.
///
/// When the timeout has expired, call into libusb_handle_events_timeout() (perhaps in non-blocking mode) so that libusb can handle the timeout.
///
/// This function may return 1 (success) and an all-zero timeval. If this is the case, it indicates that libusb has a timeout that has already expired so you should call libusb_handle_events_timeout() or similar immediately. A return code of 0 indicates that there are no pending timeouts.
///
/// On some platforms, this function will always returns 0 (no pending timeouts). See [Notes on time-based events](https://libusb.sourceforge.io/api-1.0/group__libusb__poll.html#polltime).
///
/// Returns 0 if there are no pending timeouts, 1 if a timeout was returned, or LIBUSB_ERROR_OTHER on failure
pub extern fn libusb_get_next_timeout(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// output location for a relative time against the current clock in which libusb must be called into in order to process timeout events
    tv: *std.c.timeval,
) callconv(.C) U32OrErrorCode;

/// Retrieve a list of file descriptors that should be polled by your main loop as libusb event sources.
///
/// The returned list is NULL-terminated and should be freed with libusb_free_pollfds() when done. The actual list contents must not be touched.
///
/// As file descriptors are a Unix-specific concept, this function is not available on Windows and will always return NULL.
///
/// Returns
/// * a NULL-terminated list of libusb_pollfd structures
/// * NULL on error
/// * NULL on platforms where the functionality is not available
pub extern fn libusb_get_pollfds(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
) callconv(.C) [*c]*const Pollfd;

/// Free a list of libusb_pollfd structures.
///
/// This should be called for all pollfd lists allocated with libusb_get_pollfds().
///
/// Since version 1.0.20, LIBUSB_API_VERSION >= 0x01000104
///
/// It is legal to call this function with a NULL pollfd list. In this case, the function will simply do nothing.
pub extern fn libusb_free_pollfds(
    /// the list of libusb_pollfd structures to free
    pollfds: ?[*c]*const Pollfd,
) callconv(.C) void;

/// Register notification functions for file descriptor additions/removals.
///
/// These functions will be invoked for every new or removed file descriptor that libusb uses as an event source.
///
/// To remove notifiers, pass NULL values for the function pointers.
///
/// Note that file descriptors may have been added even before you register these notifiers (e.g. at libusb_init_context() time).
///
/// Additionally, note that the removal notifier may be called during libusb_exit() (e.g. when it is closing file descriptors that were opened and added to the poll set at libusb_init_context() time). If you don't want this, remove the notifiers immediately before calling libusb_exit().
pub extern fn libusb_set_pollfd_notifiers(
    /// the context to operate on, or NULL for the default context
    ctx: ?*Context,
    /// pointer to function for addition notifications
    added_cb: ?*const fn (c_int, c_short, ?*anyopaque) callconv(.C) void,
    /// pointer to function for removal notifications
    removed_cb: ?*const fn (c_int, ?*anyopaque) callconv(.C) void,
    /// User data to be passed back to callbacks (useful for passing context information)
    user_data: ?*anyopaque,
) callconv(.C) void;

/// Register a hotplug callback function
///
/// Register a callback with the libusb_context. The callback will fire
/// when a matching event occurs on a matching device. The callback is
/// armed until either it is deregistered with libusb_hotplug_deregister_callback()
/// or the supplied callback returns 1 to indicate it is finished processing events.
///
/// If the LIBUSB_HOTPLUG_ENUMERATE is passed the callback will be
/// called with a LIBUSB_HOTPLUG_EVENT_DEVICE_ARRIVED for all devices
/// already plugged into the machine. Note that libusb modifies its internal
/// device list from a separate thread, while calling hotplug callbacks from
/// libusb_handle_events(), so it is possible for a device to already be present
/// on, or removed from, its internal device list, while the hotplug callbacks
/// still need to be dispatched. This means that when using \ref
/// LIBUSB_HOTPLUG_ENUMERATE, your callback may be called twice for the arrival
/// of the same device, once from libusb_hotplug_register_callback() and once
/// from libusb_handle_events(); and/or your callback may be called for the
/// removal of a device for which an arrived call was never made.
///
/// Since version 1.0.16, LIBUSB_API_VERSION >= 0x01000102
///
/// Returns LIBUSB_SUCCESS on success LIBUSB_ERROR code on failure
pub extern fn libusb_hotplug_register_callback(
    /// context to register this callback with
    ctx: ?*Context,
    /// bitwise or of hotplug events that will trigger this callback. See libusb_hotplug_event
    events: c_int,
    /// bitwise or of hotplug flags that affect registration. See libusb_hotplug_flag
    flags: c_int,
    /// the vendor id to match or LIBUSB_HOTPLUG_MATCH_ANY
    vendor_id: c_int,
    /// the product id to match or LIBUSB_HOTPLUG_MATCH_ANY
    product_id: c_int,
    /// the device class to match or LIBUSB_HOTPLUG_MATCH_ANY
    dev_class: c_int,
    /// the function to be invoked on a matching event/device
    cb_fn: *const fn (*Context, *Device, HotplugEvent, ?*anyopaque) callconv(.C) c_int,
    /// user data to pass to the callback function
    user_data: ?*anyopaque,
    /// pointer to store the handle of the allocated callback (can be NULL)
    callback_handle: *HotplugCallbackHandle,
) callconv(.C) ErrorCode;

/// Deregisters a hotplug callback.
///
/// Deregister a callback from a libusb_context. This function is safe to call from within
/// a hotplug callback.
///
/// Since version 1.0.16, LIBUSB_API_VERSION >= 0x01000102
pub extern fn libusb_hotplug_deregister_callback(
    /// context this callback is registered with
    ctx: ?*Context,
    /// the handle of the callback to deregister
    callback_handle: HotplugCallbackHandle,
) callconv(.C) void;

/// Gets the user_data associated with a hotplug callback.
///
/// Since version v1.0.24 LIBUSB_API_VERSION >= 0x01000108
pub extern fn libusb_hotplug_get_user_data(
    /// context this callback is registered with
    ctx: ?*Context,
    /// the handle of the callback to get the user_data of
    callback_handle: HotplugCallbackHandle,
) callconv(.C) ?*anyopaque;

/// Set an option in the library.
///
/// Use this function to configure a specific option within the library.
///
/// Some options require one or more arguments to be provided. Consult each option's documentation for specific requirements.
///
/// If the context ctx is NULL, the option will be added to a list of default options that will be applied to all subsequently created contexts.
///
/// Since version 1.0.22, LIBUSB_API_VERSION >= 0x01000106
///
/// Returns:
/// * LIBUSB_SUCCESS on success
/// * LIBUSB_ERROR_INVALID_PARAM if the option or arguments are invalid
/// * LIBUSB_ERROR_NOT_SUPPORTED if the option is valid but not supported on this platform
/// * LIBUSB_ERROR_NOT_FOUND if LIBUSB_OPTION_USE_USBDK is valid on this platform but UsbDk is not available
pub extern fn libusb_set_option(
    /// context on which to operate
    ctx: ?*Context,
    /// which option to set
    option: Option,
    /// any required arguments for the specified option
    ...,
) callconv(.C) c_int;

test "init context basic" {
    var ctx: ?*Context = null;
    try libusb_init_context(&ctx, null, 0).result();
    try testing.expect(ctx != null);
    defer libusb_exit(ctx);
}

test "init context log level" {
    var ctx: ?*Context = null;
    const options = [_]InitOption{
        .{
            .option = .log_level,
            .value = .{
                .log_level = .err,
            },
        },
    };
    try libusb_init_context(&ctx, &options, options.len).result();
    try testing.expect(ctx != null);
    defer libusb_exit(ctx);
}

test "init context log callback" {
    var ctx: ?*Context = null;
    const options = [_]InitOption{
        .{
            .option = .log_cb,
            .value = .{
                .log_cb = (struct {
                    fn test_log_cb(_: *Context, _: LogLevel, _: [*c]const u8) callconv(.C) void {}
                }).test_log_cb,
            },
        },
    };

    try libusb_init_context(&ctx, &options, options.len).result();
    try testing.expect(ctx != null);
    defer libusb_exit(ctx);
}
