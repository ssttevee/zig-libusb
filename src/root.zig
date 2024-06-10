const std = @import("std");
const testing = std.testing;
const builtin = @import("builtin");

pub const c = @import("./c.zig");

test {
    _ = c;
}

/// Device and/or Interface Class codes
pub const ClassCode = enum(u8) {
    /// In the context of a Device_descriptor "device descriptor",
    /// this bDeviceClass value indicates that each interface specifies its
    /// own class information and all interfaces operate independently.
    per_interface = 0x00,

    /// Audio class
    audio = 0x01,

    /// Communications class
    comm = 0x02,

    /// Human Interface Device class
    hid = 0x03,

    /// Physical
    physical = 0x05,

    /// Image class
    image = 0x06,

    /// Printer class
    printer = 0x07,

    /// Mass storage class
    mass_storage = 0x08,

    /// Hub class
    hub = 0x09,

    /// Data class
    data = 0x0a,

    /// Smart Card
    smart_card = 0x0b,

    /// Content Security
    content_security = 0x0d,

    /// Video
    video = 0x0e,

    /// Personal Healthcare
    personal_healthcare = 0x0f,

    /// Diagnostic Device
    diagnostic_device = 0xdc,

    /// Wireless class
    wireless = 0xe0,

    /// Miscellaneous class
    miscellaneous = 0xef,

    /// Application class
    application = 0xfe,

    /// Class is vendor-specific
    vendor_specific = 0xff,
};

/// Descriptor types as defined by the USB specification.
pub const DescriptorType = enum(u8) {
    /// Device descriptor. See Device_descriptor.
    device = 0x01,

    /// Configuration descriptor. See libusb_config_descriptor.
    config = 0x02,

    /// String descriptor
    string = 0x03,

    /// Interface descriptor. See libusb_interface_descriptor.
    interface = 0x04,

    /// Endpoint descriptor. See libusb_endpoint_descriptor.
    endpoint = 0x05,

    /// Interface Association Descriptor. See
    /// libusb_interface_association_descriptor
    interface_association = 0x0b,

    /// BOS descriptor
    bos = 0x0f,

    /// Device Capability descriptor
    device_capability = 0x10,

    /// HID descriptor
    hid = 0x21,

    /// HID report descriptor
    report = 0x22,

    /// Physical descriptor
    physical = 0x23,

    /// Hub descriptor
    hub = 0x29,

    /// SuperSpeed Hub descriptor
    superspeed_hub = 0x2a,

    /// SuperSpeed Endpoint Companion descriptor
    ss_endpoint_companion = 0x30,

    // descriptor sizes per descriptor type
    pub const device_size = 18;
    pub const config_size = 9;
    pub const interface_size = 9;
    pub const endpoint_size = 7;
    pub const endpoint_audio_size = 9; // audio extension
    pub const hub_nonvar_size = 7;
    pub const ss_endpoint_companion_size = 6;
    pub const bos_size = 5;
    pub const device_capability_size = 3;
};

pub const BOSType = enum(u8) {
    /// Wireless USB device capability
    wireless_usb_device_capability = 0x01,

    /// USB 2.0 extensions
    usb_2_0_extension = 0x02,

    /// SuperSpeed USB device capability
    ss_usb_device_capability = 0x03,

    /// Container ID type
    container_id = 0x04,

    /// Platform descriptor
    platform_descriptor = 0x05,

    pub const usb_2_0_extension_size = 7;
    pub const ss_usb_device_capability_size = 10;
    pub const container_id_size = 20;
    pub const platform_descriptor = 20;

    pub const max_size = DescriptorType.bos_size + usb_2_0_extension_size + ss_usb_device_capability_size + container_id_size;
};

/// Standard requests, as defined in table 9-5 of the USB 3.0 specifications
pub const StandardRequest = enum(u8) {
    /// Request status of the specific recipient
    get_status = 0x00,

    /// Clear or disable a specific feature
    clear_feature = 0x01,

    // 0x02 is reserved

    /// Set or enable a specific feature
    set_feature = 0x03,

    // 0x04 is reserved

    /// Set device address for all future accesses
    set_address = 0x05,

    /// Get the specified descriptor
    get_descriptor = 0x06,

    /// Used to update existing descriptors or add new descriptors
    set_descriptor = 0x07,

    /// Get the current device configuration value
    get_configuration = 0x08,

    /// Set device configuration
    set_configuration = 0x09,

    /// Return the selected alternate setting for the specified interface
    get_interface = 0x0a,

    /// Select an alternate interface for the specified interface
    set_interface = 0x0b,

    /// Set then report an endpoint's synchronization frame
    sync_frame = 0x0c,

    /// Sets both the U1 and U2 Exit Latency
    set_sel = 0x30,

    /// Delay from the time a host transmits a packet to the time it is
    /// received by the device.
    isoch_delay = 0x31,
};

pub const iso_sync_type_mask = 0x0c;

/// Supported speeds (wSpeedSupported) bitfield. Indicates what
/// speeds the device supports.
pub const SupportedSpeed = enum(c_int) {
    /// Low speed operation supported (1.5MBit/s).
    low = (1 << 0),

    /// Full speed operation supported (12MBit/s).
    full = (1 << 1),

    /// High speed operation supported (480MBit/s).
    high = (1 << 2),

    /// Superspeed operation supported (5000MBit/s).
    super = (1 << 3),
};

