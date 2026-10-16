const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const librmx_dep = b.dependency("librmx", .{
        .target = target,
        .optimize = optimize,
    });

    const oxygenengine_dep = b.dependency("oxygenengine", .{
        .target = target,
        .optimize = optimize,
    });

    const oxygenserver_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    oxygenserver_mod.addIncludePath(librmx_dep.path("source"));
    oxygenserver_mod.addIncludePath(oxygenengine_dep.path("source"));
    oxygenserver_mod.addIncludePath(b.path("source"));
    oxygenserver_mod.addCSourceFiles(.{
        .root = b.path("source/oxygenserver"),
        .files = &.{
            "Configuration.cpp",
            "main_server.cpp",
            "pch.cpp",
            "server/CrashHandler.cpp",
            "server/Server.cpp",
            "server/ServerNetConnection.cpp",
            "subsystems/Channels.cpp",
            "subsystems/NetplaySetup.cpp",
            "subsystems/UpdateCheck.cpp",
            "subsystems/VirtualDirectory.cpp",
        },
    });
    oxygenserver_mod.linkLibrary(oxygenengine_dep.artifact("oxygen_netcore"));
    b.installArtifact(b.addExecutable(.{
        .name = "oxygenserver",
        .root_module = oxygenserver_mod,
    }));
}
