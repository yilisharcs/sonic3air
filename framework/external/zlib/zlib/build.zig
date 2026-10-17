const std = @import("std");

pub fn build(b: *std.Build) void {
    const lib = b.addLibrary(.{
        .name = "z",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = b.standardTargetOptions(.{}),
            .optimize = b.standardOptimizeOption(.{}),
            .link_libc = true,
        }),
    });
    lib.root_module.addCSourceFiles(.{
        .root = b.path(""),
        .files = &.{
            "adler32.c",
            "compress.c",
            "crc32.c",
            "deflate.c",
            "gzclose.c",
            "gzlib.c",
            "gzread.c",
            "gzwrite.c",
            "infback.c",
            "inffast.c",
            "inflate.c",
            "inftrees.c",
            "trees.c",
            "uncompr.c",
            "zutil.c",
        },
        .flags = &.{
            "-DHAVE_SYS_TYPES_H",
            "-DHAVE_STDINT_H",
            "-DHAVE_STDDEF_H",
            "-DZ_HAVE_UNISTD_H",
        },
    });
    lib.installHeadersDirectory(b.path(""), "", .{
        .include_extensions = &.{
            "zconf.h",
            "zlib.h",
        },
    });
    b.installArtifact(lib);
}