/// A structure representing the standard USB device descriptor. This
/// descriptor is documented in section 9.6.1 of the USB 3.0 specification.
/// All multiple-byte fields are represented in host-endian format.
pub const DeviceDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_DEVICE LIBUSB_DT_DEVICE in this
    /// context.
    bDescriptorType: DescriptorType,

    /// USB specification release number in binary-coded decimal. A value of
    /// 0x0200 indicates USB 2.0, 0x0110 indicates USB 1.1, etc.
    bcdUSB: u16,

    /// USB-IF class code for the device. See `ClassCode`.
    bDeviceClass: ClassCode,

    /// USB-IF subclass code for the device, qualified by the bDeviceClass
    /// value
    bDeviceSubClass: u8,

    /// USB-IF protocol code for the device, qualified by the bDeviceClass and
    /// bDeviceSubClass values
    bDeviceProtocol: u8,

    /// Maximum packet size for endpoint 0
    bMaxPacketSize0: u8,

    /// USB-IF vendor ID
    idVendor: u16,

    /// USB-IF product ID
    idProduct: u16,

    /// Device release number in binary-coded decimal
    bcdDevice: u16,

    /// Index of string descriptor describing manufacturer
    iManufacturer: u8,

    /// Index of string descriptor describing product
    iProduct: u8,

    /// Index of string descriptor containing device serial number
    iSerialNumber: u8,

    /// Number of possible configurations
    bNumConfigurations: u8,
};

/// The address of the endpoint described by this descriptor.
///
/// Bits 0:3 are the endpoint number. Bits 4:6 are reserved. Bit 7 indicates direction
///
/// See https://libusb.sourceforge.io/api-1.0/structlibusb__endpoint__descriptor.html#a111d087a09cbeded8e15eda9127e23d2
pub const Endpoint = packed struct {
    pub const Direction = enum(u1) {
        output,
        input,
    };

    address: u4,
    _: u3 = 0,
    direction: Direction,

    pub fn fromU8(endpoint: u8) Endpoint {
        return @bitCast(endpoint);
    }

    pub fn toU8(self: Endpoint) u8 {
        return @bitCast(self);
    }
};

test "endpoint" {
    const address_mask = 0x0F;
    const direction_mask = 0x80;

    try testing.expectEqual(@bitSizeOf(u8), @bitSizeOf(Endpoint));

    const output_endpoint_value = 0b00000101;
    std.debug.assert(output_endpoint_value & direction_mask == 0);
    const output_endpoint = Endpoint.fromU8(output_endpoint_value);
    try testing.expectEqual(output_endpoint_value, output_endpoint.toU8());
    try testing.expectEqual(output_endpoint_value & address_mask, output_endpoint.address);
    try testing.expectEqual(.output, output_endpoint.direction);

    const input_endpoint_value = 0b10001011;
    std.debug.assert(input_endpoint_value & direction_mask != 0);
    const input_endpoint = Endpoint.fromU8(input_endpoint_value);
    try testing.expectEqual(input_endpoint_value, input_endpoint.toU8());
    try testing.expectEqual(input_endpoint_value & address_mask, input_endpoint.address);
    try testing.expectEqual(.input, input_endpoint.direction);
}

pub const EndpointDescriptor = extern struct {
    /// Endpoint transfer type.
    pub const TransferType = enum(u2) {
        /// Control endpoint
        control = 0x0,

        /// Isochronous endpoint
        isochronous = 0x1,

        /// Bulk endpoint
        bulk = 0x2,

        /// Interrupt endpoint
        interrupt = 0x3,
    };

    /// Synchronization type for isochronous endpoints.
    pub const ISOSyncType = enum(u2) {
        /// No synchronization
        none = 0x0,

        /// Asynchronous
        @"async" = 0x1,

        /// Adaptive
        adaptive = 0x2,

        /// Synchronous
        sync = 0x3,
    };

    pub const iso_usage_type_mask = 0x30;

    /// Usage type for isochronous endpoints.
    pub const ISOUsageType = enum(u2) {
        /// Data endpoint
        data = 0x0,

        /// Feedback endpoint
        feedback = 0x1,

        /// Implicit feedback Data endpoint
        implicit = 0x2,
    };

    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_ENDPOINT LIBUSB_DT_ENDPOINT in
    /// this context.
    bDescriptorType: DescriptorType,

    /// The address of the endpoint described by this descriptor. Bits 0:3 are
    /// the endpoint number. Bits 4:6 are reserved. Bit 7 indicates direction.
    bEndpointAddress: Endpoint,

    /// Attributes which apply to the endpoint when it is configured using
    /// the bConfigurationValue. Bits 0:1 determine the transfer type and
    /// correspond to libusb_endpoint_transfer_type. Bits 2:3 are only used
    /// for isochronous endpoints and correspond to libusb_iso_sync_type.
    /// Bits 4:5 are also only used for isochronous endpoints and correspond to
    /// libusb_iso_usage_type. Bits 6:7 are reserved.
    bmAttributes: packed struct {
        transfer_type: TransferType,
        iso_sync_type: ISOSyncType,
        iso_usage_type: ISOUsageType,
        _: u2,
    },

    /// Maximum packet size this endpoint is capable of sending/receiving.
    wMaxPacketSize: u16,

    /// Interval for polling endpoint for data transfers.
    bInterval: u8,

    /// For audio devices only: the rate at which synchronization feedback
    /// is provided.
    bRefresh: u8,

    /// For audio devices only: the address if the synch endpoint
    bSynchAddress: u8,

    /// Extra descriptors. If libusb encounters unknown endpoint descriptors,
    /// it will store them here, should you wish to parse them.
    extra: [*]const u8,

    /// Length of the extra descriptors, in bytes. Must be non-negative.
    extra_length: u32,
};

/// A structure representing the standard USB interface association descriptor.
/// This descriptor is documented in section 9.6.4 of the USB 3.0 specification.
/// All multiple-byte fields are represented in host-endian format.
pub const InterfaceAssociationDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_INTERFACE_ASSOCIATION
    /// LIBUSB_DT_INTERFACE_ASSOCIATION in this context.
    bDescriptorType: DescriptorType,

    /// Interface number of the first interface that is associated
    /// with this function
    bFirstInterface: u8,

    /// Number of contiguous interfaces that are associated with
    /// this function
    bInterfaceCount: u8,

    /// USB-IF class code for this function.
    /// A value of zero is not allowed in this descriptor.
    /// If this field is 0xff, the function class is vendor-specific.
    /// All other values are reserved for assignment by the USB-IF.
    bFunctionClass: u8,

    /// USB-IF subclass code for this function.
    /// If this field is not set to 0xff, all values are reserved
    /// for assignment by the USB-IF
    bFunctionSubClass: u8,

    /// USB-IF protocol code for this function.
    /// These codes are qualified by the values of the bFunctionClass
    /// and bFunctionSubClass fields.
    bFunctionProtocol: u8,

    /// Index of string descriptor describing this function
    iFunction: u8,
};

