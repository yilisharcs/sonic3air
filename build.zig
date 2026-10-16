const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const engine = b.dependency("oxygenengine", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(engine.artifact("oxygenapp"));

    const server = b.dependency("oxygenserver", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(server.artifact("oxygenserver"));

    const game = b.dependency("sonic3air_game", .{
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(game.artifact("sonic3air"));
}
