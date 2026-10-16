const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "vorbis",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    lib.root_module.addIncludePath(b.path("include"));
    lib.root_module.addIncludePath(b.path("lib"));
    lib.root_module.addCSourceFiles(.{
        .root = b.path("lib"),
        .files = &.{
            "analysis.c",
            "bitrate.c",
            "block.c",
            "codebook.c",
            "envelope.c",
            "floor0.c",
            "floor1.c",
            "info.c",
            "lookup.c",
            "lpc.c",
            "lsp.c",
            "mapping0.c",
            "mdct.c",
            "psy.c",
            "registry.c",
            "res0.c",
            "sharedbook.c",
            "smallft.c",
            "synthesis.c",
            "window.c",
            "vorbisfile.c",
        },
    });

    const ogg_dep = b.dependency("libogg", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.linkLibrary(ogg_dep.artifact("ogg"));
    lib.installHeadersDirectory(b.path("include/vorbis"), "vorbis", .{});
    b.installArtifact(lib);
}