/// Structure containing an array of 0 or more interface association
/// descriptors
pub const InterfaceAssociationDescriptorArray = extern struct {
    /// Array of interface association descriptors. The size of this array
    /// is determined by the length field.
    iad: ?[*]const InterfaceAssociationDescriptor,

    /// Number of interface association descriptors contained. Read-only.
    length: u32,

    pub fn toSlice(self: InterfaceAssociationDescriptorArray) []const InterfaceAssociationDescriptor {
        var slice: []const InterfaceAssociationDescriptor = undefined;
        slice.ptr = self.iad;
        slice.len = @intCast(self.length);
        return slice;
    }
};

/// A structure representing the standard USB interface descriptor. This
/// descriptor is documented in section 9.6.5 of the USB 3.0 specification.
/// All multiple-byte fields are represented in host-endian format.
pub const InterfaceDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_INTERFACE LIBUSB_DT_INTERFACE
    /// in this context.
    bDescriptorType: DescriptorType,

    /// Number of this interface
    bInterfaceNumber: u8,

    /// Value used to select this alternate setting for this interface
    bAlternateSetting: u8,

    /// Number of endpoints used by this interface (excluding the control
    /// endpoint).
    bNumEndpoints: u8,

    /// USB-IF class code for this interface. See libusb_class_code.
    bInterfaceClass: ClassCode,

    /// USB-IF subclass code for this interface, qualified by the
    /// bInterfaceClass value
    bInterfaceSubClass: u8,

    /// USB-IF protocol code for this interface, qualified by the
    /// bInterfaceClass and bInterfaceSubClass values
    bInterfaceProtocol: u8,

    /// Index of string descriptor describing this interface
    iInterface: u8,

    /// Array of endpoint descriptors. This length of this array is determined
    /// by the bNumEndpoints field.
    endpoint: [*]const EndpointDescriptor,

    /// Extra descriptors. If libusb encounters unknown interface descriptors,
    /// it will store them here, should you wish to parse them.
    extra: [*]const u8,

    /// Length of the extra descriptors, in bytes. Must be non-negative.
    extra_length: u32,

    pub fn endpointsSlice(self: *const InterfaceDescriptor) []const EndpointDescriptor {
        var slice: []const EndpointDescriptor = undefined;
        slice.ptr = self.endpoint;
        slice.len = @intCast(self.bNumEndpoints);
        return slice;
    }
};

/// A collection of alternate settings for a particular USB interface.
pub const Interface = extern struct {
    /// Array of interface descriptors. The length of this array is determined
    /// by the num_altsetting field.
    altsetting: [*]const InterfaceDescriptor,

    /// The number of alternate settings that belong to this interface.
    /// Must be non-negative.
    num_altsetting: u32,

    pub fn toSlice(self: Interface) []const InterfaceDescriptor {
        var slice: []const InterfaceDescriptor = undefined;
        slice.ptr = self.altsetting;
        slice.len = @intCast(self.num_altsetting);
        return slice;
    }
};

/// A structure representing the standard USB configuration descriptor. This
/// descriptor is documented in section 9.6.3 of the USB 3.0 specification.
/// All multiple-byte fields are represented in host-endian format.
pub const ConfigDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_CONFIG LIBUSB_DT_CONFIG
    /// in this context.
    bDescriptorType: DescriptorType,

    /// Total length of data returned for this configuration
    wTotalLength: u16,

    /// Number of interfaces supported by this configuration
    bNumInterfaces: u8,

    /// Identifier value for this configuration
    bConfigurationValue: u8,

    /// Index of string descriptor describing this configuration
    iConfiguration: u8,

    /// Configuration characteristics
    bmAttributes: u8,

    /// Maximum power consumption of the USB device from this bus in this
    /// configuration when the device is fully operation. Expressed in units
    /// of 2 mA when the device is operating in high-speed mode and in units
    /// of 8 mA when the device is operating in super-speed mode.
    MaxPower: u8,

    /// Array of interfaces supported by this configuration. The length of
    /// this array is determined by the bNumInterfaces field.
    interface: [*]const Interface,

    /// Extra descriptors. If libusb encounters unknown interface descriptors,
    /// it will store them here, should you wish to parse them.
    extra: [*]const u8,

    /// Length of the extra descriptors, in bytes. Must be non-negative.
    extra_length: u32,

    pub fn deinit(self: *ConfigDescriptor) void {
        c.libusb_free_config_descriptor(self);
    }

    pub fn interfacesSlice(self: *const ConfigDescriptor) []const Interface {
        var slice: []const Interface = undefined;
        slice.ptr = self.interface;
        slice.len = @intCast(self.bNumInterfaces);
        return slice;
    }
};

/// A structure representing the superspeed endpoint companion
/// descriptor. This descriptor is documented in section 9.6.7 of
/// the USB 3.0 specification. All multiple-byte fields are represented in
/// host-endian format.
pub const SSEndpointCompanionDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_SS_ENDPOINT_COMPANION in
    /// this context.
    bDescriptorType: DescriptorType,

    /// The maximum number of packets the endpoint can send or
    /// receive as part of a burst.
    bMaxBurst: u8,

    /// In bulk EP: bits 4:0 represents the maximum number of
    /// streams the EP supports. In isochronous EP: bits 1:0
    /// represents the Mult - a zero based value that determines
    /// the maximum number of packets within a service interval
    bmAttributes: u8,

    /// The total number of bytes this EP will transfer every
    /// service interval. Valid only for periodic EPs.
    wBytesPerInterval: u16,
};

