const std = @import("std");

pub fn build(b: *std.Build) void {
    const lib = b.addLibrary(.{
        .name = "ogg",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = b.standardTargetOptions(.{}),
            .optimize = b.standardOptimizeOption(.{}),
            .link_libc = true,
        }),
    });
    lib.root_module.addIncludePath(b.path("include"));
    lib.root_module.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "bitwise.c",
            "framing.c",
        },
    });
    const config_types = b.addConfigHeader(.{
        .style = .{ .autoconf_at = b.path("include/ogg/config_types.h.in") },
        .include_path = "ogg/config_types.h",
    }, .{
        .INCLUDE_INTTYPES_H = 1,
        .INCLUDE_STDINT_H = 1,
        .INCLUDE_SYS_TYPES_H = 1,
        .SIZE16 = "int16_t",
        .USIZE16 = "uint16_t",
        .SIZE32 = "int32_t",
        .USIZE32 = "uint32_t",
        .SIZE64 = "int64_t",
        .USIZE64 = "uint64_t",
    });
    lib.root_module.addConfigHeader(config_types);
    lib.installHeadersDirectory(b.path("include/ogg"), "ogg", .{});
    lib.installConfigHeader(config_types);
    b.installArtifact(lib);
}
