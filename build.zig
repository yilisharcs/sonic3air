const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_dep = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(sdl_dep.artifact("SDL2"));

    const zlib_dep = b.dependency("zlib", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(zlib_dep.artifact("z"));

    //

    const imgui_dep = b.dependency("imgui", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(imgui_dep.artifact("imgui"));

    const libogg_dep = b.dependency("libogg", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(libogg_dep.artifact("ogg"));

    const libvorbis_dep = b.dependency("libvorbis", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(libvorbis_dep.artifact("vorbis"));
}