/// A generic representation of a BOS Device Capability descriptor. It is
/// advised to check bDevCapabilityType and call the matching
/// libusb_get_*_descriptor function to get a structure fully matching the type.
pub const BOSDeviceCapabilityDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
    /// LIBUSB_DT_DEVICE_CAPABILITY in this context.
    bDescriptorType: DescriptorType,

    /// Device Capability type
    bDevCapabilityType: BOSType,

    /// Device Capability data (bLength - 3 bytes)
    pub fn dev_capability_data(self: *const BOSDeviceCapabilityDescriptor) [*c]const u8 {
        return (@as([*c]const u8, @ptrCast(self)) + @sizeOf(BOSDeviceCapabilityDescriptor))[0 .. self.bLength - @sizeOf(BOSDeviceCapabilityDescriptor)];
    }
};

/// A structure representing the Binary Device Object Store (BOS) descriptor.
/// This descriptor is documented in section 9.6.2 of the USB 3.0 specification.
/// All multiple-byte fields are represented in host-endian format.
pub const BOSDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8 align(8),

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_BOS LIBUSB_DT_BOS
    /// in this context.
    bDescriptorType: DescriptorType,

    /// Length of this descriptor and all of its sub descriptors
    wTotalLength: u16,

    /// The number of separate device capability descriptors in
    /// the BOS
    bNumDeviceCaps: u8,

    /// bNumDeviceCap Device Capability Descriptors
    pub fn dev_capability(self: *const BOSDescriptor) []const BOSDeviceCapabilityDescriptor {
        return (@as([*c]const BOSDeviceCapabilityDescriptor, @alignCast(@ptrCast(@as([*c]const u8, @ptrCast(self)) + @sizeOf(BOSDescriptor)))))[0..self.bNumDeviceCaps];
    }
};

/// A structure representing the USB 2.0 Extension descriptor
/// This descriptor is documented in section 9.6.2.1 of the USB 3.0 specification.
/// All multiple-byte fields are represented in host-endian format.
pub const USB20ExtensionDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
    /// LIBUSB_DT_DEVICE_CAPABILITY in this context.
    bDescriptorType: DescriptorType,

    /// Capability type. Will have value
    /// libusb_capability_type::LIBUSB_BT_USB_2_0_EXTENSION
    /// LIBUSB_BT_USB_2_0_EXTENSION in this context.
    bDevCapabilityType: BOSType,

    /// Bitmap encoding of supported device level features.
    /// A value of one in a bit location indicates a feature is
    /// supported; a value of zero indicates it is not supported.
    /// See libusb_usb_2_0_extension_attributes.
    bmAttributes: packed struct {
        _0: u1,

        /// Supports Link Power Management (LPM)
        lpm_support: bool,

        _1: u6,
    },
};

/// A structure representing the SuperSpeed USB Device Capability descriptor
/// This descriptor is documented in section 9.6.2.2 of the USB 3.0 specification.
/// All multiple-byte fields are represented in host-endian format.
pub const SSUSBDeviceCapabilityDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
    /// LIBUSB_DT_DEVICE_CAPABILITY in this context.
    bDescriptorType: DescriptorType,

    /// Capability type. Will have value
    /// libusb_capability_type::LIBUSB_BT_SS_USB_DEVICE_CAPABILITY
    /// LIBUSB_BT_SS_USB_DEVICE_CAPABILITY in this context.
    bDevCapabilityType: BOSType,

    /// Bitmap encoding of supported device level features.
    /// A value of one in a bit location indicates a feature is
    /// supported; a value of zero indicates it is not supported.
    /// See libusb_ss_usb_device_capability_attributes.
    bmAttributes: packed struct {
        _0: u1,

        /// Supports Latency Tolerance Messages (LTM)
        ltm_support: bool,

        _1: u6,
    },

    /// Bitmap encoding of the speed supported by this device when
    /// operating in SuperSpeed mode. See libusb_supported_speed.
    wSpeedSupported: u16,

    /// The lowest speed at which all the functionality supported
    /// by the device is available to the user. For example if the
    /// device supports all its functionality when connected at
    /// full speed and above then it sets this value to 1.
    bFunctionalitySupport: u8,

    /// U1 Device Exit Latency.
    bU1DevExitLat: u8,

    /// U2 Device Exit Latency.
    bU2DevExitLat: u16,
};

/// A structure representing the Container ID descriptor.
/// This descriptor is documented in section 9.6.2.3 of the USB 3.0 specification.
/// All multiple-byte fields, except UUIDs, are represented in host-endian format.
pub const ContainerIdDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
    /// LIBUSB_DT_DEVICE_CAPABILITY in this context.
    bDescriptorType: DescriptorType,

    /// Capability type. Will have value
    /// libusb_capability_type::LIBUSB_BT_CONTAINER_ID
    /// LIBUSB_BT_CONTAINER_ID in this context.
    bDevCapabilityType: BOSType,

    /// Reserved field
    bReserved: u8,

    /// 128 bit UUID
    ContainerID: [16]u8,
};

/// A structure representing a Platform descriptor.
/// This descriptor is documented in section 9.6.2.4 of the USB 3.2 specification.
pub const PlatformDescriptor = extern struct {
    /// Size of this descriptor (in bytes)
    bLength: u8,

    /// Descriptor type. Will have value
    /// libusb_descriptor_type::LIBUSB_DT_DEVICE_CAPABILITY
    /// LIBUSB_DT_DEVICE_CAPABILITY in this context.
    bDescriptorType: DescriptorType,

    /// Capability type. Will have value
    /// libusb_capability_type::LIBUSB_BT_PLATFORM_DESCRIPTOR
    /// LIBUSB_BT_CONTAINER_ID in this context.
    bDevCapabilityType: BOSType,

    /// Reserved field
    bReserved: u8,

    /// 128 bit UUID
    PlatformCapabilityUUID: [16]u8,

    /// Capability data (bLength - 20)
    pub fn CapabilityData(self: *const PlatformDescriptor) []const u8 {
        return (@as([*c]const u8, @ptrCast(self)) + @sizeOf(PlatformDescriptor))[0 .. self.bLength - @sizeOf(PlatformDescriptor)];
    }
};

