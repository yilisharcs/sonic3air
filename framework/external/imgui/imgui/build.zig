const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "imgui",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .link_libcpp = true,
        }),
    });
    lib.root_module.addIncludePath(b.path(""));
    lib.root_module.addCSourceFiles(.{
        .root = b.path(""),
        .files = &.{
            "imgui.cpp",
            "imgui_demo.cpp",
            "imgui_draw.cpp",
            "imgui_tables.cpp",
            "imgui_widgets.cpp",
            "backends/imgui_impl_opengl3.cpp",
            "backends/imgui_impl_sdl2.cpp",
        },
    });

    //@ framework/external/imgui/imgui/backends/imgui_impl_sdl2.cpp:116
    const sdl_dep = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addIncludePath(sdl_dep.path("include"));
    lib.root_module.addIncludePath(sdl_dep.path("include-pregen"));
    lib.root_module.linkLibrary(sdl_dep.artifact("SDL2"));

    lib.installHeader(b.path("imgui.h"), "imgui.h");
    lib.installHeader(b.path("imgui_internal.h"), "imgui_internal.h");
    lib.installHeader(b.path("imconfig.h"), "imconfig.h");
    lib.installHeader(b.path("backends/imgui_impl_opengl3.h"), "backends/imgui_impl_opengl3.h");
    lib.installHeader(b.path("backends/imgui_impl_sdl2.h"), "backends/imgui_impl_sdl2.h");

    b.installArtifact(lib);
}
