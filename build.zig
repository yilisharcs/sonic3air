const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_dep = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(sdl_dep.artifact("SDL2"));
}