/// Setup packet for control transfers.
pub const ControlSetup = packed struct {
    pub const RequestRecipient = enum(u2) {
        /// Device
        device,

        /// Interface
        interface,

        /// Endpoint
        endpoint,

        /// Other
        other,
    };

    pub const RequestType = enum(u5) {
        /// Standard
        standard,

        /// Class
        class,

        /// Vendor
        vendor,

        /// Reserved
        reserved,
    };

    pub const RequestDirection = enum(u1) {
        output,
        input,
    };

    /// Request type.
    bmRequestType: packed struct {
        recipient: RequestRecipient,
        type: RequestType,
        direction: RequestDirection,
    },

    /// Request. If the type bits of bmRequestType are equal to
    /// libusb_request_type::LIBUSB_REQUEST_TYPE_STANDARD
    /// "LIBUSB_REQUEST_TYPE_STANDARD" then this field refers to
    /// libusb_standard_request. For other cases, use of this field is
    /// application-specific.
    bRequest: extern union {
        standard: StandardRequest,
        other: u8,
    },

    /// Value. Varies according to request
    wValue: u16,

    /// Index. Varies according to request, typically used to pass an index
    /// or offset
    wIndex: u16,

    /// Number of bytes to transfer
    wLength: u16,
};

pub const Speed = enum(c_int) {
    /// The OS doesn't report or know the device speed.
    unknown = 0,

    /// The device is operating at low speed (1.5MBit/s).
    low = 1,

    /// The device is operating at full speed (12MBit/s).
    full = 2,

    /// The device is operating at high speed (480MBit/s).
    high = 3,

    /// The device is operating at super speed (5000MBit/s).
    super = 4,

    /// The device is operating at super speed plus (10000MBit/s).
    super_plus = 5,
};

/// Error codes. Most libusb functions return 0 on success or one of these
/// codes on failure.
/// You can call libusb_error_name() to retrieve a string representation of an
/// error code or libusb_strerror() to get an end-user suitable description of
/// an error code.
pub const ErrorCode = enum(c_int) {
    /// Success (no error)
    success = 0,

    /// Input/output error
    io = -1,

    /// Invalid parameter
    invalid_param = -2,

    /// Access denied (insufficient permissions)
    access = -3,

    /// No such device (it may have been disconnected)
    no_device = -4,

    /// Entity not found
    not_found = -5,

    /// Resource busy
    busy = -6,

    /// Operation timed out
    timeout = -7,

    /// Overflow
    overflow = -8,

    /// Pipe error
    pipe = -9,

    /// System call interrupted (perhaps due to signal)
    interrupt = -10,

    /// Insufficient memory
    no_mem = -11,

    /// Operation not supported or unimplemented on this platform
    not_supported = -12,

    /// Other error
    other = -99,

    _,

    fn toError(self: ErrorCode) anyerror {
        switch (self) {
            .success => std.debug.panic("not an error", .{}),
            .io => return error.IOError,
            .invalid_param => return error.InvalidParameter,
            .access => return error.AccessDenied,
            .no_device => return error.NoDevice,
            .not_found => return error.NotFound,
            .busy => return error.ResourceBusy,
            .timeout => return error.OperationTimedOut,
            .overflow => return error.Overflow,
            .pipe => return error.PipeError,
            .interrupt => return error.SystemCallInterrupted,
            .no_mem => return error.OutOfMemory,
            .not_supported => return error.OperationNotSupportedOrUnimplementedOnThisPlatform,
            .other => return error.Other,
            else => return error.Uknown,
        }
    }

    pub fn result(self: ErrorCode) !void {
        if (@intFromEnum(self) < 0) {
            return self.toError();
        }

        if (@intFromEnum(self) > 0) {
            std.debug.panic("got positive error: {d}", .{@intFromEnum(self)});
        }
    }
};

pub const Error = @typeInfo(@typeInfo(@TypeOf(ErrorCode.result)).Fn.return_type.?).ErrorUnion.error_set;

pub const UsizeOrErrorCode = enum(isize) {
    _,

    pub fn result(self: UsizeOrErrorCode) !usize {
        if (@intFromEnum(self) < 0) {
            return @as(ErrorCode, @enumFromInt(@intFromEnum(self))).toError();
        }

        return @intCast(@intFromEnum(self));
    }
};

pub const U32OrErrorCode = enum(c_int) {
    _,

    pub fn result(self: U32OrErrorCode) !usize {
        if (@intFromEnum(self) < 0) {
            return @as(ErrorCode, @enumFromInt(@intFromEnum(self))).toError();
        }

        return @intCast(@intFromEnum(self));
    }
};

pub const error_count = @typeInfo(ErrorCode).Enum.fields.len;

/// Transfer status codes
pub const TransferStatus = enum(c_int) {
    /// Transfer completed without error. Note that this does not indicate
    /// that the entire amount of requested data was transferred.
    completed,

    /// Transfer failed
    err,

    /// Transfer timed out
    timed_out,

    /// Transfer was cancelled
    cancelled,

    /// For bulk/interrupt endpoints: halt condition detected (endpoint
    /// stalled). For control endpoints: control request not supported.
    stall,

    /// Device was disconnected
    no_device,

    /// Device sent more data than requested
    overflow,
};

/// Isochronous packet descriptor
pub const ISOPacketDescriptor = extern struct {
    /// Length of data to request in this packet
    length: c_uint,

    /// Amount of data that was actually transferred
    actual_length: c_uint,

    /// Status code for this packet
    status: TransferStatus,
};

