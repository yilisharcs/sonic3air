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
    const zlib = zlib_dep.artifact("z");
    b.installArtifact(zlib);

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

    //

    const librmx_dep = b.dependency("librmx", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(librmx_dep.artifact("rmxbase"));
    b.installArtifact(librmx_dep.artifact("rmxmedia"));
    b.installArtifact(librmx_dep.artifact("rmxext_oggvorbis"));

    const lemonscript_dep = b.dependency("lemonscript", .{
        .target = target,
        .optimize = optimize,
    });
    const lemonscript = lemonscript_dep.artifact("lemonscript");
    b.installArtifact(lemonscript);

    const oxygenengine_dep = b.dependency("oxygenengine", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(oxygenengine_dep.artifact("oxygenapp"));

    const oxygenserver_dep = b.dependency("oxygenserver", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(oxygenserver_dep.artifact("oxygenserver"));
}