/// The generic USB transfer structure.
///
/// The user populates this structure and then submits it in order to request a transfer. After the transfer has completed, the library populates the transfer with the results and passes it back to the user.
pub const Transfer = extern struct {
    /// Transfer type
    pub const Type = enum(u8) {
        /// Control transfer
        control = 0,

        /// Isochronous transfer
        isochronous = 1,

        /// Bulk transfer
        bulk = 2,

        /// Interrupt transfer
        interrupt = 3,

        /// Bulk stream transfer
        bulk_stream = 4,
    };

    /// Handle of the device that this transfer will be submitted to
    dev_handle: *DeviceHandle,

    flags: packed struct {
        /// Report short frames as errors
        short_not_ok: bool,

        /// Automatically free() transfer buffer during libusb_free_transfer().
        /// Note that buffers allocated with libusb_dev_mem_alloc() should not
        /// be attempted freed in this way, since free() is not an appropriate
        /// way to release such memory.
        free_buffer: bool,

        /// Automatically call libusb_free_transfer() after callback returns.
        /// If this flag is set, it is illegal to call libusb_free_transfer()
        /// from your transfer callback, as this will result in a double-free
        /// when this flag is acted upon.
        free_transfer: bool,

        /// Terminate transfers that are a multiple of the endpoint's
        /// wMaxPacketSize with an extra zero length packet. This is useful
        /// when a device protocol mandates that each logical request is
        /// terminated by an incomplete packet (i.e. the logical requests are
        /// not separated by other means).
        ///
        /// This flag only affects host-to-device transfers to bulk and interrupt
        /// endpoints. In other situations, it is ignored.
        ///
        /// This flag only affects transfers with a length that is a multiple of
        /// the endpoint's wMaxPacketSize. On transfers of other lengths, this
        /// flag has no effect. Therefore, if you are working with a device that
        /// needs a ZLP whenever the end of the logical request falls on a packet
        /// boundary, then it is sensible to set this flag on <em>every</em>
        /// transfer (you do not have to worry about only setting it on transfers
        /// that end on the boundary).
        ///
        /// This flag is currently only supported on Linux.
        /// On other systems, libusb_submit_transfer() will return
        /// LIBUSB_ERROR_NOT_SUPPORTED for every transfer where this
        /// flag is set.
        ///
        /// Available since libusb-1.0.9.
        add_zero_packet: bool,

        _: u4 = 0,
    },

    /// Address of the endpoint where this transfer will be sent.
    endpoint: Endpoint,

    /// Type of the transfer from libusb_transfer_type
    type: Type,

    /// Timeout for this transfer in milliseconds. A value of 0 indicates no
    /// timeout.
    timeout: c_uint,

    /// The status of the transfer. Read-only, and only for use within
    /// transfer callback function.
    ///
    /// If this is an isochronous transfer, this field may read COMPLETED even
    /// if there were errors in the frames. Use the
    /// libusb_iso_packet_descriptor::status "status" field in each packet
    /// to determine if errors occurred.
    status: TransferStatus,

    /// Length of the data buffer. Must be non-negative.
    length: c_int,

    /// Actual length of data that was transferred. Read-only, and only for
    /// use within transfer callback function. Not valid for isochronous
    /// endpoint transfers.
    actual_length: c_int,

    /// Callback function. This will be invoked when the transfer completes,
    /// fails, or is cancelled.
    callback: ?*const fn (*Transfer) callconv(.C) void,

    /// User context data. Useful for associating specific data to a transfer
    /// that can be accessed from within the callback function.
    ///
    /// This field may be set manually or is taken as the `user_data` parameter
    /// of the following functions:
    /// - libusb_fill_bulk_transfer()
    /// - libusb_fill_bulk_stream_transfer()
    /// - libusb_fill_control_transfer()
    /// - libusb_fill_interrupt_transfer()
    /// - libusb_fill_iso_transfer()
    user_data: *anyopaque,

    /// Data buffer
    buffer: [*]u8,

    /// Number of isochronous packets. Only used for I/O with isochronous
    /// endpoints. Must be non-negative.
    num_iso_packets: c_int,

    /// Isochronous packet descriptors, for isochronous transfers only.
    pub fn iso_packet_desc(self: *const Transfer) []const ISOPacketDescriptor {
        return (@as([*c]const ISOPacketDescriptor, @alignCast(@ptrCast(@as([*c]const u8, @ptrCast(self)) + @sizeOf(Transfer)))))[0..self.num_iso_packets];
    }

    pub fn init(iso_packets: u31) !Transfer {
        if (c.libusb_alloc_transfer(@intCast(iso_packets))) |tx| {
            return tx;
        }

        return error.OutOfMemory;
    }

    pub fn deinit(self: *Transfer) void {
        c.libusb_free_transfer(self);
    }

    pub fn submit(self: *Transfer) !void {
        try c.libusb_submit_transfer(self).result();
    }

    pub fn cancel(self: *Transfer) !void {
        try c.libusb_cancel_transfer(self).result();
    }

    pub fn getStreamId(self: *Transfer) u32 {
        return c.libusb_transfer_get_stream_id(self);
    }

    pub fn setStreamId(self: *Transfer, stream_id: u32) void {
        c.libusb_transfer_set_stream_id(self, stream_id);
    }
};

/// Capabilities supported by an instance of libusb on the current running
/// platform. Test if the loaded library supports a given capability by calling
/// libusb_has_capability().
pub const Capability = enum(c_uint) {
    /// The libusb_has_capability() API is available.
    has_capability = 0x0000,

    /// Hotplug support is available on this platform.
    has_hotplug = 0x0001,

    /// The library can access HID devices without requiring user intervention.
    /// Note that before being able to actually access an HID device, you may
    /// still have to call additional libusb functions such as
    /// libusb_detach_kernel_driver().
    has_hid_access = 0x0100,

    /// The library supports detaching of the default USB driver, using
    /// libusb_detach_kernel_driver(), if one is set by the OS kernel
    supports_detach_kernel_driver = 0x0101,
};

/// Log message levels.
pub const LogLevel = enum(c_int) {
    /// Error messages are emitted
    err = 1,

    /// Warning and error messages are emitted
    warn = 2,

    /// Informational, warning and error messages are emitted
    info = 3,

    /// All messages are emitted
    debug = 4,
};

/// Log callback mode.
///
/// Since version 1.0.23, LIBUSB_API_VERSION >= 0x01000107
///
/// \see libusb_set_log_cb()
pub const LogCBMode = enum(c_int) {
    /// Callback function handling all log messages.
    global = (1 << 0),

    /// Callback function handling context related log messages.
    context = (1 << 1),
};

/// File descriptor for polling
pub const Pollfd = extern struct {
    fd: c_int,
    events: c_short,
};

/// Callback handle.
///
/// Callbacks handles are generated by libusb_hotplug_register_callback()
/// and can be used to deregister callbacks. Callback handles are unique
/// per libusb_context and it is safe to call libusb_hotplug_deregister_callback()
/// on an already deregistered callback.
///
/// Since version 1.0.16, LIBUSB_API_VERSION >= 0x01000102
///
/// For more information, see libusb_hotplug.
pub const HotplugCallbackHandle = c_int;

/// Since version 1.0.16, LIBUSB_API_VERSION >= 0x01000102
///
/// Hotplug events
pub const HotplugEvent = enum(c_int) {
    /// A device has been plugged in and is ready to use
    device_arrived = (1 << 0),

    /// A device has left and is no longer available.
    /// It is the user's responsibility to call libusb_close on any handle associated with a disconnected device.
    /// It is safe to call libusb_get_device_descriptor on a device that has left
    device_left = (1 << 1),
};

/// Structure providing the version of the libusb runtime
pub const Version = extern struct {
    /// Library major version.
    major: u16,

    /// Library minor version.
    minor: u16,

    /// Library micro version.
    micro: u16,

    /// Library nano version.
    nano: u16,

    /// Library release candidate suffix string, e.g. "-rc4".
    rc: [*c]const u8,

    /// For ABI compatibility only.
    describe: [*c]const u8,
};

pub const InitOptions = struct {
    log_level: ?LogLevel = null,
    log_cb: ?*const c.LogCallbackFn = null,
    use_usbdk: ?void = null,
    no_device_discovery: ?void = null,

    const max = @typeInfo(c.Option).Enum.fields.len;

    fn toInitOptionArray(self: InitOptions) std.meta.Tuple(&.{ [max]c.InitOption, usize }) {
        var init_options_arr: [max]c.InitOption = undefined;
        var option_count: usize = 0;
        const InitOptionValueUnion = @typeInfo(c.InitOption).Struct.fields[1].type;
        inline for (@typeInfo(InitOptions).Struct.fields) |field| {
            if (@field(self, field.name)) |value| {
                init_options_arr[option_count] = .{
                    .option = @field(c.Option, field.name),
                    .value = @unionInit(InitOptionValueUnion, if (@TypeOf(value) == void) "void" else field.name, value),
                };
                option_count += 1;
            }
        }

        return .{ init_options_arr, option_count };
    }
};

/// Structure representing a libusb session. The concept of individual libusb
/// sessions allows for your program to use two libraries (or dynamically
/// load two modules) which both independently use libusb. This will prevent
/// interference between the individual libusb users - for example
/// libusb_set_option() will not affect the other user of the library, and
/// libusb_exit() will not destroy resources that the other user is still
/// using.
///
/// Sessions are created by libusb_init_context() and destroyed through libusb_exit().
/// If your application is guaranteed to only ever include a single libusb
/// user (i.e. you), you do not have to worry about contexts: pass NULL in
/// every function call where a context is required, and the default context
/// will be used. Note that libusb_set_option(NULL, ...) is special, and adds
/// an option to a list of default options for new contexts.
///
/// For more information, see [Contexts](https://libusb.sourceforge.io/api-1.0/libusb_contexts.html).
pub const Context = opaque {
    pub fn init(options: InitOptions) !*Context {
        const init_options_arr, const option_count = options.toInitOptionArray();

        var ctx: ?*Context = null;
        try c.libusb_init_context(&ctx, &init_options_arr, @intCast(option_count)).result();
        return ctx.?;
    }

    pub fn deinit(self: *Context) void {
        c.libusb_exit(self);
    }

    pub fn getDeviceList(self: *Context) ![]*Device {
        var list: ?[*]*Device = null;
        const len = try c.libusb_get_device_list(self, &list).result();
        return list.?[0..len];
    }
};

/// Structure representing a USB device detected on the system. This is an
/// opaque type for which you are only ever provided with a pointer, usually
/// originating from libusb_get_device_list() or libusb_hotplug_register_callback().
///
/// Certain operations can be performed on a device, but in order to do any
/// I/O you will have to first obtain a device handle using libusb_open().
///
/// Devices are reference counted with libusb_ref_device() and
/// libusb_unref_device(), and are freed when the reference count reaches 0.
/// New devices presented by libusb_get_device_list() have a reference count of
/// 1, and libusb_free_device_list() can optionally decrease the reference count
/// on all devices in the list. libusb_open() adds another reference which is
/// later destroyed by libusb_close().
pub const Device = opaque {
    pub fn ref(self: *Device) *Device {
        return c.libusb_ref_device(self);
    }

    pub fn unref(self: *Device) void {
        return c.libusb_unref_device(self);
    }

    pub fn getDescriptor(self: *Device) !DeviceDescriptor {
        var desc: DeviceDescriptor = undefined;
        try c.libusb_get_device_descriptor(self, &desc).result();
        return desc;
    }

    pub fn getActiveConfigDescriptor(self: *Device) !*ConfigDescriptor {
        var config: ?*ConfigDescriptor = null;
        try c.libusb_get_active_config_descriptor(self, &config).result();
        return config.?;
    }

    pub fn open(self: *Device) !*DeviceHandle {
        var h: ?*DeviceHandle = null;
        try c.libusb_open(self, &h).result();
        return h.?;
    }

    pub fn getBusNumber(self: *Device) u8 {
        return c.libusb_get_bus_number(self);
    }

    pub fn getPortNumbers(self: *Device) !std.meta.Tuple(&.{ [7]u8, usize }) {
        var ports: [7]u8 = undefined;
        const len = try c.libusb_get_port_numbers(self, &ports, 7).result();
        return .{ ports, @intCast(len) };
    }
};

/// Structure representing a handle on a USB device. This is an opaque type for
/// which you are only ever provided with a pointer, usually originating from
/// libusb_open().
///
/// A device handle is used to perform I/O and other operations. When finished
/// with a device handle, you should call libusb_close().
pub const DeviceHandle = opaque {
    pub fn close(self: *DeviceHandle) void {
        c.libusb_close(self);
    }

    pub fn claimInterface(self: *DeviceHandle, interface_number: u8) !ClaimedInterface {
        return ClaimedInterface.init(self, interface_number);
    }

    pub fn reset(self: *DeviceHandle) !void {
        try c.libusb_reset_device(self).result();
    }

    pub fn clearHalt(self: *DeviceHandle, endpoint: Endpoint) !void {
        try c.libusb_clear_halt(self, endpoint.toU8()).result();
    }
};

pub const ClaimedInterface = struct {
    device_handle: *DeviceHandle,
    interface_number: c_int,

    pub fn init(device_handle: *DeviceHandle, interface_number: u8) !ClaimedInterface {
        try c.libusb_claim_interface(device_handle, @intCast(interface_number)).result();
        return .{
            .device_handle = device_handle,
            .interface_number = @intCast(interface_number),
        };
    }

    pub fn release(self: ClaimedInterface) void {
        switch (c.libusb_release_interface(self.device_handle, self.interface_number)) {
            .success, .no_device, .not_found => {},
            else => |err| std.log.warn("unexpected error occurred while releasing interface: {}", .{err}),
        }
    }

    pub const Writable = struct {
        device_handle: *DeviceHandle,
        endpoint: u8,
        timeout: c_uint,

        fn writeFn(context: *const anyopaque, bytes: []const u8) Error!usize {
            const self: *const Writable = @alignCast(@ptrCast(context));
            var written: c_int = 0;
            c.libusb_bulk_transfer(self.device_handle, self.endpoint, @constCast(bytes.ptr), @intCast(bytes.len), &written, self.timeout).result() catch |err| {
                if (err != error.OperationTimedOut) {
                    return err;
                }
            };

            return @intCast(written);
        }

        pub fn writer(self: *const Writable) std.io.AnyWriter {
            return .{
                .context = self,
                .writeFn = writeFn,
            };
        }
    };

    pub fn writable(self: ClaimedInterface, endpoint: Endpoint, timeout: u32) Writable {
        std.debug.assert(endpoint.direction == .output);
        return .{
            .device_handle = self.device_handle,
            .endpoint = endpoint.toU8(),
            .timeout = @intCast(timeout),
        };
    }

    pub const Readable = struct {
        device_handle: *DeviceHandle,
        endpoint: u8,
        timeout: c_uint,

        fn readFn(context: *const anyopaque, buffer: []u8) Error!usize {
            const self: *const Readable = @alignCast(@ptrCast(context));
            var read: c_int = 0;
            c.libusb_bulk_transfer(self.device_handle, self.endpoint, buffer.ptr, @intCast(buffer.len), &read, self.timeout).result() catch |err| {
                if (err != error.OperationTimedOut) {
                    return err;
                }
            };

            return @intCast(read);
        }

        pub fn reader(self: *const Readable) std.io.AnyReader {
            return .{
                .context = self,
                .readFn = readFn,
            };
        }
    };

    pub fn readable(self: ClaimedInterface, endpoint: Endpoint, timeout: u32) Readable {
        std.debug.assert(endpoint.direction == .input);
        return .{
            .device_handle = self.device_handle,
            .endpoint = endpoint.toU8(),
            .timeout = @intCast(timeout),
        };
    }
};

pub fn init(options: InitOptions) !void {
    const init_options_arr, const option_count = options.toInitOptionArray();
    try c.libusb_init_context(null, &init_options_arr, @intCast(option_count)).result();
}

pub fn deinit() void {
    c.libusb_exit(null);
}

pub fn getDeviceList() ![]*Device {
    var list: ?[*]*Device = null;
    const len = try c.libusb_get_device_list(null, &list).result();
    return list.?[0..len];
}

pub fn freeDeviceList(device_list: []*Device, unref_devices: bool) void {
    c.libusb_free_device_list(device_list.ptr, unref_devices);
}

test "struct sizes" {
    const realc = @cImport({
        @cInclude("libusb.h");
    });

    try testing.expectEqual(@sizeOf(realc.struct_libusb_device_descriptor), @sizeOf(DeviceDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_endpoint_descriptor), @sizeOf(EndpointDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_interface_association_descriptor), @sizeOf(InterfaceAssociationDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_interface_association_descriptor_array), @sizeOf(InterfaceAssociationDescriptorArray));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_interface_descriptor), @sizeOf(InterfaceDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_interface), @sizeOf(Interface));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_config_descriptor), @sizeOf(ConfigDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_ss_endpoint_companion_descriptor), @sizeOf(SSEndpointCompanionDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_bos_dev_capability_descriptor), @sizeOf(BOSDeviceCapabilityDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_bos_descriptor), @sizeOf(BOSDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_usb_2_0_extension_descriptor), @sizeOf(USB20ExtensionDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_ss_usb_device_capability_descriptor), @sizeOf(SSUSBDeviceCapabilityDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_container_id_descriptor), @sizeOf(ContainerIdDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_platform_descriptor), @sizeOf(PlatformDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_version), @sizeOf(Version));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_iso_packet_descriptor), @sizeOf(ISOPacketDescriptor));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_transfer), @sizeOf(Transfer));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_init_option), @sizeOf(c.InitOption));
    try testing.expectEqual(@sizeOf(realc.struct_libusb_pollfd), @sizeOf(Pollfd));
}

test "init context basic" {
    const ctx = try Context.init(.{});
    defer ctx.deinit();
}

test "init context log level" {
    const ctx = try Context.init(.{ .log_level = .err });
    defer ctx.deinit();
}

test "init context log callback" {
    const ctx = try Context.init(.{
        .log_cb = (struct {
            fn test_log_cb(_: *Context, _: LogLevel, _: [*c]const u8) callconv(.C) void {}
        }).test_log_cb,
    });
    defer ctx.deinit();
}

test "no device discovery" {
    if (builtin.os.tag != .linux) {
        return error.SkipZigTest;
    }

    const ctx = try Context.init(.{ .no_device_discovery = {} });
    defer ctx.deinit();
}

test "get device list" {
    const ctx = try Context.init(.{});
    defer ctx.deinit();

    const devices = try ctx.getDeviceList();
    defer freeDeviceList(devices, true);
}
